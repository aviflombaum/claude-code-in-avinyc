# qmd Plugin

Generic qmd semantic search for any project. Replaces per-project hardcoded qmd-search skills with a single plugin that interviews you on first use, configures collections, and provides smart search from that point forward.

## Installation

Enable `qmd@avi-ai` in your Claude Code settings.

## Usage

### First run (setup)

```
/qmd:search
```

Triggers an interactive interview:
1. Detects indexable directories (`docs/`, `plans/`, `tasks/`, etc.)
2. Asks which to index and what each contains
3. Creates `~/.config/qmd/<index>.yml` and `.claude/qmd.json`
4. Runs initial `qmd update && qmd embed`
5. Optionally installs guard hook and git post-commit hook

### Search

```
/qmd:search how does authentication work
/qmd:search deployment configuration
```

### Reconfigure

```
/qmd:search reconfigure
```

### Check status

```
/qmd:search status
```

## Config Format

Per-project config at `.claude/qmd.json`:

```json
{
  "index": "myproject",
  "collections": {
    "myproject_docs": { "path": "docs", "pattern": "**/*.md", "description": "Project docs" }
  },
  "guardedDirs": ["docs"],
  "guard": true,
  "gitHook": true
}
```

## Guard Hook

When enabled, blocks Glob/Grep on indexed directories and redirects to `/qmd:search`. Config-gated: zero overhead in unconfigured projects.

## Git Hook

When enabled, auto-runs `qmd update && qmd embed` in the background on commits that touch `.md` files.
