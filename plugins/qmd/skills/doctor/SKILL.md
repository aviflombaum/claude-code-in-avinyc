---
name: avinyc:qmd-doctor
description: Run qmd health check for this project. Triggers on "qmd doctor", "check qmd health", "qmd problems", "diagnose qmd".
user-invocable: true
allowed-tools: ["Bash", "Read", "Glob", "mcp__qmd__status"]
---

# QMD Doctor

Run a comprehensive health check on the qmd configuration for this project. Perform each check below in order and report results as `[PASS]`, `[FAIL]`, or `[WARN]`. At the end, summarize the total number of issues found.

## Remediation Reference

For any failure, suggest the appropriate fix:

| Failure | Fix |
|---------|-----|
| qmd binary not found | `npm install -g @tobilu/qmd` |
| .claude/qmd.json missing | Run `/avinyc:qmd-configure` |
| Missing project field | Run `/avinyc:qmd-configure` |
| Collection not in qmd index | Run `/avinyc:qmd-configure` |
| Collection naming mismatch | Run `/avinyc:qmd-configure` to rename |
| Git hook missing/wrong marker | Run `/avinyc:qmd-configure` and re-enable git hook |
| Git hook has old --index flag | Run `/avinyc:qmd-configure` and re-enable git hook |
| MCP server not responding | Run `claude mcp add qmd -- qmd mcp` or add qmd to `.mcp.json` |
| YAML config missing collection | Run `/avinyc:qmd-configure` |

## Checks

### 1. qmd binary

```bash
command -v qmd
```

`[PASS]` if found (print the path), `[FAIL]` if not.

### 2. Config file exists

Check if `.claude/qmd.json` exists using Read. If it does not exist, report `[FAIL]` and stop — remaining checks depend on it.

### 3. Valid JSON

Read `.claude/qmd.json`. If you can parse it as JSON, `[PASS]`. If the content is malformed, `[FAIL]` and stop.

### 4. Has "project" field

Check the parsed JSON has a non-empty `project` string. `[PASS]` or `[FAIL]`.

### 5. Default index database

```bash
test -f "$HOME/.cache/qmd/index.sqlite" && echo "exists" || echo "missing"
```

`[PASS]` if exists, `[FAIL]` if missing.

### 6. Global config

```bash
test -f "$HOME/.config/qmd/index.yml" && echo "exists" || echo "missing"
```

`[PASS]` if exists, `[FAIL]` if missing.

### 7-9. Collection checks

For each key in the `collections` object:

**7. Collection in qmd index:**

```bash
qmd collection list
```

Check if the collection name appears in the output. `[PASS]` or `[FAIL]`.

**8. Naming convention:** If the project name is set, check that the collection name starts with `{project}_`. `[PASS]` or `[WARN]`.

### 9. YAML config entries

If `~/.config/qmd/index.yml` exists, check that each collection name appears in it:

```bash
grep -F "{collection_name}:" "$HOME/.config/qmd/index.yml"
```

`[PASS]` or `[FAIL]` per collection.

### 10-11. Git hook checks (only if `gitHook` is `true`)

**10.** Check `.git/hooks/post-commit` exists. If it does, verify it contains the marker comment `# qmd-auto-index:{project}`. `[PASS]`, `[WARN]` (marker mismatch), or `[FAIL]` (missing).

**11.** Check the hook does NOT contain the deprecated `--index` flag. `[PASS]` or `[WARN]`.

### 12. MCP server connectivity

Try calling `mcp__qmd__status`. If it returns data, `[PASS]`. If the tool is not available or returns an error, `[WARN]` with message:

> MCP server not configured or not responding. Search will fall back to CLI. Run `claude mcp add qmd -- qmd mcp` or add qmd to `.mcp.json`.

## Output Format

Print each result on its own line:

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

If all checks pass, end with: `All checks passed.`
