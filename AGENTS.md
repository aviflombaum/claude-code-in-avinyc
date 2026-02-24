# AGENTS.md

This file provides guidance to AI coding agents when working with this repository.

## Overview

This is an agent skills marketplace for Ruby, Rails, and SaaS development. It contains plugins with skills that extend AI coding agents with specialized capabilities.

## Installation

### For Any Agent (Cursor, OpenAI Codex, Gemini CLI, etc.)

```bash
npx add-skill aviflombaum/claude-code-in-avinyc
```

This installs all skills to your agent's skills directory.

### For Claude Code Specifically

```bash
# Via marketplace (recommended)
/plugin marketplace add aviflombaum/claude-code-in-avinyc

# Or install individual plugins
/plugin install rspec-writer@claude-code-in-avinyc
```

## Compatibility

This repo supports multiple agent platforms via the Agent Skills specification:

| File | Purpose |
|------|---------|
| `AGENTS.md` | Instructions for all agents (this file) |
| `CLAUDE.md` | Symlink to AGENTS.md for Claude Code |
| `skills/` | Flat skill directory for `npx add-skill` |
| `plugins/` | Claude Code plugin structure |

Skills are symlinked from `skills/` to `plugins/*/skills/*/` so both structures stay in sync.

## Repository Structure

```
AGENTS.md                    # Instructions for all agents (this file)
CLAUDE.md                    # Symlink -> AGENTS.md

skills/                      # Flat skill directory for npx add-skill
  analyze/                   # Symlink -> plugins/compound-analyzer/skills/analyze
  business/                  # Symlink -> plugins/saas-metrics/skills/business
  hotwire/                   # Symlink -> plugins/rails-frontend/skills/hotwire
  interview/                 # Symlink -> plugins/plan-interview/skills/interview
  marketing/                 # Symlink -> plugins/saas-metrics/skills/marketing
  rails/                     # Symlink -> plugins/rails-expert/skills/rails
  tailwind/                  # Symlink -> plugins/rails-frontend/skills/tailwind
  ux-ui/                     # Symlink -> plugins/design-system/skills/ux-ui
  web-design/                # Symlink -> plugins/design-system/skills/web-design
  write/                     # Symlink -> plugins/tech-writer/skills/write
  write-test/                # Symlink -> plugins/rspec-writer/skills/write-test

.claude/
  hooks.json                 # Claude Code hooks (version bump reminders)
  settings.local.json        # Local settings

.claude-plugin/
  marketplace.json           # Marketplace manifest

.github/
  workflows/
    validate-versions.yml    # CI check for version consistency

scripts/
  bump-version.sh            # Bump versions in both files
  setup-local-dev.sh         # Configure local development
  validate-settings.sh       # Validate settings.local.json
  validate-versions.sh       # Validate version consistency

plugins/
  rspec-writer/
    .claude-plugin/plugin.json
    skills/write-test/SKILL.md    # /rspec:write-test
    skills/write-test/patterns/   # Supporting reference files

  rails-frontend/
    .claude-plugin/plugin.json
    skills/hotwire/SKILL.md       # /rails-frontend:hotwire
    skills/tailwind/SKILL.md      # Auto-triggered (background knowledge)

  rails-expert/
    .claude-plugin/plugin.json
    skills/rails/SKILL.md         # Auto-triggered (background knowledge)

  design-system/
    .claude-plugin/plugin.json
    skills/web-design/SKILL.md    # /design-system:web-design
    skills/ux-ui/SKILL.md         # Auto-triggered (background knowledge)

  saas-metrics/
    .claude-plugin/plugin.json
    skills/business/SKILL.md      # /saas-metrics:business
    skills/marketing/SKILL.md     # /saas-metrics:marketing

  tech-writer/
    .claude-plugin/plugin.json
    skills/write/SKILL.md         # /tech-writer:write

  compound-analyzer/
    .claude-plugin/plugin.json
    skills/analyze/SKILL.md       # /compound-analyzer:analyze

  plan-interview/
    .claude-plugin/plugin.json
    skills/interview/SKILL.md     # /plan-interview:interview

  qmd/
    .claude-plugin/plugin.json
    skills/search/SKILL.md        # /qmd:search
    skills/configure/SKILL.md     # /qmd:configure
    skills/doctor/SKILL.md        # /qmd:doctor
    skills/status/SKILL.md        # /qmd:status
    hooks/hooks.json              # Guard hook for qmd-first workflow
    hooks/guard-qmd-search.sh
    scripts/                      # Utility scripts (doctor, git hook, etc.)
```

