# Changelog

## 2.0.0

### Breaking Changes

* Search skill no longer forks a Haiku subagent — runs inline in the main thread

* Search uses qmd MCP tools (`mcp__qmd__query`, `mcp__qmd__get`, `mcp__qmd__multi_get`) instead of CLI commands

* Guard hooks removed entirely — no more directory interception

* All skills now `disable-model-invocation: true` (user-invocable only)

* `.claude/qmd.json` schema simplified: removed `guardedDirs` and `guard` fields

* Deleted scripts: `qmd-search.sh`, `qmd-vsearch.sh`, `qmd-status.sh`

* Deleted hooks: `hooks.json`, `guard-qmd-search.sh`

### Added

* Structured query support via MCP: lex + vec + hyde query types with intent disambiguation

* `mcp__qmd__multi_get` for batch document retrieval

* MCP server configuration check in `/avinyc:qmd-configure`

* MCP connectivity check in `/avinyc:qmd-doctor`

* CLI fallback when MCP is unavailable (`qmd query` with structured multiline format)

* Error handling with specific fix instructions for each failure mode

### Changed

* Search queries now constructed as structured JSON (multi-type with fusion weighting) instead of single CLI strings

* Full model intelligence (Opus/Sonnet) applied to query construction instead of Haiku

* Status skill uses `mcp__qmd__status` with CLI fallback

* Doctor skill adds MCP health check, removes guard-related checks

* Configure skill adds MCP server verification step

### Why

The main model (Opus/Sonnet) constructs significantly better structured queries than Haiku did with CLI strings. MCP keeps qmd's GGUF models warm between queries, eliminating ~3GB cold-start per invocation. Structured queries (lex+vec+hyde with intent) were impossible with the old CLI-per-command approach.

## 1.3.0

### Added

* `guard-qmd-bash.sh` — PreToolUse hook on Bash that blocks direct `qmd` CLI commands, enforcing wrapper script usage

* Hook self-discovers plugin root via `BASH_SOURCE` and provides actual resolved script paths in block messages

* Hard enforcement: LLM cannot bypass wrapper scripts even if it ignores SKILL.md instructions

### Changed

* Tightened Doctor Mode and Status Mode instructions — explicit "run this ONE command, nothing else"

* STRICT RULES section now references hook enforcement

* Hook allows diagnostic commands (`qmd --version`, `qmd --help`, `which qmd`, `command -v qmd`)

* README reorganized hooks into dedicated section (Bash Guard, Directory Guard, Git Hook)

## 1.2.0

### Changed

* Split overloaded `/qmd:search` into explicit commands: `/qmd:configure`, `/qmd:status`, `/qmd:doctor`

* `/qmd:search` is now search-only — directs to `/qmd:configure` if not set up

* Setup and reconfigure collapsed into single idempotent `/qmd:configure` command

* Updated doctor script remediation messages to reference new commands

## 1.1.0

### Breaking Changes

* Dropped `--index <name>` — all operations use the default qmd index

* `.claude/qmd.json` field renamed: `"index"` → `"project"`

* `install-git-hook.sh` arg is now project name (for marker only), not index name

### Added

* Bash wrapper scripts for all qmd operations

* Doctor mode health checks

* `qmd-derive-name.sh` — deterministic project name derivation

### Changed

* All qmd operations go through bash wrapper scripts (never called directly)

* Setup uses `qmd collection add` CLI instead of writing YAML manually

## 1.0.0

* Initial release in claude-code-in-avinyc marketplace

* Per-project setup interview for qmd configuration

* Smart search across collections

* Guard hooks for qmd-first workflow