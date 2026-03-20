# <span data-proof="authored" data-by="ai:claude">Changelog</span>

## <span data-proof="authored" data-by="ai:claude">2.0.0</span>

### <span data-proof="authored" data-by="ai:claude">Breaking Changes</span>

* <span data-proof="authored" data-by="ai:claude">Search skill no longer forks a Haiku subagent — runs inline in the main thread</span>

* <span data-proof="authored" data-by="ai:claude">Search uses qmd MCP tools (`mcp__qmd__query`,</span> <span data-proof="authored" data-by="ai:claude">`mcp__qmd__get`,</span> <span data-proof="authored" data-by="ai:claude">`mcp__qmd__multi_get`) instead of CLI commands</span>

* <span data-proof="authored" data-by="ai:claude">Guard hooks removed entirely — no more directory interception</span>

* <span data-proof="authored" data-by="ai:claude">All skills now</span> <span data-proof="authored" data-by="ai:claude">`disable-model-invocation: true`</span> <span data-proof="authored" data-by="ai:claude">(user-invocable only)</span>

* <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`</span> <span data-proof="authored" data-by="ai:claude">schema simplified: removed</span> <span data-proof="authored" data-by="ai:claude">`guardedDirs`</span> <span data-proof="authored" data-by="ai:claude">and</span> <span data-proof="authored" data-by="ai:claude">`guard`</span> <span data-proof="authored" data-by="ai:claude">fields</span>

* <span data-proof="authored" data-by="ai:claude">Deleted scripts:</span> <span data-proof="authored" data-by="ai:claude">`qmd-search.sh`,</span> <span data-proof="authored" data-by="ai:claude">`qmd-vsearch.sh`,</span> <span data-proof="authored" data-by="ai:claude">`qmd-status.sh`</span>

* <span data-proof="authored" data-by="ai:claude">Deleted hooks:</span> <span data-proof="authored" data-by="ai:claude">`hooks.json`,</span> <span data-proof="authored" data-by="ai:claude">`guard-qmd-search.sh`</span>

### <span data-proof="authored" data-by="ai:claude">Added</span>

* <span data-proof="authored" data-by="ai:claude">Structured query support via MCP: lex + vec + hyde query types with intent disambiguation</span>

* <span data-proof="authored" data-by="ai:claude">`mcp__qmd__multi_get`</span> <span data-proof="authored" data-by="ai:claude">for batch document retrieval</span>

* <span data-proof="authored" data-by="ai:claude">MCP server configuration check in</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span>

* <span data-proof="authored" data-by="ai:claude">MCP connectivity check in</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-doctor`</span>

* <span data-proof="authored" data-by="ai:claude">CLI fallback when MCP is unavailable (`qmd query`</span> <span data-proof="authored" data-by="ai:claude">with structured multiline format)</span>

* <span data-proof="authored" data-by="ai:claude">Error handling with specific fix instructions for each failure mode</span>

### <span data-proof="authored" data-by="ai:claude">Changed</span>

* <span data-proof="authored" data-by="ai:claude">Search queries now constructed as structured JSON (multi-type with fusion weighting) instead of single CLI strings</span>

* <span data-proof="authored" data-by="ai:claude">Full model intelligence (Opus/Sonnet) applied to query construction instead of Haiku</span>

* <span data-proof="authored" data-by="ai:claude">Status skill uses</span> <span data-proof="authored" data-by="ai:claude">`mcp__qmd__status`</span> <span data-proof="authored" data-by="ai:claude">with CLI fallback</span>

* <span data-proof="authored" data-by="ai:claude">Doctor skill adds MCP health check, removes guard-related checks</span>

* <span data-proof="authored" data-by="ai:claude">Configure skill adds MCP server verification step</span>

### <span data-proof="authored" data-by="ai:claude">Why</span>

<span data-proof="authored" data-by="ai:claude">The main model (Opus/Sonnet) constructs significantly better structured queries than Haiku did with CLI strings. MCP keeps qmd's GGUF models warm between queries, eliminating ~3GB cold-start per invocation. Structured queries (lex+vec+hyde with intent) were impossible with the old CLI-per-command approach.</span>

## <span data-proof="authored" data-by="ai:claude">1.3.0</span>

### <span data-proof="authored" data-by="ai:claude">Added</span>

* <span data-proof="authored" data-by="ai:claude">`guard-qmd-bash.sh`</span> <span data-proof="authored" data-by="ai:claude">— PreToolUse hook on Bash that blocks direct</span> <span data-proof="authored" data-by="ai:claude">`qmd`</span> <span data-proof="authored" data-by="ai:claude">CLI commands, enforcing wrapper script usage</span>

