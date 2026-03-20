---
name: avinyc:qmd-configure
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

## Step 2: Check qmd MCP server

The search skill uses qmd's MCP tools for best performance (models stay warm between queries). Check if the MCP server is configured:

```bash
cat .mcp.json 2>/dev/null | grep -q '"qmd"' && echo "found in project" || echo "not in project"
```

If not configured, tell the user:

> qmd MCP server is not configured. Add it for the best search experience.
>
> **Option 1 — CLI (recommended):**
> ```bash
> claude mcp add qmd -- qmd mcp
> ```
>
> **Option 2 — Manual:** Add to `.mcp.json` in the project root:
> ```json
> {
>   "mcpServers": {
>     "qmd": {
>       "command": "qmd",
>       "args": ["mcp"]
>     }
>   }
> }
> ```
>
> The search skill will fall back to CLI if MCP isn't available, but MCP is significantly faster for repeated queries.

Continue with setup regardless — MCP is recommended but not required.

## Step 3: Derive project name

Get the git repo folder name and normalize it:

```bash
basename "$(git rev-parse --show-toplevel)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g; s/__*/_/g; s/^_//; s/_$//'
```

Show the derived name to the user via `AskUserQuestion`. Let them confirm or type a custom name. Once confirmed, this is the canonical project name used for all collection prefixes.

## Step 4: Scan for indexable directories

Find directories containing markdown files:

```bash
find . -maxdepth 2 -type f -name "*.md" -exec dirname {} \; | sort -u
```

From the output, select only directories useful for a searchable document collection (docs/, plans/, tasks/, etc.). Ignore tmp/, vendor/, node_modules/, and other project cruft.

## Step 5: Ask which directories to index

Use `AskUserQuestion` with `multiSelect: true`. List indexable directories as options. Explain that each directory becomes a qmd collection for fast semantic search.

If no candidate directories were found, ask the user to type custom directory paths.

## Step 6: Get collection details

For each selected directory, use `AskUserQuestion` to:
- Ask for a short description of what the directory contains (e.g., "Project architecture and feature docs")
- Confirm the file pattern (default: `**/*.md`, offer alternatives like `**/*.{md,txt}`)

## Step 7: Add collections

For each selected directory, derive the collection name: `{project}_{dirname}` where dirname has `/` and `.` replaced with `_` and leading dots stripped. Example: `.cursor/rules` → `cursor_rules`, so collection is `myproject_cursor_rules`.

Get the absolute path to the directory:

```bash
echo "$(git rev-parse --show-toplevel)/<dirname>"
```

Then add the collection:

```bash
qmd collection add "<absolute_path>" --name "<collection_name>" --mask "<pattern>"
qmd context add "qmd://<collection_name>/" "<description>"
```

If `qmd collection add` fails (collection already exists), ask the user whether to overwrite. If yes:

```bash
qmd collection remove "<collection_name>"
qmd collection add "<absolute_path>" --name "<collection_name>" --mask "<pattern>"
qmd context add "qmd://<collection_name>/" "<description>"
```

## Step 8: Write project config

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
  "gitHook": false
}
```

## Step 9: Generate embeddings

```bash
qmd update && qmd embed
```

Tell the user it's generating embeddings. This may take a moment for large collections.

## Step 10: Ask about git post-commit hook

Use `AskUserQuestion`: "Install a git post-commit hook? When enabled, committing changes to .md files will automatically re-index in the background so search results stay fresh."

Options: "Yes, install hook" / "No, skip"

If yes, install the hook by appending to `.git/hooks/post-commit` (create the file if needed, ensure it's executable):

```bash
# qmd-auto-index:<project_name>
# Auto-update qmd index when markdown files change
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"
if command -v qmd &>/dev/null; then
  if git diff-tree --no-commit-id --name-only -r HEAD | grep -q '\.md$'; then
    (qmd update && qmd embed) &>/dev/null &
  fi
fi
```

Check for the marker comment `# qmd-auto-index:<project_name>` first to avoid duplicates. Update `.claude/qmd.json` to set `"gitHook": true`.

## Step 11: Print summary

Show the user:
- Project name
- Collections created (name, path, description)
- MCP server: configured/not configured
- Git hook: installed/not installed
- How to search: `/avinyc:qmd-search <query>`
- How to reconfigure: `/avinyc:qmd-configure`
- How to check status: `/avinyc:qmd-status`
- How to diagnose issues: `/avinyc:qmd-doctor`
