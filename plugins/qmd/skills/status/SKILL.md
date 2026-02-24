---
name: status
description: Show qmd configuration and index status for this project. Triggers on "qmd status", "show qmd config", "qmd collections".
user-invocable: true
allowed-tools: ["Bash", "Read"]
---

# QMD Status

**Step 1:** Read `.claude/qmd.json` and print a summary:
- Project name
- Collections (name, path, description)
- Guard hook: enabled/disabled
- Git hook: installed/not installed

**Step 2:** Run the status script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-status.sh
```

Display the raw script output alongside the config summary.
