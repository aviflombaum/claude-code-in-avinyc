# qmd Plugin

Semantic search for any project's documentation. Interviews you on first use, configures collections in the default qmd index, and provides fast search from that point forward.

## Installation

Enable `qmd@claude-code-in-avinyc` in your Claude Code settings.

## Skills

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| search | `/qmd:search <query>` | Search indexed collections |
| configure | `/qmd:configure` | Set up or reconfigure qmd for this project |
| status | `/qmd:status` | Show project config and index status |
| doctor | `/qmd:doctor` | Run health check |

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

Three search modes: `qmd search` (BM25 keyword), `qmd vsearch` (vector/semantic), `qmd query` (auto-expand + rerank). The skill picks the right one for the query.

### Status

```
/qmd:status
```

### Doctor

```
/qmd:doctor
```

Runs checks for: qmd binary, config validity, collection existence, naming conventions, git hook state, guard config consistency, and YAML/SQLite sync.

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

## Hooks

### Directory Guard Hook

When enabled (`guard: true` in config), a PreToolUse hook on Glob/Grep/Task blocks searches on indexed directories and redirects to `/qmd:search`. This enforces a qmd-first workflow. Config-gated: zero overhead in unconfigured projects.

### Git Post-Commit Hook

When enabled via `/qmd:configure`, auto-runs `qmd update && qmd embed` in the background on commits that touch `.md` files.

## Scripts

Utility scripts in `scripts/` used by the doctor skill and configure flow:

| Script | Purpose |
|--------|---------|
| `qmd-doctor.sh` | Health check (called by doctor skill) |
| `install-git-hook.sh` | Git post-commit hook installer |
| `qmd-add-collection.sh` | `qmd collection add` + `qmd context add` |
| `qmd-remove-collection.sh` | `qmd collection remove` |
| `qmd-list-collections.sh` | `qmd collection list` |
| `qmd-search.sh` | BM25 search with correct flags |
| `qmd-vsearch.sh` | Semantic search with correct flags |
| `qmd-index.sh` | `qmd update` + `qmd embed` |
| `qmd-status.sh` | `qmd status` |
| `qmd-derive-name.sh` | Project name from git folder |
