---
name: configure
description: Configure or reconfigure qmd collections for this project. Triggers on "configure qmd", "set up qmd", "reconfigure qmd", "qmd setup".
user-invocable: true
allowed-tools: ["Bash", "Read", "Write", "AskUserQuestion"]
---

# QMD Configure

Interactive interview to set up or reconfigure qmd collections for a project. Idempotent: works for both first-time setup and reconfiguration.

Run this flow step by step. Do NOT skip steps or assume answers.

## Step 1: Check qmd is installed

```bash
command -v qmd
```

If missing, tell the user:
> qmd is not installed. Install it with: `npm install -g @tobilu/qmd`

Then STOP.

## Step 2: Derive project name

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-derive-name.sh
```

Show the derived name to the user via `AskUserQuestion`. Let them confirm or type a custom name. Once confirmed, this is the canonical project name used for all collection prefixes.

## Step 3: Scan for indexable directories

Find the directories in this project that contain markdown files that should be part of this projects qmd collection index by running:

```bash
find . -maxdepth 2 -type f -name "*.md" -exec dirname {} \; | sort -u
```

From that output, select only the directories that would be helpful for a searchable document collection to present to the user in the next step. Common examples would be docs/ or plans/ or tasks/. Ignore tmp/ vendor/ and other project cruft.

## Step 4: Ask which directories to index

Use `AskUserQuestion` with `multiSelect: true`. List indexable directories as an option. Explain that each directory becomes a qmd collection for fast semantic search.

If no candidate directories were found, ask the user to type custom directory paths.

## Step 5: Get collection details

For each selected directory, use `AskUserQuestion` to:
- Ask for a short description of what the directory contains (e.g., "Project architecture and feature docs")
- Confirm the file pattern (default: `**/*.md`, offer alternatives like `**/*.{md,txt}`)

## Step 6: Add collections via wrapper scripts

For each selected directory, derive the collection name: `{project}_{dirname}` where dirname has `/` and `.` replaced with `_` and leading dots stripped. Example: `.cursor/rules` → `cursor_rules`, so collection is `myproject_cursor_rules`.

Get the absolute path to the directory:

```bash
echo "$(git rev-parse --show-toplevel)/<dirname>"
```

Then add the collection:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-add-collection.sh "<collection_name>" "<absolute_path>" "<pattern>" "<description>"
```

If the script exits 1 (collection already exists), ask the user whether to overwrite. If yes:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-remove-collection.sh "<collection_name>"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-add-collection.sh "<collection_name>" "<absolute_path>" "<pattern>" "<description>"
```

## Step 7: Write project config

Use the Write tool to create `.claude/qmd.json`:

```json
{
  "project": "<project_name>",
  "collections": {
    "<project>_<dirname>": {
      "path": "<relative-dir-path>",
      "pattern": "**/*.md",
      "description": "<user-provided description>"
    }
  },
  "guardedDirs": ["<dir1>", "<dir2>"],
  "guard": false,
  "gitHook": false
}
```

`guardedDirs` includes all selected directory paths (relative, e.g., `docs`, `plans`, `.cursor/rules`).

## Step 8: Generate embeddings

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-index.sh
```

Tell the user it's generating embeddings.

## Step 9: Ask about guard hook

Use `AskUserQuestion`: "Enable the guard hook? When enabled, Glob/Grep on indexed directories will be blocked and redirected to /qmd:search. This enforces a qmd-first workflow. You can disable it later by setting `guard: false` in `.claude/qmd.json`."

Options: "Yes, enable guard" / "No, skip"

If yes, update `.claude/qmd.json` to set `"guard": true`.

## Step 10: Ask about git post-commit hook

Use `AskUserQuestion`: "Install a git post-commit hook? When enabled, committing changes to .md files will automatically re-index in the background so search results stay fresh."

Options: "Yes, install hook" / "No, skip"

If yes:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-git-hook.sh <project_name>
```

Update `.claude/qmd.json` to set `"gitHook": true`.

## Step 11: Print summary

Show the user:
- Project name
- Collections created (name, path, description)
- Guard hook: enabled/disabled
- Git hook: installed/not installed
- How to search: `/qmd:search <query>`
- How to reconfigure: `/qmd:configure`
- How to check status: `/qmd:status`
- How to check health: `/qmd:doctor`
