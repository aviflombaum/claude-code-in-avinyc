# Changelog

## 1.3.0

### Added
- `guard-qmd-bash.sh` — PreToolUse hook on Bash that blocks direct `qmd` CLI commands, enforcing wrapper script usage
- Hook self-discovers plugin root via `BASH_SOURCE` and provides actual resolved script paths in block messages
- Hard enforcement: LLM cannot bypass wrapper scripts even if it ignores SKILL.md instructions

### Changed
- Tightened Doctor Mode and Status Mode instructions — explicit "run this ONE command, nothing else"
- STRICT RULES section now references hook enforcement
- Hook allows diagnostic commands (`qmd --version`, `qmd --help`, `which qmd`, `command -v qmd`)
- README reorganized hooks into dedicated section (Bash Guard, Directory Guard, Git Hook)

## 1.2.0

### Changed
- Split overloaded `/qmd:search` into explicit commands: `/qmd:configure`, `/qmd:status`, `/qmd:doctor`
- `/qmd:search` is now search-only — directs to `/qmd:configure` if not set up
- Setup and reconfigure collapsed into single idempotent `/qmd:configure` command
- Updated doctor script remediation messages to reference new commands

## 1.1.0

### Breaking Changes
- Dropped `--index <name>` — all operations use the default qmd index
- `.claude/qmd.json` field renamed: `"index"` → `"project"`
- `install-git-hook.sh` arg is now project name (for marker only), not index name

### Added
- `qmd-add-collection.sh` — wrapper for `qmd collection add` + `qmd context add`
- `qmd-remove-collection.sh` — wrapper for `qmd collection remove`
- `qmd-list-collections.sh` — wrapper for `qmd collection list`
- `qmd-search.sh` — BM25 search wrapper with correct flags
- `qmd-vsearch.sh` — semantic search wrapper with correct flags
- `qmd-index.sh` — wrapper for `qmd update` + `qmd embed`
- `qmd-status.sh` — wrapper for `qmd status`
- `qmd-derive-name.sh` — deterministic project name derivation from git folder
- `qmd-doctor.sh` — 13-point health check (config, collections, hooks, naming)
- Doctor mode via `/qmd:search doctor`

### Changed
- All qmd operations go through bash wrapper scripts (never called directly)
- Setup uses `qmd collection add` CLI instead of writing YAML manually
- Git hook uses default index (no `--index` flag), cleans up old v1.0 markers
- Collection naming is script-derived (`{project}_{type}`), user can override project name

## 1.0.0

- Initial release in claude-code-in-avinyc marketplace
- Per-project setup interview for qmd configuration
- Smart search across collections
- Guard hooks for qmd-first workflow