* <span data-proof="authored" data-by="ai:claude">Hook self-discovers plugin root via</span> <span data-proof="authored" data-by="ai:claude">`BASH_SOURCE`</span> <span data-proof="authored" data-by="ai:claude">and provides actual resolved script paths in block messages</span>

* <span data-proof="authored" data-by="ai:claude">Hard enforcement: LLM cannot bypass wrapper scripts even if it ignores SKILL.md instructions</span>

### <span data-proof="authored" data-by="ai:claude">Changed</span>

* <span data-proof="authored" data-by="ai:claude">Tightened Doctor Mode and Status Mode instructions — explicit "run this ONE command, nothing else"</span>

* <span data-proof="authored" data-by="ai:claude">STRICT RULES section now references hook enforcement</span>

* <span data-proof="authored" data-by="ai:claude">Hook allows diagnostic commands (`qmd --version`,</span> <span data-proof="authored" data-by="ai:claude">`qmd --help`,</span> <span data-proof="authored" data-by="ai:claude">`which qmd`,</span> <span data-proof="authored" data-by="ai:claude">`command -v qmd`)</span>

* <span data-proof="authored" data-by="ai:claude">README reorganized hooks into dedicated section (Bash Guard, Directory Guard, Git Hook)</span>

## <span data-proof="authored" data-by="ai:claude">1.2.0</span>

### <span data-proof="authored" data-by="ai:claude">Changed</span>

* <span data-proof="authored" data-by="ai:claude">Split overloaded</span> <span data-proof="authored" data-by="ai:claude">`/qmd:search`</span> <span data-proof="authored" data-by="ai:claude">into explicit commands:</span> <span data-proof="authored" data-by="ai:claude">`/qmd:configure`,</span> <span data-proof="authored" data-by="ai:claude">`/qmd:status`,</span> <span data-proof="authored" data-by="ai:claude">`/qmd:doctor`</span>

* <span data-proof="authored" data-by="ai:claude">`/qmd:search`</span> <span data-proof="authored" data-by="ai:claude">is now search-only — directs to</span> <span data-proof="authored" data-by="ai:claude">`/qmd:configure`</span> <span data-proof="authored" data-by="ai:claude">if not set up</span>

* <span data-proof="authored" data-by="ai:claude">Setup and reconfigure collapsed into single idempotent</span> <span data-proof="authored" data-by="ai:claude">`/qmd:configure`</span> <span data-proof="authored" data-by="ai:claude">command</span>

* <span data-proof="authored" data-by="ai:claude">Updated doctor script remediation messages to reference new commands</span>

## <span data-proof="authored" data-by="ai:claude">1.1.0</span>

### <span data-proof="authored" data-by="ai:claude">Breaking Changes</span>

* <span data-proof="authored" data-by="ai:claude">Dropped</span> <span data-proof="authored" data-by="ai:claude">`--index <name>`</span> <span data-proof="authored" data-by="ai:claude">— all operations use the default qmd index</span>

* <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`</span> <span data-proof="authored" data-by="ai:claude">field renamed:</span> <span data-proof="authored" data-by="ai:claude">`"index"`</span> <span data-proof="authored" data-by="ai:claude">→</span> <span data-proof="authored" data-by="ai:claude">`"project"`</span>

* <span data-proof="authored" data-by="ai:claude">`install-git-hook.sh`</span> <span data-proof="authored" data-by="ai:claude">arg is now project name (for marker only), not index name</span>

### <span data-proof="authored" data-by="ai:claude">Added</span>

* <span data-proof="authored" data-by="ai:claude">Bash wrapper scripts for all qmd operations</span>

* <span data-proof="authored" data-by="ai:claude">Doctor mode health checks</span>

* <span data-proof="authored" data-by="ai:claude">`qmd-derive-name.sh`</span> <span data-proof="authored" data-by="ai:claude">— deterministic project name derivation</span>

### <span data-proof="authored" data-by="ai:claude">Changed</span>

* <span data-proof="authored" data-by="ai:claude">All qmd operations go through bash wrapper scripts (never called directly)</span>

* <span data-proof="authored" data-by="ai:claude">Setup uses</span> <span data-proof="authored" data-by="ai:claude">`qmd collection add`</span> <span data-proof="authored" data-by="ai:claude">CLI instead of writing YAML manually</span>

## <span data-proof="authored" data-by="ai:claude">1.0.0</span>

* <span data-proof="authored" data-by="ai:claude">Initial release in claude-code-in-avinyc marketplace</span>

* <span data-proof="authored" data-by="ai:claude">Per-project setup interview for qmd configuration</span>

* <span data-proof="authored" data-by="ai:claude">Smart search across collections</span>

* <span data-proof="authored" data-by="ai:claude">Guard hooks for qmd-first workflow</span>