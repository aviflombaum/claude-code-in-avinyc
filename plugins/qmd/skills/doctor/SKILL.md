---
name: avinyc:qmd-doctor
description: Run qmd health check for this project. Triggers on "qmd doctor", "check qmd health", "qmd problems", "diagnose qmd".
user-invocable: true
allowed-tools: ["Bash", "Read", "Glob", "mcp__qmd__status"]
---

# <span data-proof="authored" data-by="ai:claude">QMD Doctor</span>

<span data-proof="authored" data-by="ai:claude">Run a comprehensive health check on the qmd configuration for this project. Perform each check below in order and report results as</span> <span data-proof="authored" data-by="ai:claude">`[PASS]`,</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`, or</span> <span data-proof="authored" data-by="ai:claude">`[WARN]`. At the end, summarize the total number of issues found.</span>

## <span data-proof="authored" data-by="ai:claude">Remediation Reference</span>

<span data-proof="authored" data-by="ai:claude">For any failure, suggest the appropriate fix:</span>

| <span data-proof="authored" data-by="ai:claude">Failure</span>                        | <span data-proof="authored" data-by="ai:claude">Fix</span>                                                                                                                                                                                        |
| ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <span data-proof="authored" data-by="ai:claude">qmd binary not found</span>           | <span data-proof="authored" data-by="ai:claude">`npm install -g @tobilu/qmd`</span>                                                                                                                                                               |
| <span data-proof="authored" data-by="ai:claude">.claude/qmd.json missing</span>       | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span>                                                                                                         |
| <span data-proof="authored" data-by="ai:claude">Missing project field</span>          | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span>                                                                                                         |
| <span data-proof="authored" data-by="ai:claude">Collection not in qmd index</span>    | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span>                                                                                                         |
| <span data-proof="authored" data-by="ai:claude">Collection naming mismatch</span>     | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span> <span data-proof="authored" data-by="ai:claude">to rename</span>                                        |
| <span data-proof="authored" data-by="ai:claude">Git hook missing/wrong marker</span>  | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span> <span data-proof="authored" data-by="ai:claude">and re-enable git hook</span>                           |
| <span data-proof="authored" data-by="ai:claude">Git hook has old --index flag</span>  | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span> <span data-proof="authored" data-by="ai:claude">and re-enable git hook</span>                           |
| <span data-proof="authored" data-by="ai:claude">MCP server not responding</span>      | <span data-proof="authored" data-by="ai:claude">Add</span> <span data-proof="authored" data-by="ai:claude">`"mcpServers": {"qmd": {"command": "qmd", "args": ["mcp"]}}`</span> <span data-proof="authored" data-by="ai:claude">to settings</span> |
| <span data-proof="authored" data-by="ai:claude">YAML config missing collection</span> | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span>                                                                                                         |

## <span data-proof="authored" data-by="ai:claude">Checks</span>

### <span data-proof="authored" data-by="ai:claude">1. qmd binary</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MTQsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
command -v qmd
```

<span data-proof="authored" data-by="ai:claude">`[PASS]`</span> <span data-proof="authored" data-by="ai:claude">if found (print the path),</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`</span> <span data-proof="authored" data-by="ai:claude">if not.</span>

### <span data-proof="authored" data-by="ai:claude">2. Config file exists</span>

<span data-proof="authored" data-by="ai:claude">Check if</span> <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`</span> <span data-proof="authored" data-by="ai:claude">exists using Read. If it does not exist, report</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`</span> <span data-proof="authored" data-by="ai:claude">and stop — remaining checks depend on it.</span>

### <span data-proof="authored" data-by="ai:claude">3. Valid JSON</span>

<span data-proof="authored" data-by="ai:claude">Read</span> <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`. If you can parse it as JSON,</span> <span data-proof="authored" data-by="ai:claude">`[PASS]`. If the content is malformed,</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`</span> <span data-proof="authored" data-by="ai:claude">and stop.</span>

### <span data-proof="authored" data-by="ai:claude">4. Has "project" field</span>

<span data-proof="authored" data-by="ai:claude">Check the parsed JSON has a non-empty</span> <span data-proof="authored" data-by="ai:claude">`project`</span> <span data-proof="authored" data-by="ai:claude">string.</span> <span data-proof="authored" data-by="ai:claude">`[PASS]`</span> <span data-proof="authored" data-by="ai:claude">or</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`.</span>

### <span data-proof="authored" data-by="ai:claude">5. Default index database</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NzQsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
test -f "$HOME/.cache/qmd/index.sqlite" && echo "exists" || echo "missing"
```

<span data-proof="authored" data-by="ai:claude">`[PASS]`</span> <span data-proof="authored" data-by="ai:claude">if exists,</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`</span> <span data-proof="authored" data-by="ai:claude">if missing.</span>

### <span data-proof="authored" data-by="ai:claude">6. Global config</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NzIsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
test -f "$HOME/.config/qmd/index.yml" && echo "exists" || echo "missing"
```

<span data-proof="authored" data-by="ai:claude">`[PASS]`</span> <span data-proof="authored" data-by="ai:claude">if exists,</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`</span> <span data-proof="authored" data-by="ai:claude">if missing.</span>

