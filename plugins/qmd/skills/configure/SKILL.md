---
name: avinyc:qmd-configure
description: Configure or reconfigure qmd collections for this project. Triggers on "configure qmd", "set up qmd", "reconfigure qmd", "qmd setup".
user-invocable: true
allowed-tools: ["Bash", "Read", "Write", "AskUserQuestion"]
---

# <span data-proof="authored" data-by="ai:claude">QMD Configure</span>

<span data-proof="authored" data-by="ai:claude">Interactive interview to set up or reconfigure qmd collections for a project. Idempotent: works for both first-time setup and reconfiguration.</span>

<span data-proof="authored" data-by="ai:claude">Run this flow step by step. Do NOT skip steps or assume answers.</span>

## <span data-proof="authored" data-by="ai:claude">Step 1: Check qmd is installed</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MTQsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
command -v qmd
```

<span data-proof="authored" data-by="ai:claude">If missing, tell the user:</span>

> <span data-proof="authored" data-by="ai:claude">qmd is not installed. Install it with:</span> <span data-proof="authored" data-by="ai:claude">`npm install -g @tobilu/qmd`</span>

<span data-proof="authored" data-by="ai:claude">Then STOP.</span>

## <span data-proof="authored" data-by="ai:claude">Step 2: Check qmd MCP server</span>

<span data-proof="authored" data-by="ai:claude">The search skill uses qmd's MCP tools for best performance (models stay warm between queries). Check if the MCP server is configured:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MjE3LCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
cat ~/.claude/settings.json 2>/dev/null | grep -q '"qmd"' && echo "found in global" || echo "not in global"
cat .claude/settings.local.json 2>/dev/null | grep -q '"qmd"' && echo "found in local" || echo "not in local"
```

<span data-proof="authored" data-by="ai:claude">If not configured in either location, tell the user:</span>

> <span data-proof="authored" data-by="ai:claude">qmd MCP server is not configured. Add it to your Claude Code settings for the best search experience.</span>
>
> <span data-proof="authored" data-by="ai:claude">Add this to</span> <span data-proof="authored" data-by="ai:claude">`~/.claude/settings.json`</span> <span data-proof="authored" data-by="ai:claude">(global) or</span> <span data-proof="authored" data-by="ai:claude">`.claude/settings.local.json`</span> <span data-proof="authored" data-by="ai:claude">(project):</span>
>
> ```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NzQsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
> {
>   "mcpServers": {
>     "qmd": { "command": "qmd", "args": ["mcp"] }
>   }
> }
> ```
>
> <span data-proof="authored" data-by="ai:claude">The search skill will fall back to CLI if MCP isn't available, but MCP is significantly faster for repeated queries.</span>

<span data-proof="authored" data-by="ai:claude">Continue with setup regardless — MCP is recommended but not required.</span>

## <span data-proof="authored" data-by="ai:claude">Step 3: Derive project name</span>

<span data-proof="authored" data-by="ai:claude">Get the git repo folder name and normalize it:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MTIzLCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
basename "$(git rev-parse --show-toplevel)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g; s/__*/_/g; s/^_//; s/_$//'
```

<span data-proof="authored" data-by="ai:claude">Show the derived name to the user via</span> <span data-proof="authored" data-by="ai:claude">`AskUserQuestion`. Let them confirm or type a custom name. Once confirmed, this is the canonical project name used for all collection prefixes.</span>

## <span data-proof="authored" data-by="ai:claude">Step 4: Scan for indexable directories</span>

<span data-proof="authored" data-by="ai:claude">Find directories containing markdown files:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NjksImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
find . -maxdepth 2 -type f -name "*.md" -exec dirname {} \; | sort -u
```

<span data-proof="authored" data-by="ai:claude">From the output, select only directories useful for a searchable document collection (docs/, plans/, tasks/, etc.). Ignore tmp/, vendor/, node_modules/, and other project cruft.</span>

## <span data-proof="authored" data-by="ai:claude">Step 5: Ask which directories to index</span>

<span data-proof="authored" data-by="ai:claude">Use</span> <span data-proof="authored" data-by="ai:claude">`AskUserQuestion`</span> <span data-proof="authored" data-by="ai:claude">with</span> <span data-proof="authored" data-by="ai:claude">`multiSelect: true`. List indexable directories as options. Explain that each directory becomes a qmd collection for fast semantic search.</span>

<span data-proof="authored" data-by="ai:claude">If no candidate directories were found, ask the user to type custom directory paths.</span>

## <span data-proof="authored" data-by="ai:claude">Step 6: Get collection details</span>

<span data-proof="authored" data-by="ai:claude">For each selected directory, use</span> <span data-proof="authored" data-by="ai:claude">`AskUserQuestion`</span> <span data-proof="authored" data-by="ai:claude">to:</span>

* <span data-proof="authored" data-by="ai:claude">Ask for a short description of what the directory contains (e.g., "Project architecture and feature docs")</span>

* <span data-proof="authored" data-by="ai:claude">Confirm the file pattern (default:</span> <span data-proof="authored" data-by="ai:claude">`**/*.md`, offer alternatives like</span> <span data-proof="authored" data-by="ai:claude">`**/*.{md,txt}`)</span>

