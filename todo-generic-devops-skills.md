---
title: "Create generic open-source devops skills for community"
marketplace: claude-code-in-avinyc
status: pending
---

# Create generic open-source devops skills for community

Private Innovent devops skills currently live in the `innovent-ai-devops` marketplace. Generic, sanitized versions of these skills could benefit the broader Claude Code community by providing reusable devops automation patterns.

## Candidate patterns for open-source extraction

- **Server hardening** — Automated security hardening checklists and implementation for Linux servers (SSH config, firewall rules, fail2ban, unattended upgrades)
- **Multi-server audit** — Cross-server configuration consistency checks, drift detection, and compliance reporting
- **Service upgrade workflow** — Safe rolling upgrade procedures for production services with health checks, rollback triggers, and verification steps
- **Hetzner Cloud management** — Infrastructure provisioning and management for Hetzner Cloud (server creation, networking, firewall rules, snapshots)

## Approach

1. Identify which patterns from `innovent-ai-devops` are generic enough to open-source
2. Strip any Innovent-specific configuration, credentials references, or proprietary infrastructure details
3. Create new plugin(s) in this marketplace with sanitized, community-friendly versions
4. Ensure skills are parameterized so users can plug in their own server IPs, credentials paths, and provider details
