# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Claude Code plugin marketplace for Ruby and Rails development. It hosts plugins that extend Claude Code with specialized capabilities for Rails developers.

## Repository Structure

```
.claude-plugin/marketplace.json  # Marketplace manifest listing all plugins
plugins/                         # Individual plugin packages
  rspec-writer/                  # RSpec test generation plugin
    .claude-plugin/plugin.json   # Plugin manifest
    skills/write-test/           # Main skill for the plugin
      SKILL.md                   # Skill definition and instructions
      patterns/                  # Detailed testing patterns by spec type
```

## Plugin Architecture

### Marketplace Manifest
`.claude-plugin/marketplace.json` defines the marketplace metadata and lists available plugins with their source paths.

### Plugin Structure
Each plugin in `plugins/` contains:
- `.claude-plugin/plugin.json` - Plugin manifest with name, description, version
- `skills/` - Skill definitions with SKILL.md files containing frontmatter and instructions
- `patterns/` or other resources - Supporting documentation for the skill

### Skill Definition Format
Skills use YAML frontmatter followed by markdown instructions:
```yaml
---
name: skill-name
description: When to trigger this skill
argument-hint: "[optional args]"
user-invocable: true
---
```

## Current Plugins

### rspec-writer
Generates RSpec tests for Rails applications. Key conventions:
- Uses fixtures, not factories
- Modern `expect().to` syntax only
- Runs with `--fail-fast` flag
- Pattern files in `patterns/` for each spec type (model, request, system, job, mailer, channel, storage)

## Adding New Plugins

1. Create `plugins/<plugin-name>/.claude-plugin/plugin.json`
2. Add skill(s) under `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`
3. Register plugin in `.claude-plugin/marketplace.json`

## Installation Commands

```bash
# Add this marketplace to Claude Code
/plugin marketplace add aviflombaum/claude-code-in-avinyc

# Install a specific plugin
/plugin install rspec-writer@claude-code-in-avinyc
```