## <span data-proof="authored" data-by="ai:claude">Step 7: Add collections</span>

<span data-proof="authored" data-by="ai:claude">For each selected directory, derive the collection name:</span> <span data-proof="authored" data-by="ai:claude">`{project}_{dirname}`</span> <span data-proof="authored" data-by="ai:claude">where dirname has</span> <span data-proof="authored" data-by="ai:claude">`/`</span> <span data-proof="authored" data-by="ai:claude">and</span> <span data-proof="authored" data-by="ai:claude">`.`</span> <span data-proof="authored" data-by="ai:claude">replaced with</span> <span data-proof="authored" data-by="ai:claude">`_`</span> <span data-proof="authored" data-by="ai:claude">and leading dots stripped. Example:</span> <span data-proof="authored" data-by="ai:claude">`.cursor/rules`</span> <span data-proof="authored" data-by="ai:claude">→</span> <span data-proof="authored" data-by="ai:claude">`cursor_rules`, so collection is</span> <span data-proof="authored" data-by="ai:claude">`myproject_cursor_rules`.</span>

<span data-proof="authored" data-by="ai:claude">Get the absolute path to the directory:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NDksImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
echo "$(git rev-parse --show-toplevel)/<dirname>"
```

<span data-proof="authored" data-by="ai:claude">Then add the collection:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MTQxLCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
qmd collection add "<absolute_path>" --name "<collection_name>" --mask "<pattern>"
qmd context add "qmd://<collection_name>/" "<description>"
```

<span data-proof="authored" data-by="ai:claude">If</span> <span data-proof="authored" data-by="ai:claude">`qmd collection add`</span> <span data-proof="authored" data-by="ai:claude">fails (collection already exists), ask the user whether to overwrite. If yes:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MTgzLCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
qmd collection remove "<collection_name>"
qmd collection add "<absolute_path>" --name "<collection_name>" --mask "<pattern>"
qmd context add "qmd://<collection_name>/" "<description>"
```

## <span data-proof="authored" data-by="ai:claude">Step 8: Write project config</span>

<span data-proof="authored" data-by="ai:claude">Use the Write tool to create</span> <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`:</span>

```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MjI4LCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
{
  "project": "<project_name>",
  "collections": {
    "<project>_<dirname>": {
      "path": "<relative-dir-path>",
      "pattern": "**/*.md",
      "description": "<user-provided description>"
    }
  },
  "gitHook": false
}
```

## <span data-proof="authored" data-by="ai:claude">Step 9: Generate embeddings</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MjMsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
qmd update && qmd embed
```

<span data-proof="authored" data-by="ai:claude">Tell the user it's generating embeddings. This may take a moment for large collections.</span>

## <span data-proof="authored" data-by="ai:claude">Step 10: Ask about git post-commit hook</span>

<span data-proof="authored" data-by="ai:claude">Use</span> <span data-proof="authored" data-by="ai:claude">`AskUserQuestion`: "Install a git post-commit hook? When enabled, committing changes to .md files will automatically re-index in the background so search results stay fresh."</span>

<span data-proof="authored" data-by="ai:claude">Options: "Yes, install hook" / "No, skip"</span>

<span data-proof="authored" data-by="ai:claude">If yes, install the hook by appending to</span> <span data-proof="authored" data-by="ai:claude">`.git/hooks/post-commit`</span> <span data-proof="authored" data-by="ai:claude">(create the file if needed, ensure it's executable):</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MzAwLCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
# qmd-auto-index:<project_name>
# Auto-update qmd index when markdown files change
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"
if command -v qmd &>/dev/null; then
  if git diff-tree --no-commit-id --name-only -r HEAD | grep -q '\.md$'; then
    (qmd update && qmd embed) &>/dev/null &
  fi
fi
```

<span data-proof="authored" data-by="ai:claude">Check for the marker comment</span> <span data-proof="authored" data-by="ai:claude">`# qmd-auto-index:<project_name>`</span> <span data-proof="authored" data-by="ai:claude">first to avoid duplicates. Update</span> <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`</span> <span data-proof="authored" data-by="ai:claude">to set</span> <span data-proof="authored" data-by="ai:claude">`"gitHook": true`.</span>

## <span data-proof="authored" data-by="ai:claude">Step 11: Print summary</span>

<span data-proof="authored" data-by="ai:claude">Show the user:</span>

* <span data-proof="authored" data-by="ai:claude">Project name</span>

* <span data-proof="authored" data-by="ai:claude">Collections created (name, path, description)</span>

* <span data-proof="authored" data-by="ai:claude">MCP server: configured/not configured</span>

* <span data-proof="authored" data-by="ai:claude">Git hook: installed/not installed</span>

* <span data-proof="authored" data-by="ai:claude">How to search:</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-search <query>`</span>

* <span data-proof="authored" data-by="ai:claude">How to reconfigure:</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span>

* <span data-proof="authored" data-by="ai:claude">How to check status:</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-status`</span>

* <span data-proof="authored" data-by="ai:claude">How to diagnose issues:</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-doctor`</span>