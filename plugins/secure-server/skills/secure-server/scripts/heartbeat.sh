#!/bin/bash
# heartbeat.sh - Send heartbeat with system metrics to Cloudflare Worker
# Runs every 5 minutes via cron

set -euo pipefail

CONFIG_FILE="/opt/server-security/config/alert.conf"

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

source "$CONFIG_FILE"

# Validate required config
if [[ -z "${ALERT_ENDPOINT:-}" ]] || [[ -z "${ALERT_SECRET:-}" ]] || [[ -z "${SERVER_NAME:-}" ]]; then
    echo "Error: Missing required config" >&2
    exit 1
fi

# Collect metrics
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
UPTIME_SECONDS=$(awk '{print int($1)}' /proc/uptime)
LOAD_1=$(awk '{print $1}' /proc/loadavg)
LOAD_5=$(awk '{print $2}' /proc/loadavg)
LOAD_15=$(awk '{print $3}' /proc/loadavg)
CPU_CORES=$(nproc)

# Memory info (in MB)
MEM_TOTAL=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
MEM_AVAILABLE=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
MEM_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED/$MEM_TOTAL)*100}")

# Disk usage (root partition)
DISK_TOTAL=$(df -BG / | awk 'NR==2 {gsub("G",""); print $2}')
DISK_USED=$(df -BG / | awk 'NR==2 {gsub("G",""); print $3}')
DISK_PERCENT=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

# Service status
FAIL2BAN_STATUS=$(systemctl is-active fail2ban 2>/dev/null || echo "inactive")
UFW_STATUS=$(ufw status 2>/dev/null | head -1 | awk '{print $2}' || echo "unknown")
AUDITD_STATUS=$(systemctl is-active auditd 2>/dev/null || echo "inactive")

# Build JSON payload
PAYLOAD=$(cat <<EOF
{
    "server": "$SERVER_NAME",
    "timestamp": "$TIMESTAMP",
    "uptime_seconds": $UPTIME_SECONDS,
    "cpu": {
        "cores": $CPU_CORES,
        "load_1": $LOAD_1,
        "load_5": $LOAD_5,
        "load_15": $LOAD_15
    },
    "memory": {
        "total_mb": $MEM_TOTAL,
        "used_mb": $MEM_USED,
        "percent": $MEM_PERCENT
    },
    "disk": {
        "total_gb": $DISK_TOTAL,
        "used_gb": $DISK_USED,
        "percent": $DISK_PERCENT
    },
    "services": {
        "fail2ban": "$FAIL2BAN_STATUS",
        "ufw": "$UFW_STATUS",
        "auditd": "$AUDITD_STATUS"
    }
}
EOF
)

# Send to Cloudflare Worker
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${ALERT_ENDPOINT}/heartbeat" \
    -H "Content-Type: application/json" \
    -H "X-Alert-Secret: ${ALERT_SECRET}" \
    -d "$PAYLOAD" \
    --max-time 10 \
    2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
    echo "[$(date)] Heartbeat sent successfully"
else
    echo "[$(date)] Failed to send heartbeat (HTTP $HTTP_CODE)" >&2
fi
