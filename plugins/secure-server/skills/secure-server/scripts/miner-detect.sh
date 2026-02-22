#!/bin/bash
# miner-detect.sh - Detect crypto miners via CPU, processes, and network connections
# Runs every 5 minutes via cron

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="/opt/server-security/config"
CONFIG_FILE="$CONFIG_DIR/alert.conf"
WHITELIST_FILE="$CONFIG_DIR/process-whitelist.txt"
STATE_DIR="/opt/server-security/state"

# Create state directory if needed
mkdir -p "$STATE_DIR"

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

# Thresholds
CPU_THRESHOLD="${CPU_THRESHOLD:-80}"           # Percent of cores for sustained spike
PROCESS_CPU_THRESHOLD="${PROCESS_CPU_THRESHOLD:-50}"  # Single process CPU%
SPIKE_COUNT_THRESHOLD="${SPIKE_COUNT_THRESHOLD:-3}"   # Consecutive checks before alerting

ALERTS_SENT=0

# =============================================================================
# Check 1: Sustained CPU Spike Detection
# =============================================================================
CPU_CORES=$(nproc)
LOAD=$(awk '{print $1}' /proc/loadavg)
THRESHOLD=$(awk "BEGIN {printf \"%.1f\", $CPU_CORES * ($CPU_THRESHOLD / 100)}")

SPIKE_FILE="$STATE_DIR/cpu_spike_count"

if (( $(echo "$LOAD > $THRESHOLD" | bc -l) )); then
    # Increment spike counter
    SPIKE_COUNT=$(cat "$SPIKE_FILE" 2>/dev/null || echo 0)
    SPIKE_COUNT=$((SPIKE_COUNT + 1))
    echo "$SPIKE_COUNT" > "$SPIKE_FILE"

    if [[ $SPIKE_COUNT -ge $SPIKE_COUNT_THRESHOLD ]]; then
        # Get top CPU consumers for context
        TOP_PROCS=$(ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%s (%.1f%%), ", $11, $3}')
        send_alert "cpu_spike" "Sustained high CPU: load $LOAD (threshold: $THRESHOLD) for $((SPIKE_COUNT * 5)) min. Top: $TOP_PROCS" "urgent"
        ALERTS_SENT=$((ALERTS_SENT + 1))

        # Reset counter after alerting to avoid spam (will alert again if continues)
        echo "0" > "$SPIKE_FILE"
    fi
else
    # Reset counter when load is normal
    rm -f "$SPIKE_FILE"
fi

# =============================================================================
# Check 2: Suspicious Process Detection
# =============================================================================
# Find processes using more than threshold CPU that aren't whitelisted

if [[ -f "$WHITELIST_FILE" ]]; then
    while read -r PROC CPU; do
        # Skip empty lines
        [[ -z "$PROC" ]] && continue

        # Get just the process name
        PROC_NAME=$(basename "$PROC" 2>/dev/null || echo "$PROC")

        # Check if whitelisted (prefix match to handle versioned names like ruby3.0)
        PROC_BASE="${PROC_NAME%%[0-9.]*}"
        if ! grep -qi "^${PROC_BASE}$" "$WHITELIST_FILE" 2>/dev/null && \
           ! grep -qi "^${PROC_NAME}$" "$WHITELIST_FILE" 2>/dev/null; then
            # Additional check: skip common system processes and utilities
            case "$PROC_NAME" in
                kworker/*|ksoftirqd/*|rcu_*|migration/*|watchdog/*|kthreadd|init|systemd*)
                    continue
                    ;;
                # Skip common utilities that may briefly spike CPU
                ps|top|htop|awk|grep|sed|find|sort|uniq|cut|head|tail|wc|cat|less|more|ssh|scp|rsync|curl|wget)
                    continue
                    ;;
                # Skip package managers and system tools
                apt|apt-get|dpkg|aptitude|update-*|unattended-*)
                    continue
                    ;;
            esac

            # Dedup: check if we alerted on this process recently
            PROC_HASH=$(echo "$PROC_NAME" | md5sum | cut -c1-8)
            PROC_ALERT_FILE="$STATE_DIR/proc_alert_$PROC_HASH"

            if [[ ! -f "$PROC_ALERT_FILE" ]] || [[ $(find "$PROC_ALERT_FILE" -mmin +30 2>/dev/null) ]]; then
                send_alert "suspicious_process" "Unknown process using ${CPU}% CPU: $PROC (not in whitelist)" "urgent"
                touch "$PROC_ALERT_FILE"
                ALERTS_SENT=$((ALERTS_SENT + 1))
            fi
        fi
    done < <(ps aux --sort=-%cpu | awk -v thresh="$PROCESS_CPU_THRESHOLD" 'NR>1 && $3 > thresh {print $11, $3}')
fi

# =============================================================================
# Check 3: Mining Pool Connection Detection
# =============================================================================
# Common mining pool ports (excluding 8080 which is used by web proxies)
# Removed ambiguous ports (9999, 6666, 7777) that trigger false positives on dev servers
MINING_PORTS="3333|4444|5555|8333|14444|14433|45700|3357"

# Check for established connections to mining ports
# Filter out localhost, Docker internal IPs, and private networks
SUSPICIOUS_CONNS=$(ss -tn state established 2>/dev/null | \
    grep -E ":($MINING_PORTS)\s" | \
    grep -vE "(127\.0\.0\.1|::1|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.|10\.|192\.168\.)" || true)

if [[ -n "$SUSPICIOUS_CONNS" ]]; then
    # Dedup: check if we alerted recently
    CONN_ALERT_FILE="$STATE_DIR/mining_conn_alert"

    if [[ ! -f "$CONN_ALERT_FILE" ]] || [[ $(find "$CONN_ALERT_FILE" -mmin +30 2>/dev/null) ]]; then
        # Get just the remote addresses
        REMOTE_ADDRS=$(echo "$SUSPICIOUS_CONNS" | awk '{print $4}' | tr '\n' ', ' | sed 's/, $//')
        send_alert "mining_connection" "Possible mining pool connection detected: $REMOTE_ADDRS" "urgent"
        touch "$CONN_ALERT_FILE"
        ALERTS_SENT=$((ALERTS_SENT + 1))
    fi
fi

# =============================================================================
# Check 4: Known Miner Process Names
# =============================================================================
KNOWN_MINERS="xmrig|xmr-stak|minerd|cgminer|bfgminer|ethminer|nbminer|t-rex|gminer|lolminer|phoenixminer|claymore|nanominer|cpuminer|ccminer"

MINER_PROCS=$(ps aux | grep -iE "$KNOWN_MINERS" | grep -v grep || true)

if [[ -n "$MINER_PROCS" ]]; then
    MINER_ALERT_FILE="$STATE_DIR/known_miner_alert"

    if [[ ! -f "$MINER_ALERT_FILE" ]] || [[ $(find "$MINER_ALERT_FILE" -mmin +30 2>/dev/null) ]]; then
        MINER_NAMES=$(echo "$MINER_PROCS" | awk '{print $11}' | tr '\n' ', ' | sed 's/, $//')
        send_alert "known_miner" "Known mining software detected: $MINER_NAMES" "urgent"
        touch "$MINER_ALERT_FILE"
        ALERTS_SENT=$((ALERTS_SENT + 1))
    fi
fi

# =============================================================================
# Cleanup old state files (older than 1 day)
# =============================================================================
find "$STATE_DIR" -type f -mtime +1 -delete 2>/dev/null || true

echo "[$(date)] Miner detection complete. Alerts sent: $ALERTS_SENT"