### <span data-proof="authored" data-by="ai:claude">7-9. Collection checks</span>

<span data-proof="authored" data-by="ai:claude">For each key in the</span> <span data-proof="authored" data-by="ai:claude">`collections`</span> <span data-proof="authored" data-by="ai:claude">object:</span>

**<span data-proof="authored" data-by="ai:claude">7. Collection in qmd index:</span>**

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MTksImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
qmd collection list
```

<span data-proof="authored" data-by="ai:claude">Check if the collection name appears in the output.</span> <span data-proof="authored" data-by="ai:claude">`[PASS]`</span> <span data-proof="authored" data-by="ai:claude">or</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`.</span>

**<span data-proof="authored" data-by="ai:claude">8. Naming convention:</span>** <span data-proof="authored" data-by="ai:claude">If the project name is set, check that the collection name starts with</span> <span data-proof="authored" data-by="ai:claude">`{project}_`.</span> <span data-proof="authored" data-by="ai:claude">`[PASS]`</span> <span data-proof="authored" data-by="ai:claude">or</span> <span data-proof="authored" data-by="ai:claude">`[WARN]`.</span>

### <span data-proof="authored" data-by="ai:claude">9. YAML config entries</span>

<span data-proof="authored" data-by="ai:claude">If</span> <span data-proof="authored" data-by="ai:claude">`~/.config/qmd/index.yml`</span> <span data-proof="authored" data-by="ai:claude">exists, check that each collection name appears in it:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NTgsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
grep -F "{collection_name}:" "$HOME/.config/qmd/index.yml"
```

<span data-proof="authored" data-by="ai:claude">`[PASS]`</span> <span data-proof="authored" data-by="ai:claude">or</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`</span> <span data-proof="authored" data-by="ai:claude">per collection.</span>

### <span data-proof="authored" data-by="ai:claude">10-11. Git hook checks (only if</span> <span data-proof="authored" data-by="ai:claude">`gitHook`</span> <span data-proof="authored" data-by="ai:claude">is</span> <span data-proof="authored" data-by="ai:claude">`true`)</span>

**<span data-proof="authored" data-by="ai:claude">10.</span>** <span data-proof="authored" data-by="ai:claude">Check</span> <span data-proof="authored" data-by="ai:claude">`.git/hooks/post-commit`</span> <span data-proof="authored" data-by="ai:claude">exists. If it does, verify it contains the marker comment</span> <span data-proof="authored" data-by="ai:claude">`# qmd-auto-index:{project}`.</span> <span data-proof="authored" data-by="ai:claude">`[PASS]`,</span> <span data-proof="authored" data-by="ai:claude">`[WARN]`</span> <span data-proof="authored" data-by="ai:claude">(marker mismatch), or</span> <span data-proof="authored" data-by="ai:claude">`[FAIL]`</span> <span data-proof="authored" data-by="ai:claude">(missing).</span>

**<span data-proof="authored" data-by="ai:claude">11.</span>** <span data-proof="authored" data-by="ai:claude">Check the hook does NOT contain the deprecated</span> <span data-proof="authored" data-by="ai:claude">`--index`</span> <span data-proof="authored" data-by="ai:claude">flag.</span> <span data-proof="authored" data-by="ai:claude">`[PASS]`</span> <span data-proof="authored" data-by="ai:claude">or</span> <span data-proof="authored" data-by="ai:claude">`[WARN]`.</span>

### <span data-proof="authored" data-by="ai:claude">12. MCP server connectivity</span>

<span data-proof="authored" data-by="ai:claude">Try calling</span> <span data-proof="authored" data-by="ai:claude">`mcp__qmd__status`. If it returns data,</span> <span data-proof="authored" data-by="ai:claude">`[PASS]`. If the tool is not available or returns an error,</span> <span data-proof="authored" data-by="ai:claude">`[WARN]`</span> <span data-proof="authored" data-by="ai:claude">with message:</span>

> <span data-proof="authored" data-by="ai:claude">MCP server not configured or not responding. Search will fall back to CLI. Add</span> <span data-proof="authored" data-by="ai:claude">`"mcpServers": {"qmd": {"command": "qmd", "args": ["mcp"]}}`</span> <span data-proof="authored" data-by="ai:claude">to your Claude Code settings.</span>

## <span data-proof="authored" data-by="ai:claude">Output Format</span>

<span data-proof="authored" data-by="ai:claude">Print each result on its own line:</span>

```
[PASS] qmd binary found: /path/to/qmd
[PASS] .claude/qmd.json exists
[PASS] .claude/qmd.json is valid JSON
[PASS] Project name: myproject
[FAIL] Default index database missing: ~/.cache/qmd/index.sqlite
[WARN] MCP server not configured — search will use CLI fallback
...

N issue(s) found.
```

<span data-proof="authored" data-by="ai:claude">If all checks pass, end with:</span> <span data-proof="authored" data-by="ai:claude">`All checks passed.`</span>