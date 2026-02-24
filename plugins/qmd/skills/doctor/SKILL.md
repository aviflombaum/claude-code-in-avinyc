---
name: doctor
description: Run qmd health check for this project. Triggers on "qmd doctor", "check qmd health", "qmd problems", "diagnose qmd".
user-invocable: true
allowed-tools: ["Bash"]
---

# QMD Doctor

Run the health check script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-doctor.sh
```

The script performs all checks and outputs `[PASS]`, `[FAIL]`, or `[WARN]` lines. Display the raw output, then explain any failures:

- `[FAIL] qmd binary not found` → `bun install -g @tobilu/qmd`
- `[FAIL] .claude/qmd.json not found` → run `/qmd:configure`
- `[FAIL] Collection not in qmd index` → run `/qmd:configure`
- `[WARN] Git hook contains --index` → run `/qmd:configure` and re-enable git hook
- `[WARN] Collection naming mismatch` → run `/qmd:configure` to fix

The script does all the work. Just display and explain.
