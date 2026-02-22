/**
 * Server Security Alerts - Cloudflare Worker
 *
 * Centralized alert hub for server security monitoring.
 * Receives alerts from servers, stores in KV, forwards high-priority to Ntfy.
 *
 * Endpoints:
 *   POST /alert     - Receive alerts from servers
 *   POST /heartbeat - Receive heartbeats with metrics
 *   GET  /status    - Dashboard JSON showing all alerts and server health
 *   GET  /health    - Simple health check
 *
 * Environment:
 *   ALERT_SECRET    - Shared secret for authentication (set via wrangler secret)
 *   ALERTS_KV       - KV namespace binding
 *   NTFY_TOPIC      - Ntfy topic for push notifications
 */

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS headers for status endpoint
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, X-Alert-Secret',
    };

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      // Route requests
      if (path === '/alert' && request.method === 'POST') {
        return await handleAlert(request, env, corsHeaders);
      } else if (path === '/heartbeat' && request.method === 'POST') {
        return await handleHeartbeat(request, env, corsHeaders);
      } else if (path === '/status' && request.method === 'GET') {
        return await handleStatus(request, env, corsHeaders);
      } else if (path === '/health' && request.method === 'GET') {
        return jsonResponse({ status: 'ok', timestamp: new Date().toISOString() }, corsHeaders);
      } else {
        return jsonResponse({ error: 'Not found' }, corsHeaders, 404);
      }
    } catch (error) {
      console.error('Worker error:', error);
      return jsonResponse({ error: 'Internal server error' }, corsHeaders, 500);
    }
  },

  // Cron trigger for dead man's switch
  async scheduled(event, env, ctx) {
    await checkDeadManSwitch(env);
  }
};

/**
 * Validate the shared secret
 */
function validateSecret(request, env) {
  const secret = request.headers.get('X-Alert-Secret');
  return secret === env.ALERT_SECRET;
}

/**
 * Handle incoming alert
 */
async function handleAlert(request, env, corsHeaders) {
  // Validate authentication
  if (!validateSecret(request, env)) {
    return jsonResponse({ error: 'Unauthorized' }, corsHeaders, 401);
  }

  // Parse request body
  let data;
  try {
    data = await request.json();
  } catch (e) {
    return jsonResponse({ error: 'Invalid JSON' }, corsHeaders, 400);
  }

  // Validate required fields
  const { server, type, message, priority = 'medium', timestamp } = data;
  if (!server || !type || !message) {
    return jsonResponse({ error: 'Missing required fields: server, type, message' }, corsHeaders, 400);
  }

  // Create alert record
  const alertId = `alert:${Date.now()}:${Math.random().toString(36).substr(2, 9)}`;
  const alert = {
    id: alertId,
    server,
    type,
    message,
    priority,
    timestamp: timestamp || new Date().toISOString(),
    receivedAt: new Date().toISOString(),
  };

  // Check for deduplication (same server + type within 5 minutes)
  const dedupeKey = `dedupe:${server}:${type}`;
  const existingDedupe = await env.ALERTS_KV.get(dedupeKey);

  if (existingDedupe && priority !== 'urgent') {
    // Skip duplicate, but acknowledge receipt
    return jsonResponse({
      status: 'deduplicated',
      message: 'Similar alert received recently'
    }, corsHeaders);
  }

  // Store deduplication marker (5 minute TTL)
  await env.ALERTS_KV.put(dedupeKey, 'true', { expirationTtl: 300 });

  // Store alert in KV (30 day retention)
  const retentionDays = parseInt(env.ALERT_RETENTION_DAYS) || 30;
  await env.ALERTS_KV.put(alertId, JSON.stringify(alert), {
    expirationTtl: retentionDays * 24 * 60 * 60
  });

  // Add to recent alerts list for the server
  await addToRecentAlerts(env, server, alertId);

  // Forward high/urgent priority to Ntfy
  if (priority === 'high' || priority === 'urgent') {
    await sendToNtfy(env, alert);
  }

  return jsonResponse({ status: 'ok', alertId }, corsHeaders);
}

/**
 * Handle heartbeat from server
 */
