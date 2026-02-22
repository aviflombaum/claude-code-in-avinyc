#!/bin/bash
# rkhunter-scan.sh - Run rkhunter rootkit scan and alert on findings
# Runs weekly via cron (Sunday 3 AM)

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_FILE="/opt/server-security/config/alert.conf"
LOG_DIR="/opt/server-security/logs"
REPORT_FILE="$LOG_DIR/rkhunter-$(date +%Y%m%d).log"

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

source "$CONFIG_FILE"

# Helper function to send alert
send_alert() {
    local type="$1"
    local message="$2"
    local priority="$3"
    "$SCRIPT_DIR/send-alert.sh" "$type" "$message" "$priority"
}

echo "[$(date)] Starting rkhunter scan..."

# Update rkhunter database first
rkhunter --update --nocolors 2>&1 || true

# Run the scan
# --skip-keypress: don't wait for user input
# --report-warnings-only: only show warnings
# --nocolors: no ANSI colors in output
rkhunter --check --skip-keypress --report-warnings-only --nocolors > "$REPORT_FILE" 2>&1 || true

# Check for warnings
WARNING_COUNT=$(grep -c "Warning:" "$REPORT_FILE" 2>/dev/null || echo "0")
INFECTED_COUNT=$(grep -c "Infected" "$REPORT_FILE" 2>/dev/null || echo "0")
ROOTKIT_COUNT=$(grep -c "Rootkit" "$REPORT_FILE" 2>/dev/null || echo "0")

echo "[$(date)] Scan complete. Warnings: $WARNING_COUNT, Infected: $INFECTED_COUNT, Rootkits: $ROOTKIT_COUNT"

# Determine alert priority based on findings
if [[ "$INFECTED_COUNT" -gt 0 ]] || [[ "$ROOTKIT_COUNT" -gt 0 ]]; then
    # Critical findings - possible rootkit
    SUMMARY=$(grep -E "(Infected|Rootkit)" "$REPORT_FILE" | head -5 | tr '\n' ' ')
    send_alert "rkhunter_critical" "CRITICAL: Possible rootkit detected! Infected: $INFECTED_COUNT, Rootkits: $ROOTKIT_COUNT. Summary: $SUMMARY" "urgent"
elif [[ "$WARNING_COUNT" -gt 10 ]]; then
    # Many warnings - needs attention
    SUMMARY=$(grep "Warning:" "$REPORT_FILE" | head -3 | tr '\n' ' ')
    send_alert "rkhunter_warnings" "rkhunter found $WARNING_COUNT warnings. First few: $SUMMARY" "high"
elif [[ "$WARNING_COUNT" -gt 0 ]]; then
    # Some warnings - informational
    SUMMARY=$(grep "Warning:" "$REPORT_FILE" | head -3 | tr '\n' ' ')
    send_alert "rkhunter_scan" "Weekly rkhunter scan: $WARNING_COUNT warnings. $SUMMARY" "low"
else
    # Clean scan - just log, don't alert
    echo "[$(date)] Clean scan - no warnings"
fi

# Cleanup old reports (keep 4 weeks)
find "$LOG_DIR" -name "rkhunter-*.log" -mtime +28 -delete 2>/dev/null || true

echo "[$(date)] rkhunter scan complete"
