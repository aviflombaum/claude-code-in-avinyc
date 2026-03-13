---
name: avinyc:qmd-status
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

**Step 2:** Run qmd status:

```bash
qmd status
```

Display the output alongside the config summary.
