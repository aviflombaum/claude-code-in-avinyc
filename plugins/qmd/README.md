# qmd Plugin

Generic qmd semantic search for any project. Interviews you on first use, configures collections in the default qmd index, and provides fast search from that point forward. All qmd CLI operations go through bash wrapper scripts for consistency and debuggability.

## Installation

Enable `qmd@claude-code-in-avinyc` in your Claude Code settings.

## Commands

| Command | Purpose |
|---------|---------|
| `/qmd:configure` | Set up or reconfigure qmd for this project |
| `/qmd:search <query>` | Search indexed collections |
| `/qmd:status` | Show project config and index status |
| `/qmd:doctor` | Run 13-point health check |

### Configure (first run)

```
/qmd:configure
```

Interactive interview that:
1. Derives project name from git folder (user can override)
2. Detects indexable directories (`docs/`, `plans/`, `tasks/`, etc.)
3. Asks which to index and what each contains
4. Adds collections to the default qmd index via `qmd collection add`
5. Writes `.claude/qmd.json` with project config
6. Generates embeddings
7. Optionally installs guard hook and git post-commit hook

Idempotent — run again to reconfigure.

### Search

```
/qmd:search how does authentication work
/qmd:search deployment configuration
```

### Status

```
/qmd:status
```

### Doctor

```
/qmd:doctor
```

Runs 13 checks: qmd binary, config validity, collection existence, naming conventions, git hook state, guard config consistency, and YAML/SQLite sync.

## Config Format

Per-project config at `.claude/qmd.json`:

```json
{
  "project": "myproject",
  "collections": {
    "myproject_docs": { "path": "docs", "pattern": "**/*.md", "description": "Project docs" },
    "myproject_plans": { "path": "plans", "pattern": "**/*.md", "description": "Implementation plans" }
  },
  "guardedDirs": ["docs", "plans"],
  "guard": true,
  "gitHook": true
}
```

Collection naming convention: `{project}_{type}` with underscores. All collections live in the default qmd index (`~/.cache/qmd/index.sqlite`).

## Scripts

All qmd CLI access goes through thin bash wrappers in `scripts/`:

| Script | Wraps |
|--------|-------|
| `qmd-add-collection.sh` | `qmd collection add` + `qmd context add` |
| `qmd-remove-collection.sh` | `qmd collection remove` |
| `qmd-list-collections.sh` | `qmd collection list` |
| `qmd-search.sh` | `qmd search` (with `--json -c -n`) |
| `qmd-vsearch.sh` | `qmd vsearch` (with `--json -c -n`) |
| `qmd-index.sh` | `qmd update` + `qmd embed` |
| `qmd-status.sh` | `qmd status` |
| `qmd-derive-name.sh` | Project name from git folder |
| `qmd-doctor.sh` | 13-point health check |
| `install-git-hook.sh` | Git post-commit hook |

## Hooks

### Bash Guard Hook

A PreToolUse hook on `Bash` blocks direct `qmd` CLI commands and requires wrapper scripts. This prevents the LLM from bypassing the scripts and calling `qmd` directly. Only active when `.claude/qmd.json` exists. Allows `command -v qmd` (install check) and any command going through `scripts/`.

### Directory Guard Hook

When enabled (`guard: true` in config), blocks Glob/Grep on indexed directories and redirects to `/qmd:search`. Config-gated: zero overhead in unconfigured projects.

### Git Post-Commit Hook

When enabled, auto-runs `qmd update && qmd embed` in the background on commits that touch `.md` files. Uses the default index (no `--index` flag).