## Plugin Architecture

### Skills

Skills are the core building block. Each skill is a `SKILL.md` file inside `skills/<name>/`. Skills automatically:

- Appear in the `/` autocomplete menu (as `/plugin:skill-name`)
- Can be auto-triggered by Claude based on the `description` field
- Accept arguments via `$ARGUMENTS`

> **Note:** Claude Code previously supported a separate `commands/` directory for slash commands. This is now **legacy** — skills handle both discoverability and auto-triggering. Some plugins in this marketplace still have `commands/` wrappers from before this change; see `plans/deprecate-commands.md` for the migration plan.

### Skill Types

Skills fall into two categories based on their frontmatter:

| Type | Frontmatter | `/` menu | Auto-triggered | Example |
|------|-------------|----------|----------------|---------|
| **Action** | (defaults) | Yes | Yes | `write-test`, `search`, `analyze` |
| **Action (user-only)** | `disable-model-invocation: true` | Yes | No | Skills with side effects |
| **Background knowledge** | `user-invocable: false` | No | Yes | `rails`, `tailwind`, `ux-ui` |

### Skill Definition

Skills use YAML frontmatter in `SKILL.md`:

```yaml
---
name: skill-name
description: When to trigger this skill (include trigger phrases)
argument-hint: "[optional args]"
---

# Skill Title

Instructions for the skill...
```

**Supported frontmatter fields:**

| Field | Default | Description |
|-------|---------|-------------|
| `name` | directory name | Display name; becomes the `/slash-command`. Lowercase, hyphens, max 64 chars. |
| `description` | first paragraph | Used for auto-triggering and shown in autocomplete. Include trigger phrases. |
| `argument-hint` | none | Hint shown during autocomplete (e.g., `[issue-number]`) |
| `user-invocable` | `true` | Set `false` to hide from `/` menu (background knowledge only) |
| `disable-model-invocation` | `false` | Set `true` to prevent Claude from auto-triggering |
| `allowed-tools` | all tools | Restrict tool access (e.g., `["Read", "Grep", "Glob"]`) |
| `model` | current model | Force a specific model (e.g., `haiku`, `sonnet`) |
| `context` | none | Set `fork` to run in an isolated subagent |
| `agent` | none | Subagent type when `context: fork` (e.g., `Explore`) |

**String substitutions** available in skill content:
- `$ARGUMENTS` — all arguments passed when invoking
- `$ARGUMENTS[N]` or `$N` — positional arguments (0-indexed)
- `${CLAUDE_PLUGIN_ROOT}` — absolute path to the plugin root
- `` !`command` `` — shell command preprocessing

### Marketplace Manifest

`.claude-plugin/marketplace.json` defines:
- Marketplace name and owner
- Array of plugins with source paths and metadata

### Plugin Manifest

Each plugin has `.claude-plugin/plugin.json`:
```json
{
  "name": "plugin-name",
  "description": "What the plugin does",
  "version": "1.0.0",
  "author": { "name": "Avi Flombaum" },
  "keywords": ["relevant", "tags"]
}
```

Additional optional fields: `homepage`, `repository`, `license`, `commands`, `agents`, `skills`, `hooks`, `mcpServers`, `outputStyles`, `lspServers`.

## Current Plugins Summary

| Plugin | Skills | Purpose |
|--------|--------|---------|
| rspec-writer | write-test | Generate RSpec tests |
| rails-frontend | hotwire, tailwind* | Turbo, Stimulus, Tailwind |
| rails-expert | rails* | POODR and Refactoring Ruby |
| design-system | web-design, ux-ui* | Visual design and usability |
| saas-metrics | business, marketing | LTV, CAC, funnels |
| tech-writer | write | Blog posts, tutorials |
| compound-analyzer | analyze | Automation opportunities |
| plan-interview | interview | Socratic questioning |
| qmd | search, configure, doctor, status | Semantic search for project docs |

\* = background knowledge skill (`user-invocable: false`), auto-triggered only.

## Adding New Plugins

