#!/bin/bash
# health-check.sh - Alert on high disk/memory/load
# Runs every 15 minutes via cron

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_FILE="/opt/server-security/config/alert.conf"

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

source "$CONFIG_FILE"

# Thresholds (can be overridden in config)
DISK_THRESHOLD="${DISK_THRESHOLD:-85}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD:-90}"
LOAD_THRESHOLD_MULTIPLIER="${LOAD_THRESHOLD_MULTIPLIER:-2.0}"

# Helper function to send alert
send_alert() {
    local type="$1"
    local message="$2"
    local priority="$3"
    "$SCRIPT_DIR/send-alert.sh" "$type" "$message" "$priority"
}

# Track if any alerts were sent
ALERTS_SENT=0

# Check disk usage
DISK_PERCENT=$(df / | awk 'NR==2 {gsub("%",""); print $5}')
if [[ "$DISK_PERCENT" -ge "$DISK_THRESHOLD" ]]; then
    send_alert "disk_high" "Disk usage at ${DISK_PERCENT}% (threshold: ${DISK_THRESHOLD}%)" "high"
    ALERTS_SENT=$((ALERTS_SENT + 1))
fi

# Check memory usage
MEM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEM_AVAILABLE=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
MEM_PERCENT=$(awk "BEGIN {printf \"%.0f\", ($MEM_USED/$MEM_TOTAL)*100}")

if [[ "$MEM_PERCENT" -ge "$MEMORY_THRESHOLD" ]]; then
    send_alert "memory_high" "Memory usage at ${MEM_PERCENT}% (threshold: ${MEMORY_THRESHOLD}%)" "high"
    ALERTS_SENT=$((ALERTS_SENT + 1))
fi

# Check load average
CPU_CORES=$(nproc)
LOAD_1=$(awk '{print $1}' /proc/loadavg)
LOAD_THRESHOLD=$(awk "BEGIN {printf \"%.1f\", $CPU_CORES * $LOAD_THRESHOLD_MULTIPLIER}")

# Compare using bc for floating point
if (( $(echo "$LOAD_1 > $LOAD_THRESHOLD" | bc -l) )); then
    send_alert "load_high" "Load average ${LOAD_1} exceeds threshold ${LOAD_THRESHOLD} (${CPU_CORES} cores)" "high"
    ALERTS_SENT=$((ALERTS_SENT + 1))
fi

# Check for zombie processes
ZOMBIES=$(ps aux | awk '$8 ~ /^Z/ {count++} END {print count+0}')
if [[ "$ZOMBIES" -gt 5 ]]; then
    send_alert "zombies" "Found ${ZOMBIES} zombie processes" "medium"
    ALERTS_SENT=$((ALERTS_SENT + 1))
fi

# Check for OOM kills in last hour
OOM_KILLS=$(dmesg 2>/dev/null | grep -c "Out of memory" || true)
OOM_KILLS=${OOM_KILLS:-0}
if [[ "$OOM_KILLS" -gt 0 ]]; then
    # Check if we already alerted (simple dedup using temp file)
    OOM_ALERT_FILE="/tmp/server_security_oom_alert"
    if [[ ! -f "$OOM_ALERT_FILE" ]] || [[ $(find "$OOM_ALERT_FILE" -mmin +60 2>/dev/null) ]]; then
        send_alert "oom_kill" "OOM killer has been active - $OOM_KILLS events in dmesg" "urgent"
        touch "$OOM_ALERT_FILE"
        ALERTS_SENT=$((ALERTS_SENT + 1))
    fi
fi

echo "[$(date)] Health check complete. Alerts sent: $ALERTS_SENT"
