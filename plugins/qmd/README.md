# qmd Plugin

Semantic search for any project's documentation using qmd's MCP tools. Interviews you on first use, configures collections in the default qmd index, and provides fast MCP-powered search from that point forward.

## Prerequisites

- [qmd](https://github.com/tobi/qmd) 2.0+ installed (`npm install -g @tobilu/qmd`)
- qmd MCP server configured in Claude Code settings (recommended for best performance)

## Installation

Enable `qmd@claude-code-in-avinyc` in your Claude Code settings.

## Skills

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| search | `/avinyc:qmd-search <query>` | Search indexed collections via MCP |
| configure | `/avinyc:qmd-configure` | Set up or reconfigure qmd for this project |
| status | `/avinyc:qmd-status` | Show project config and index status |
| doctor | `/avinyc:qmd-doctor` | Run health check |

All skills are both user-invocable and model-invocable.

### Configure (first run)

```
/avinyc:qmd-configure
```

Interactive interview that:
1. Checks qmd is installed and MCP server is configured
2. Derives project name from git folder (user can override)
3. Detects indexable directories (`docs/`, `plans/`, `tasks/`, etc.)
4. Asks which to index and what each contains
5. Adds collections to the default qmd index
6. Writes `.claude/qmd.json` with project config
7. Generates embeddings
8. Optionally installs git post-commit hook for auto-reindex

Idempotent — run again to reconfigure.

### Search

```
/avinyc:qmd-search how does authentication work
/avinyc:qmd-search deployment configuration
```

Uses qmd's MCP tools with structured queries (lex + vec + hyde) for best results. The skill reads your project config to target the right collection, constructs multi-type queries with intent disambiguation, and retrieves documents via MCP `get`/`multi_get`.

Falls back to CLI if MCP is unavailable.

### Status

```
/avinyc:qmd-status
```

Shows project config alongside live index health via MCP.

### Doctor

```
/avinyc:qmd-doctor
```

Runs checks for: qmd binary, config validity, collection existence, naming conventions, git hook state, YAML/SQLite sync, and MCP server connectivity.

## Config Format

Per-project config at `.claude/qmd.json`:

```json
{
  "project": "myproject",
  "collections": {
    "myproject_docs": { "path": "docs", "pattern": "**/*.md", "description": "Project docs" },
    "myproject_plans": { "path": "plans", "pattern": "**/*.md", "description": "Implementation plans" }
  },
  "gitHook": true
}
```

Collection naming convention: `{project}_{type}` with underscores. All collections live in the default qmd index (`~/.cache/qmd/index.sqlite`).

## MCP Setup

For best performance, configure qmd's MCP server in your Claude Code settings:

```json
{
  "mcpServers": {
    "qmd": { "command": "qmd", "args": ["mcp"] }
  }
}
```

The MCP server keeps qmd's GGUF models (~3GB) warm between queries, making subsequent searches significantly faster than CLI cold-starts.

## Git Post-Commit Hook

When enabled via `/avinyc:qmd-configure`, auto-runs `qmd update && qmd embed` in the background on commits that touch `.md` files.

## Scripts

Utility scripts in `scripts/` used by configure and doctor:

| Script | Purpose |
|--------|---------|
| `install-git-hook.sh` | Git post-commit hook installer |
| `qmd-add-collection.sh` | `qmd collection add` + `qmd context add` |
| `qmd-remove-collection.sh` | `qmd collection remove` |
| `qmd-list-collections.sh` | `qmd collection list` |
| `qmd-index.sh` | `qmd update` + `qmd embed` |
| `qmd-derive-name.sh` | Project name from git folder |