1. Create `plugins/<name>/.claude-plugin/plugin.json`
2. Add skills under `plugins/<name>/skills/<skill-name>/SKILL.md`
3. Register in `.claude-plugin/marketplace.json`
4. Add symlinks in `skills/` for cross-platform compatibility
5. Update this file and README.md

## Local Development

To test plugin changes locally before pushing:

### Quick Setup

```bash
./scripts/setup-local-dev.sh
```

This configures Claude Code to load plugins from your local directory instead of GitHub.

### What It Does

1. **Updates `~/.claude/plugins/known_marketplaces.json`** - Changes source from `github` to `directory` pointing to your local path
2. **Updates `.claude/settings.local.json`** - Enables all plugins from this marketplace

### Manual Setup

If you prefer to configure manually:

1. Edit `~/.claude/plugins/known_marketplaces.json`:
```json
"claude-code-in-avinyc": {
  "source": {
    "source": "directory",
    "path": "/path/to/claude-code-in-avinyc"
  },
  "installLocation": "/path/to/claude-code-in-avinyc"
}
```

2. Add plugins to `.claude/settings.local.json`:
```json
{
  "enabledPlugins": {
    "plugin-name@claude-code-in-avinyc": true
  }
}
```

### Validation (Local Only)

Check that all plugins are properly enabled in your local settings:
```bash
./scripts/validate-settings.sh  # Local dev only, not run in CI
```

For CI-style validation (runs in GitHub Actions):
```bash
./scripts/validate-versions.sh  # Version consistency check
```

### Switching Back to GitHub

To revert to loading from GitHub, change `known_marketplaces.json` source back to:
```json
"source": {
  "source": "github",
  "repo": "aviflombaum/claude-code-in-avinyc"
}
```

## Key Conventions

- All plugins are MIT licensed
- Skills should include trigger phrases in descriptions
- Use `argument-hint` for skills that accept arguments
- Pattern files go in subdirectories under the skill
- Background knowledge skills use `user-invocable: false`
- Action skills use defaults (visible in `/` menu + auto-triggered)

## Versioning

**Critical:** Claude Code detects updates by comparing `version` in each `plugin.json`, NOT the marketplace metadata version. If you don't bump plugin versions, updates won't propagate to users.

**When to bump versions:**
- Adding new skills
- Modifying skill instructions or behavior
- Changing plugin.json metadata
- Any change users should receive via auto-update

**Where versions live:**
- `plugin.json` - Required, triggers update detection
- `marketplace.json` plugins array - Should match plugin.json

### Version Bump Tooling

Three layers ensure version bumps never get forgotten:

**Layer 1: Claude Code Hook** - Real-time reminder when editing plugin files
- Configured in `.claude/hooks.json`
- Fires on Edit/Write to `plugins/**`
- Reminds to bump versions before you forget

**Layer 2: Bump Script** - Makes the correct action easy
```bash
./scripts/bump-version.sh <plugin-name> <bump-type>

# Examples:
./scripts/bump-version.sh rspec-writer patch   # 1.2.0 -> 1.2.1
./scripts/bump-version.sh design-system minor  # 1.2.0 -> 1.3.0
./scripts/bump-version.sh rails-expert major   # 1.1.0 -> 2.0.0
```
Updates both `plugin.json` and `marketplace.json` atomically.

**Layer 3: GitHub Actions CI** - Safety net on PRs
- Validates version consistency between `plugin.json` and `marketplace.json`
- Checks if plugin files changed without version bump
- Validates JSON syntax for all plugin manifests
- Verifies plugin structure (manifest + skills)
- Comments on PR with instructions if validation fails

### Version Workflow

1. Make changes to plugin content
2. Run `./scripts/bump-version.sh <plugin-name> patch`
3. Commit and push
4. CI validates on PR

## Plugin Change Checklist

When modifying plugins, ensure all related files are updated:

- [ ] Update skill content (skills/*/SKILL.md)
- [ ] Update plugin README.md with new examples
- [ ] Update main README.md tables and examples
- [ ] Update CLAUDE.md if conventions changed
- [ ] Run `./scripts/bump-version.sh <plugin-name> patch` (bumps both files)

Validate before pushing (mirrors CI checks):
```bash
./scripts/validate-versions.sh  # Version consistency
```
