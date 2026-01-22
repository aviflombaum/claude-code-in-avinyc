# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Overview

This is a Claude Code plugin marketplace for Ruby, Rails, and SaaS development. It contains 8 plugins with 11 skills that extend Claude Code with specialized capabilities.

## Repository Structure

```
.claude-plugin/
  marketplace.json           # Marketplace manifest (v1.1.0)

plugins/
  rspec-writer/              # RSpec test generation
    .claude-plugin/plugin.json
    skills/write-test/SKILL.md
    skills/write-test/patterns/   # Spec patterns by type

  rails-frontend/            # Hotwire + Tailwind
    .claude-plugin/plugin.json
    skills/hotwire/SKILL.md
    skills/tailwind/SKILL.md

  rails-expert/              # Ruby/Rails best practices
    .claude-plugin/plugin.json
    skills/rails/SKILL.md

  design-system/             # UI/UX design
    .claude-plugin/plugin.json
    skills/web-designer/SKILL.md
    skills/ux-ui/SKILL.md

  saas-metrics/              # Business metrics
    .claude-plugin/plugin.json
    skills/business/SKILL.md
    skills/marketing/SKILL.md

  tech-writer/               # Technical writing
    .claude-plugin/plugin.json
    skills/write/SKILL.md

  compound-analyzer/         # Automation analysis
    .claude-plugin/plugin.json
    skills/analyze/SKILL.md

  plan-interview/            # Plan refinement
    .claude-plugin/plugin.json
    skills/interview/SKILL.md
```

## Plugin Architecture

### Marketplace Manifest

`.claude-plugin/marketplace.json` defines:
- Marketplace name and owner
- Version (currently 1.1.0)
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

### Skill Definition

Skills use YAML frontmatter in `SKILL.md`:
```yaml
---
name: skill-name
description: When to trigger this skill (include trigger phrases)
argument-hint: "[optional args]"
user-invocable: true
---

# Skill Title

Instructions for the skill...
```

## Current Plugins Summary

| Plugin | Skills | Purpose |
|--------|--------|---------|
| rspec-writer | `/write-test` | Generate RSpec tests (fixtures, modern syntax) |
| rails-frontend | `/hotwire`, `/tailwind` | Turbo, Stimulus, Tailwind patterns |
| rails-expert | `/rails` | POODR and Refactoring Ruby principles |
| design-system | `/web-designer`, `/ux-ui` | Visual design and usability |
| saas-metrics | `/business`, `/marketing` | LTV, CAC, funnels, unit economics |
| tech-writer | `/write` | Blog posts, tutorials, documentation |
| compound-analyzer | `/analyze` | Identify automation opportunities |
| plan-interview | `/interview` | Socratic questioning for plans |

## Adding New Plugins

1. Create `plugins/<name>/.claude-plugin/plugin.json`
2. Add skills under `plugins/<name>/skills/<skill-name>/SKILL.md`
3. Register in `.claude-plugin/marketplace.json`
4. Update README.md with plugin documentation

## Key Conventions

- All plugins are MIT licensed
- Skills should include trigger phrases in descriptions
- Use `argument-hint` for skills that accept arguments
- Pattern files go in subdirectories under the skill
