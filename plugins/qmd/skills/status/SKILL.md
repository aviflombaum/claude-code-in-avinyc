---
name: avinyc:qmd-status
description: Show qmd configuration and index status for this project. Triggers on "qmd status", "show qmd config", "qmd collections".
user-invocable: true
allowed-tools: ["Bash", "Read", "mcp__qmd__status"]
---

# <span data-proof="authored" data-by="ai:claude">QMD Status</span>

<span data-proof="authored" data-by="ai:claude">Show the project's qmd configuration alongside live index health.</span>

## <span data-proof="authored" data-by="ai:claude">Step 1: Read project config</span>

<span data-proof="authored" data-by="ai:claude">Read</span> <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`. If missing, tell the user:</span>

> <span data-proof="authored" data-by="ai:claude">qmd is not configured for this project. Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span> <span data-proof="authored" data-by="ai:claude">to set it up.</span>

<span data-proof="authored" data-by="ai:claude">Print a summary:</span>

* <span data-proof="authored" data-by="ai:claude">Project name</span>

* <span data-proof="authored" data-by="ai:claude">Collections (name, path, description for each)</span>

* <span data-proof="authored" data-by="ai:claude">Git hook: installed/not installed</span>

## <span data-proof="authored" data-by="ai:claude">Step 2: Get live index status</span>

<span data-proof="authored" data-by="ai:claude">Try</span> <span data-proof="authored" data-by="ai:claude">`mcp__qmd__status`</span> <span data-proof="authored" data-by="ai:claude">first (fastest, returns structured data). If MCP is unavailable, fall back to CLI:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MTAsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
qmd status
```

<span data-proof="authored" data-by="ai:claude">Display the live status alongside the project config. Key things to highlight:</span>

* <span data-proof="authored" data-by="ai:claude">Total documents indexed per collection</span>

* <span data-proof="authored" data-by="ai:claude">Embedding status (how many chunks have vectors)</span>

* <span data-proof="authored" data-by="ai:claude">Any collections in config that are missing from the index</span>

* <span data-proof="authored" data-by="ai:claude">Model info (which embedding/reranker models are loaded)</span>

## <span data-proof="authored" data-by="ai:claude">Step 3: MCP connectivity</span>

<span data-proof="authored" data-by="ai:claude">Report whether MCP tools are available. If not, suggest:</span>

> <span data-proof="authored" data-by="ai:claude">MCP server not configured. Add</span> <span data-proof="authored" data-by="ai:claude">`"mcpServers": {"qmd": {"command": "qmd", "args": ["mcp"]}}`</span> <span data-proof="authored" data-by="ai:claude">to your Claude Code settings for faster searches.</span>