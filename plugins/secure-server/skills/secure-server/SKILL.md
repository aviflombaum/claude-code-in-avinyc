---
name: secure-server
description: This skill should be used when the user asks to "secure server", "harden server", "server hardening", "setup server security", or needs to configure fail2ban, UFW, auditd, rkhunter, unattended-upgrades, or security alerting on Ubuntu servers.
user-invocable: true
argument-hint: "[server hostname or IP]"
disable-model-invocation: true
---

# Server Hardening Skill

## Overview

This skill hardens Ubuntu servers with:
- **fail2ban** - Block IPs after failed SSH attempts
- **UFW** - Firewall with deny-by-default policy
- **auditd** - Monitor critical file changes
- **rkhunter** - Weekly rootkit scans
- **unattended-upgrades** - Automatic security patches
- **Custom alerting** - Sends alerts to Cloudflare Worker -> Ntfy push notifications
- **Crypto miner detection** - Detects suspicious CPU usage and mining pool connections

## Prerequisites

Before running this skill, ensure:
1. Cloudflare Worker is deployed (see `cloudflare-worker/` directory)
2. You have the Worker URL and shared secret
3. You have SSH access to target servers
4. Ntfy topic is configured in the Worker

## Instructions

When user invokes this skill, follow this interactive workflow:

### Step 1: Gather Information

Ask the user:
1. Which server(s) to harden (IP addresses or hostnames)
2. The Cloudflare Worker alert endpoint URL
3. The shared secret for authentication (or offer to generate one)
4. The server role (web, database, worker, utility) - this determines UFW rules

### Step 2: Verify Connectivity

Before making any changes:
```bash
ssh root@<server> "echo 'Connection successful' && uname -a"
```

Confirm the user has a second SSH session open or Hetzner console access available.

### Step 3: Deploy Alerting Infrastructure (Ask Permission)

**What this does:**
- Creates `/opt/server-security/` directory structure
- Deploys alert scripts (send-alert.sh, heartbeat.sh, health-check.sh, miner-detect.sh)
- Creates config file with Worker URL and secret
- Tests alert delivery

**Commands to run:**
```bash
# Create directory structure
ssh root@<server> "mkdir -p /opt/server-security/{scripts,config,logs}"

# Copy scripts (use scp or cat heredoc)
# Copy config template and fill in values

# Make scripts executable
ssh root@<server> "chmod +x /opt/server-security/scripts/*.sh"

# Test alert
ssh root@<server> "/opt/server-security/scripts/send-alert.sh test 'Hardening started' low"
```

### Step 4: Install Base Security Tools (Ask Permission)

**What this does:**
- Updates package list
- Installs fail2ban, ufw, auditd, rkhunter, unattended-upgrades

**Commands:**
```bash
ssh root@<server> "apt update && apt install -y fail2ban ufw auditd audispd-plugins rkhunter unattended-upgrades"
```

### Step 5: Configure SSH Hardening (Ask Permission)

**What this does:**
- Backs up current sshd_config
- Disables password authentication (keys only)
- Disables root password login (keys still work)
- Sets other security options

**CRITICAL: Verify user has key-based access working before this step!**

**Commands:**
```bash
# Backup
ssh root@<server> "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)"

# Apply hardening (show exact changes to user first)
ssh root@<server> "cat /etc/ssh/sshd_config"  # Show current config

# Changes to make:
# PasswordAuthentication no
# PermitRootLogin prohibit-password
# PubkeyAuthentication yes
# PermitEmptyPasswords no
# X11Forwarding no
# MaxAuthTries 3

# Restart SSH (user should have second session ready!)
ssh root@<server> "systemctl restart sshd"
```

### Step 6: Configure UFW Firewall (Ask Permission)

**Rules depend on server role:**

| Role | Ports |
|------|-------|
| All | 22 (SSH), 10.0.0.0/8 (private network) |
| Web | + 80, 443 |
| Database | + 5432, 6379 from 10.0.0.0/8 only |
| Worker | (no additional) |

**Commands:**
```bash
# Reset and set defaults
ssh root@<server> "ufw --force reset && ufw default deny incoming && ufw default allow outgoing"

# Allow SSH (CRITICAL - do this first!)
ssh root@<server> "ufw allow 22/tcp"

# Allow private network
ssh root@<server> "ufw allow from 10.0.0.0/8"

# Role-specific rules
# For web servers:
ssh root@<server> "ufw allow 80/tcp && ufw allow 443/tcp"

# For database (private network only):
ssh root@<server> "ufw allow from 10.0.0.0/8 to any port 5432"
ssh root@<server> "ufw allow from 10.0.0.0/8 to any port 6379"

# Enable (with confirmation)
ssh root@<server> "ufw --force enable"

# Verify
ssh root@<server> "ufw status verbose"
```

### Step 7: Configure fail2ban (Ask Permission)

**What this does:**
- Deploys jail.local config for SSH protection
- Deploys custom action to send alerts on ban
- Enables and starts fail2ban

**Commands:**
```bash
# Copy jail.local
# Copy security-alert.local action

ssh root@<server> "systemctl enable fail2ban && systemctl restart fail2ban"

# Verify
ssh root@<server> "fail2ban-client status sshd"
```