async function handleHeartbeat(request, env, corsHeaders) {
  // Validate authentication
  if (!validateSecret(request, env)) {
    return jsonResponse({ error: 'Unauthorized' }, corsHeaders, 401);
  }

  // Parse request body
  let data;
  try {
    data = await request.json();
  } catch (e) {
    return jsonResponse({ error: 'Invalid JSON' }, corsHeaders, 400);
  }

  const { server, timestamp, ...metrics } = data;
  if (!server) {
    return jsonResponse({ error: 'Missing required field: server' }, corsHeaders, 400);
  }

  // Store heartbeat
  const heartbeat = {
    server,
    timestamp: timestamp || new Date().toISOString(),
    receivedAt: new Date().toISOString(),
    metrics,
  };

  // Store current heartbeat (overwrites previous)
  await env.ALERTS_KV.put(`heartbeat:${server}`, JSON.stringify(heartbeat), {
    expirationTtl: 24 * 60 * 60 // 24 hour TTL
  });

  // Update server list
  await addToServerList(env, server);

  return jsonResponse({ status: 'ok' }, corsHeaders);
}

/**
 * Handle status dashboard request (requires authentication)
 */
async function handleStatus(request, env, corsHeaders) {
  // Check for status token authentication
  const url = new URL(request.url);
  const token = url.searchParams.get('token') || request.headers.get('X-Status-Token');

  if (!token || token !== env.STATUS_TOKEN) {
    return jsonResponse({ error: 'Unauthorized - status token required' }, corsHeaders, 401);
  }

  // Get list of known servers
  const serverListJson = await env.ALERTS_KV.get('servers:list');
  const servers = serverListJson ? JSON.parse(serverListJson) : [];

  // Build status for each server
  const serverStatuses = await Promise.all(servers.map(async (server) => {
    // Get heartbeat
    const heartbeatJson = await env.ALERTS_KV.get(`heartbeat:${server}`);
    const heartbeat = heartbeatJson ? JSON.parse(heartbeatJson) : null;

    // Get recent alerts
    const recentAlertsJson = await env.ALERTS_KV.get(`alerts:recent:${server}`);
    const recentAlertIds = recentAlertsJson ? JSON.parse(recentAlertsJson) : [];

    // Fetch recent alert details (last 10)
    const recentAlerts = await Promise.all(
      recentAlertIds.slice(0, 10).map(async (id) => {
        const alertJson = await env.ALERTS_KV.get(id);
        return alertJson ? JSON.parse(alertJson) : null;
      })
    );

    // Calculate health status
    let health = 'unknown';
    if (heartbeat) {
      const lastSeen = new Date(heartbeat.receivedAt);
      const minutesAgo = (Date.now() - lastSeen.getTime()) / (1000 * 60);
      const timeout = parseInt(env.HEARTBEAT_TIMEOUT_MINUTES) || 15;

      if (minutesAgo < timeout) {
        health = 'healthy';
      } else if (minutesAgo < timeout * 2) {
        health = 'warning';
      } else {
        health = 'critical';
      }
    }

    return {
      server,
      health,
      lastHeartbeat: heartbeat,
      recentAlerts: recentAlerts.filter(a => a !== null),
    };
  }));

  // Get global stats
  const stats = {
    totalServers: servers.length,
    healthyServers: serverStatuses.filter(s => s.health === 'healthy').length,
    warningServers: serverStatuses.filter(s => s.health === 'warning').length,
    criticalServers: serverStatuses.filter(s => s.health === 'critical').length,
  };

  return jsonResponse({
    timestamp: new Date().toISOString(),
    stats,
    servers: serverStatuses,
  }, corsHeaders);
}

/**
 * Check for missing heartbeats (dead man's switch)
 */
