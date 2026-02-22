#!/bin/bash
# send-alert.sh - Send alerts to Cloudflare Worker
# Usage: send-alert.sh <type> <message> <priority>
# Priority: low, medium, high, urgent

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
    echo "Error: Missing required config (ALERT_ENDPOINT, ALERT_SECRET, or SERVER_NAME)" >&2
    exit 1
fi

# Arguments
ALERT_TYPE="${1:-unknown}"
MESSAGE="${2:-No message provided}"
PRIORITY="${3:-medium}"

# Validate priority
case "$PRIORITY" in
    low|medium|high|urgent) ;;
    *) PRIORITY="medium" ;;
esac

# Build JSON payload (using jq for safe escaping)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
PAYLOAD=$(jq -n \
    --arg server "$SERVER_NAME" \
    --arg type "$ALERT_TYPE" \
    --arg msg "$MESSAGE" \
    --arg priority "$PRIORITY" \
    --arg ts "$TIMESTAMP" \
    '{server: $server, type: $type, message: $msg, priority: $priority, timestamp: $ts}')

# Send to Cloudflare Worker
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${ALERT_ENDPOINT}/alert" \
    -H "Content-Type: application/json" \
    -H "X-Alert-Secret: ${ALERT_SECRET}" \
    -d "$PAYLOAD" \
    --max-time 10 \
    2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
    echo "[$(date)] Alert sent successfully: $ALERT_TYPE - $MESSAGE"
else
    echo "[$(date)] Failed to send alert (HTTP $HTTP_CODE): $BODY" >&2
    exit 1
fi
