---
name: avinyc:warp-bootstrap
description: Bootstrap Warp terminal configuration for Rails projects. Creates launch configurations with colored tabs for dev server, Claude, shell, and more. This skill should be used when setting up Warp for a Rails project. Triggers on "setup warp", "configure warp", "warp rails", "warp bootstrap", "terminal setup for rails", "warp-rails".
argument-hint: "[project-path]"
user-invocable: true
disable-model-invocation: true
---

# Warp Rails Bootstrap

Configure Warp terminal for optimal Rails development with colored tabs.

## Critical Rules

**READ THESE FIRST. VIOLATIONS WILL BREAK THE CONFIG.**

1. **MUST use AskUserQuestion** - Do NOT generate the config until user selects their tabs
2. **MUST use `bin/dev`** - If `bin/dev` exists, use it. Do NOT parse Procfile.dev for individual commands
3. **MUST use lowercase color names** - Only valid: `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`
4. **MUST use `exec:` for commands** - Format: `- exec: bin/dev` NOT `- "bin/dev"`
5. **MUST use absolute paths** - Never use `~` or relative paths in `cwd` field
6. **MUST start YAML with `---`** - The document separator is required
7. **MUST read reference docs** - Before generating YAML, read @./references/launch-config-schema.md

## Workflow

Execute these steps IN ORDER. Do not skip steps.

### Step 1: Verify Rails Project

Run this command:
```bash
test -f config/application.rb && echo "RAILS PROJECT" || echo "NOT RAILS"
```

If NOT RAILS, stop and tell user to run from a Rails directory.

### Step 2: Gather Project Context

Run these commands and store the results:

```bash
# Get absolute path (REQUIRED for cwd)
pwd

# Get project name from directory
basename "$(pwd)"

# Check for bin/dev
test -f bin/dev && echo "HAS_BIN_DEV=true" || echo "HAS_BIN_DEV=false"

# Check for background job processor
grep -l "sidekiq\|good_job\|solid_queue" Gemfile 2>/dev/null && echo "HAS_JOBS=true" || echo "HAS_JOBS=false"
```

**IMPORTANT:**
- If `HAS_BIN_DEV=true`, the dev command is `bin/dev`. Period. Do NOT look inside Procfile.dev.
- If `HAS_BIN_DEV=false`, the dev command is `bin/rails server`.

### Step 3: STOP - Ask Tab Configuration

**You MUST use AskUserQuestion here. Do NOT proceed until user responds.**

Ask: "Which tabs do you want in your Warp launch configuration?"

Use multi-select with these options:

| Label | Description |
|-------|-------------|
| Server (green) | Run dev server (bin/dev or rails server) |
| Claude (blue) | Start Claude Code session |
| Shell (yellow) | Empty terminal for commands |
| Console (magenta) | Rails console |
| Logs (cyan) | Tail log/development.log |

If HAS_JOBS=true, also include:
| Jobs (red) | Background job processor |

**WAIT FOR USER RESPONSE BEFORE CONTINUING.**

### Step 4: Read Reference Documentation

**Before writing ANY YAML, read the schema reference:**

Read @./references/launch-config-schema.md

This ensures you use the correct format.

### Step 5: Generate Launch Configuration

Create the launch configuration file.

**File location:** `~/.warp/launch_configurations/{project-name}.yaml`

**EXACT FORMAT TO USE:**

```yaml
---
name: {project-name}
windows:
  - tabs:
      - title: Server
        color: green
        layout:
          cwd: {ABSOLUTE_PATH_FROM_PWD}
          commands:
            - exec: bin/dev
      - title: Claude
        color: blue
        layout:
          cwd: {ABSOLUTE_PATH_FROM_PWD}
          commands:
            - exec: claude
      - title: Shell
        color: yellow
        layout:
          cwd: {ABSOLUTE_PATH_FROM_PWD}
```

**FORMAT RULES:**
- File MUST start with `---` (YAML document separator)
- `color` MUST be lowercase: `green`, `blue`, `yellow`, `magenta`, `cyan`, `red`
- `color` MUST NOT be capitalized or an object with r/g/b values
- `commands` MUST use `exec:` prefix: `- exec: bin/dev`
- `commands` MUST NOT be plain strings like `- "bin/dev"`
- `cwd` MUST be the absolute path from `pwd` command (no quotes needed)
- `cwd` MUST NOT use `~` or relative paths

### Step 6: Display Summary

Show the user what was created:

```
Warp launch configuration created for {project-name}!

Location: ~/.warp/launch_configurations/{project-name}.yaml

How to use:
  Keyboard:     Ctrl-Cmd-L → select "{project-name}"
  Direct URL:   warp://launch/{project-name}.yaml

Tabs configured:
  {list each tab with color and command}
```

## Common Mistakes to Avoid

| Wrong | Right |
|-------|-------|
| `color: Green` | `color: green` |
| `color: { r: 34, g: 197, b: 94 }` | `color: green` |
| `commands: ["bin/dev"]` | `commands: [- exec: bin/dev]` |
| `cwd: ~/project` | `cwd: /Users/avi/project` |
| `cwd: .` | `cwd: /Users/avi/project` |
| Missing `---` at start | Start file with `---` |
| Parsing Procfile.dev for commands | Just use `bin/dev` |
| Skipping AskUserQuestion | MUST ask and wait for response |

## Reference Files

- @./references/launch-config-schema.md - Launch configuration YAML format