### Step 8: Configure auditd (Ask Permission)

**What this does:**
- Deploys rules to monitor: /etc/passwd, /etc/shadow, /etc/sudoers, SSH config, cron
- Enables and starts auditd

**Commands:**
```bash
# Copy security.rules to /etc/audit/rules.d/

ssh root@<server> "systemctl enable auditd && systemctl restart auditd"

# Verify
ssh root@<server> "auditctl -l"
```

### Step 9: Configure Unattended Upgrades (Ask Permission)

**What this does:**
- Enables automatic security updates
- Configures email notifications (optional)
- Sets auto-reboot to false (manual reboots preferred)

**Commands:**
```bash
# Copy 50unattended-upgrades to /etc/apt/apt.conf.d/

ssh root@<server> "dpkg-reconfigure -plow unattended-upgrades"  # or use debconf-set-selections

# Verify
ssh root@<server> "cat /etc/apt/apt.conf.d/20auto-upgrades"
```

### Step 10: Configure rkhunter (Ask Permission)

**What this does:**
- Updates rkhunter database
- Sets up weekly scan with alerting

**Commands:**
```bash
ssh root@<server> "rkhunter --update && rkhunter --propupd"

# Weekly scan is handled by cron in next step
```

### Step 11: Configure Process Whitelist (Ask Permission)

**What this does:**
- Deploys process whitelist for miner detection
- Customizes based on server role

Ask the user if they have additional processes that legitimately use high CPU on this server.

**Default whitelist:**
- ruby, rails, puma, sidekiq (Rails apps)
- postgres, redis-server (databases)
- node, python, python3 (other apps)
- docker, containerd, kamal (containers)
- nginx, caddy (web servers)

### Step 12: Setup Cron Jobs (Ask Permission)

**What this does:**
- Heartbeat every 5 minutes
- Health check every 15 minutes
- Miner detection every 5 minutes
- rkhunter weekly scan (Sunday 3 AM)

**Commands:**
```bash
# Deploy cron file to /etc/cron.d/server-security
ssh root@<server> "cat > /etc/cron.d/server-security << 'EOF'
# Server Security Monitoring
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Heartbeat every 5 minutes
*/5 * * * * root /opt/server-security/scripts/heartbeat.sh >> /opt/server-security/logs/heartbeat.log 2>&1

# Health check every 15 minutes
*/15 * * * * root /opt/server-security/scripts/health-check.sh >> /opt/server-security/logs/health-check.log 2>&1

# Miner detection every 5 minutes
*/5 * * * * root /opt/server-security/scripts/miner-detect.sh >> /opt/server-security/logs/miner-detect.log 2>&1

# Weekly rkhunter scan (Sunday 3 AM)
0 3 * * 0 root /opt/server-security/scripts/rkhunter-scan.sh >> /opt/server-security/logs/rkhunter.log 2>&1
EOF"

# Verify
ssh root@<server> "cat /etc/cron.d/server-security"
```

### Step 13: Final Verification

Run through this checklist:

```bash
# SSH still works
ssh root@<server> "echo 'SSH OK'"

# UFW enabled
ssh root@<server> "ufw status | head -1"

# fail2ban running
ssh root@<server> "systemctl is-active fail2ban"

# Test alert delivery
ssh root@<server> "/opt/server-security/scripts/send-alert.sh test 'Hardening complete' low"

# Check heartbeat
ssh root@<server> "/opt/server-security/scripts/heartbeat.sh"

# Check health
ssh root@<server> "/opt/server-security/scripts/health-check.sh"

# auditd rules loaded
ssh root@<server> "auditctl -l | wc -l"

# Cron installed
ssh root@<server> "ls -la /etc/cron.d/server-security"
```

### Step 14: Document Completion

Record in conversation:
- Server IP
- Role
- Date hardened
- Any customizations made
- Any issues encountered

## Rollback Commands

If something breaks, provide these to the user:

```bash
# Restore SSH config
ssh root@<server> "cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config && systemctl restart sshd"

# Disable firewall
ssh root@<server> "ufw disable"

# Stop security services
ssh root@<server> "systemctl stop fail2ban auditd"

# Remove cron
ssh root@<server> "rm /etc/cron.d/server-security"
```

## Files in This Skill

- `scripts/send-alert.sh` - Send alerts to CF Worker
- `scripts/heartbeat.sh` - Send heartbeat with metrics
- `scripts/health-check.sh` - Check disk/memory/load
- `scripts/miner-detect.sh` - Detect crypto miners
- `scripts/rkhunter-scan.sh` - Run rkhunter and alert
- `config/alert.conf.template` - Alert configuration template
- `config/process-whitelist.txt` - Allowed high-CPU processes
- `config/jail.local` - fail2ban configuration
- `config/security-alert.local` - fail2ban alert action
- `config/security.rules` - auditd rules
- `config/50unattended-upgrades` - Auto-update config
- `cloudflare-worker/worker.js` - Alert hub Worker code
- `cloudflare-worker/wrangler.toml` - Worker deployment config
