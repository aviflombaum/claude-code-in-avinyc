# Agent Skills for Ruby & Rails

A curated collection of AI agent skills for Ruby, Rails, and SaaS development.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Plugins](https://img.shields.io/badge/plugins-9-brightgreen.svg)](#available-plugins)
[![Skills](https://img.shields.io/badge/skills-15-green.svg)](#available-plugins)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-compatible-blueviolet.svg)](https://agentskills.io)

---

## Quick Start

### Any Agent (Cursor, OpenAI Codex, Gemini CLI, etc.)

```bash
npx add-skill aviflombaum/claude-code-in-avinyc
```

### Claude Code

```bash
# Add marketplace and install all plugins
/plugin marketplace add aviflombaum/claude-code-in-avinyc

# Or install individual plugins
/plugin install git-workflows@claude-code-in-avinyc
/plugin install design-system@claude-code-in-avinyc
/plugin install saas-metrics@claude-code-in-avinyc
/plugin install tech-writer@claude-code-in-avinyc
/plugin install compound-analyzer@claude-code-in-avinyc
/plugin install plan-interview@claude-code-in-avinyc
/plugin install qmd@claude-code-in-avinyc
/plugin install warp-rails@claude-code-in-avinyc
/plugin install monitor-config@claude-code-in-avinyc
```

---

## Available Plugins

### 🛤️ Development Tools

| Plugin | Skills | Description |
|--------|--------|-------------|
| [**git-workflows**](plugins/git-workflows/) | `/avinyc:commit`, `/avinyc:rails-worktree` | Git commits and worktrees |
| [**qmd**](plugins/qmd/) | `/avinyc:qmd-search`, `/avinyc:qmd-configure`, `/avinyc:qmd-doctor`, `/avinyc:qmd-status` | Semantic search for project docs |

### 🎨 Design & UX

| Plugin | Skills | Description |
|--------|--------|-------------|
| [**design-system**](plugins/design-system/) | `/avinyc:web-design`, `avinyc:ux-ui` (auto) | Visual design and usability |

### 📊 Business & Writing

| Plugin | Skills | Description |
|--------|--------|-------------|
| [**saas-metrics**](plugins/saas-metrics/) | `/avinyc:business`, `/avinyc:marketing` | LTV, CAC, funnels |
| [**tech-writer**](plugins/tech-writer/) | `/avinyc:write` | Blog posts and tutorials |

### ⚡ Productivity

| Plugin | Skills | Description |
|--------|--------|-------------|
| [**compound-analyzer**](plugins/compound-analyzer/) | `/avinyc:analyze` | Find automation opportunities |
| [**plan-interview**](plugins/plan-interview/) | `/avinyc:interview` | Socratic plan refinement |

### 🖥️ System & Terminal

| Plugin | Skills | Description |
|--------|--------|-------------|
| [**warp-rails**](plugins/warp-rails/) | `/avinyc:warp-bootstrap` | Bootstrap Warp terminal for Rails |
| [**monitor-config**](plugins/monitor-config/) | `/avinyc:monitor-config` | Optimize multi-monitor setups |

---

## Plugin Details

### git-workflows

Git commit assistant and worktree management for Rails projects.

```bash
# Create logical commits
/avinyc:commit

# Create an isolated worktree
/avinyc:rails-worktree feature-branch
```

**`/avinyc:commit`:** Analyzes git changes and creates logical, well-structured commits using conventional commit format.

**`/avinyc:rails-worktree`:** Creates git worktrees with automatic Rails credential symlinking (master.key, environment keys).

---

### qmd

Semantic search and management for project documentation using qmd.

```bash
# Search project docs
/avinyc:qmd-search how does authentication work

# Configure collections
/avinyc:qmd-configure

# Health check
/avinyc:qmd-doctor

# Show status
/avinyc:qmd-status
```

---

### design-system

UI/UX design expertise for building beautiful, usable interfaces.

```bash
# Design a landing page
/avinyc:web-design hero section for a SaaS product

# UX knowledge auto-triggers when discussing usability
"What's the best information architecture for a settings page?"
```

**`/avinyc:web-design`:** Visual hierarchy, typography, color theory, layout systems, design aesthetics (Bauhaus, Retro, Futuristic)

**`avinyc:ux-ui` (auto-triggered):** Usability principles, accessibility, interaction design, information architecture

---

### saas-metrics

SaaS business metrics for founders building products.

```bash
# Analyze unit economics
/avinyc:business calculate LTV:CAC ratio

# Model a marketing funnel
/avinyc:marketing ad spend to conversion analysis
```

**`/avinyc:business`:** LTV, CAC, MRR/ARR, churn analysis, payback period, Rule of 40

**`/avinyc:marketing`:** CPM, CPC, conversion funnels, landing page optimization, waitlist economics

---

### tech-writer

Write technical content with Flatiron School's engaging teaching style.

```bash
# Write a blog post
/avinyc:write blog "How to implement Action Cable"

# Create a tutorial
/avinyc:write tutorial "Building a Rails API"
```

**Style:** Technically unimpeachable yet refreshingly human. Strong opinions, loosely held. Clarity through progression.

---

### compound-analyzer

Identify automation and systematization opportunities in your development work.

```bash
# Analyze completed work
/avinyc:analyze

# Or describe what to review
"Analyze this feature for automation opportunities"
```

**Identifies:** Delegation opportunities, automation candidates, pattern extraction, workflow systematization

---

### plan-interview

Refine project plans through in-depth Socratic questioning.

```bash
# Interview about a plan
/avinyc:interview path/to/plan.md
```

**Questions cover:** Technical implementation, UI/UX considerations, edge cases, tradeoffs, assumptions

---

### warp-rails

Bootstrap Warp terminal configuration for Rails projects with colored tabs.

```bash
# Set up Warp for current project
/avinyc:warp-bootstrap
```

**Creates launch config with tabs:**
- Server (green) — `bin/dev` or `rails server`
- Claude (blue) — Claude Code session
- Shell (yellow) — Empty terminal
- Console (magenta) — Rails console
- Logs (cyan) — Tail development log
- Jobs (red) — Background processor (if detected)

**Auto-detects:** `bin/dev`, Sidekiq, GoodJob, SolidQueue

---

### monitor-config

Configure and optimize multi-monitor setups on macOS using displayplacer.

```bash
# Configure your monitors
/avinyc:monitor-config

# Or describe your setup
"Optimize my monitors for coding with a vertical display on the left"
```

**Interactive workflow:**
1. Discovers connected displays
2. Interviews about physical arrangement
3. Asks about use case (coding, media, gaming)
4. Recommends optimal resolutions and refresh rates
5. Applies configuration and saves reusable profiles

**Supports:** 4K displays, portrait/landscape orientation, 120Hz refresh rates, multi-monitor arrangements

---

## Local Development

Test plugin changes locally before pushing:

```bash
# One-time setup
./scripts/setup-local-dev.sh

# Verify configuration
./scripts/validate-settings.sh
./scripts/validate-versions.sh
```

This configures Claude Code to load plugins from your local directory instead of GitHub. See [AGENTS.md](AGENTS.md#local-development) for details.

---

## Contributing

1. Fork the repository
2. Run `./scripts/setup-local-dev.sh` to configure local testing
3. Create your plugin in `plugins/<plugin-name>/`
4. Add `.claude-plugin/plugin.json` manifest
5. Add skills under `skills/<skill-name>/SKILL.md`
6. Register in `.claude-plugin/marketplace.json`
7. **Bump version** with `./scripts/bump-version.sh <plugin-name> patch` (required for updates to propagate)
8. Submit a pull request

---

## License

MIT
