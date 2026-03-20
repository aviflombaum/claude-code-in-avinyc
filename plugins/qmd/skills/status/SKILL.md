---
name: avinyc:qmd-status
description: Show qmd configuration and index status for this project. Triggers on "qmd status", "show qmd config", "qmd collections".
user-invocable: true
allowed-tools: ["Bash", "Read", "mcp__qmd__status"]
---

# QMD Status

Show the project's qmd configuration alongside live index health.

## Step 1: Read project config

Read `.claude/qmd.json`. If missing, tell the user:

> qmd is not configured for this project. Run `/avinyc:qmd-configure` to set it up.

Print a summary:
- Project name
- Collections (name, path, description for each)
- Git hook: installed/not installed

## Step 2: Get live index status

Try `mcp__qmd__status` first (fastest, returns structured data). If MCP is unavailable, fall back to CLI:

```bash
qmd status
```

Display the live status alongside the project config. Key things to highlight:
- Total documents indexed per collection
- Embedding status (how many chunks have vectors)
- Any collections in config that are missing from the index
- Model info (which embedding/reranker models are loaded)

## Step 3: MCP connectivity

Report whether MCP tools are available. If not, suggest:

> MCP server not configured. Add `"mcpServers": {"qmd": {"command": "qmd", "args": ["mcp"]}}` to your Claude Code settings for faster searches.