async function checkDeadManSwitch(env) {
  const serverListJson = await env.ALERTS_KV.get('servers:list');
  const servers = serverListJson ? JSON.parse(serverListJson) : [];

  const timeout = parseInt(env.HEARTBEAT_TIMEOUT_MINUTES) || 15;

  for (const server of servers) {
    const heartbeatJson = await env.ALERTS_KV.get(`heartbeat:${server}`);

    if (!heartbeatJson) {
      continue; // No heartbeat ever received, skip
    }

    const heartbeat = JSON.parse(heartbeatJson);
    const lastSeen = new Date(heartbeat.receivedAt);
    const minutesAgo = (Date.now() - lastSeen.getTime()) / (1000 * 60);

    // Check if we need to alert
    const alertKey = `deadman:alerted:${server}`;
    const alreadyAlerted = await env.ALERTS_KV.get(alertKey);

    if (minutesAgo > timeout && !alreadyAlerted) {
      // Send alert
      await sendToNtfy(env, {
        server,
        type: 'heartbeat_missing',
        message: `No heartbeat from ${server} for ${Math.round(minutesAgo)} minutes`,
        priority: 'urgent',
      });

      // Mark as alerted (1 hour TTL to avoid spam)
      await env.ALERTS_KV.put(alertKey, 'true', { expirationTtl: 3600 });
    } else if (minutesAgo <= timeout && alreadyAlerted) {
      // Server recovered, clear alert marker
      await env.ALERTS_KV.delete(alertKey);

      // Send recovery notification
      await sendToNtfy(env, {
        server,
        type: 'heartbeat_recovered',
        message: `${server} is back online`,
        priority: 'low',
      });
    }
  }
}

/**
 * Send notification to Ntfy
 */
async function sendToNtfy(env, alert) {
  const topic = env.NTFY_TOPIC || 'server-alerts';
  const url = `https://ntfy.sh/${topic}`;

  // Map priority to ntfy priority
  const priorityMap = {
    low: '2',
    medium: '3',
    high: '4',
    urgent: '5',
  };

  // Map alert type to emoji
  const emojiMap = {
    fail2ban_ban: '\u{1F6AB}',
    fail2ban_unban: '\u2705',
    disk_high: '\u{1F4BE}',
    memory_high: '\u{1F9E0}',
    load_high: '\u{1F4C8}',
    cpu_spike: '\u{1F525}',
    suspicious_process: '\u26A0\uFE0F',
    mining_connection: '\u26CF\uFE0F',
    known_miner: '\u{1F6A8}',
    rkhunter_critical: '\u2620\uFE0F',
    rkhunter_warnings: '\u{1F50D}',
    rkhunter_scan: '\u{1F50D}',
    heartbeat_missing: '\u{1F494}',
    heartbeat_recovered: '\u{1F49A}',
    oom_kill: '\u{1F480}',
    zombies: '\u{1F9DF}',
    test: '\u{1F9EA}',
  };

  const emoji = emojiMap[alert.type] || '\u{1F514}';
  const title = `${emoji} [${alert.server}] ${alert.type}`;

  // Build headers
  const headers = {
    'Title': title,
    'Priority': priorityMap[alert.priority] || '3',
    'Tags': `server,${alert.type},${alert.priority}`,
  };

  // Add auth token if configured (for reserved topics)
  if (env.NTFY_TOKEN) {
    headers['Authorization'] = `Bearer ${env.NTFY_TOKEN}`;
  }

  // Add email forwarding for high/urgent priority alerts
  if (env.ALERT_EMAIL && (alert.priority === 'high' || alert.priority === 'urgent')) {
    headers['Email'] = env.ALERT_EMAIL;
  }

  // Add click URL to status dashboard if configured
  if (env.STATUS_URL && env.STATUS_TOKEN) {
    headers['Click'] = `${env.STATUS_URL}/status?token=${env.STATUS_TOKEN}`;
  }

  try {
    await fetch(url, {
      method: 'POST',
      headers,
      body: alert.message,
    });
  } catch (error) {
    console.error('Failed to send to Ntfy:', error);
  }
}

/**
 * Add alert ID to server's recent alerts list
 */
async function addToRecentAlerts(env, server, alertId) {
  const key = `alerts:recent:${server}`;
  const existingJson = await env.ALERTS_KV.get(key);
  const existing = existingJson ? JSON.parse(existingJson) : [];

  // Add new alert to front, keep last 50
  existing.unshift(alertId);
  const trimmed = existing.slice(0, 50);

  await env.ALERTS_KV.put(key, JSON.stringify(trimmed), {
    expirationTtl: 30 * 24 * 60 * 60 // 30 days
  });
}

/**
 * Add server to known servers list
 */
async function addToServerList(env, server) {
  const key = 'servers:list';
  const existingJson = await env.ALERTS_KV.get(key);
  const existing = existingJson ? JSON.parse(existingJson) : [];

  if (!existing.includes(server)) {
    existing.push(server);
    await env.ALERTS_KV.put(key, JSON.stringify(existing));
  }
}

/**
 * Helper to return JSON response
 */
function jsonResponse(data, corsHeaders, status = 200) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
    },
  });
}
