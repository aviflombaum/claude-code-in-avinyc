---
name: search
description: Search project documentation using qmd semantic search, or configure qmd for a new project. Use BEFORE grepping/globbing indexed directories. Triggers on any task involving finding docs, plans, or other indexed markdown content.
argument-hint: "[search query | setup | reconfigure | status]"
user-invocable: true
allowed-tools: ["Bash", "Read", "Write", "AskUserQuestion"]
---

# QMD Search — Generic Project Documentation Discovery

Search indexed collections using qmd for fast, relevant results before falling back to manual file exploration. On first use in a project, runs an interactive setup interview to configure collections.

## Entry Point

1. Read `.claude/qmd.json`
2. If file exists AND argument is NOT `setup` or `reconfigure` → **Search Mode**
3. If file is missing OR argument is `setup` or `reconfigure` → **Setup Mode**
4. If argument is `status` → **Status Mode**: read `.claude/qmd.json`, print summary of index name, collections, guard status, git hook status, then stop

---

## Setup Mode (Interactive Interview)

Run this flow step by step. Do NOT skip steps or assume answers.

### Step 1: Check qmd is installed

```bash
command -v qmd
```

If missing, tell the user:
> qmd is not installed. Install it with: `bun install -g @tobilu/qmd`

Then STOP. Do not continue setup.

### Step 2: Determine project root and index name

Get the project root from git:

```bash
git rev-parse --show-toplevel
```

Derive the index name: take the folder name, lowercase, replace non-alphanumeric with `_`. Example: `vc-matcher-app-rails` → `vc_matcher_app_rails`.

### Step 3: Scan for indexable directories

Check which of these directories exist in the project root:

- `docs/`
- `plans/`
- `tasks/`
- `.cursor/rules/`
- `wiki/`
- `notes/`
- `specs/`
- `.plans-archive/`

```bash
ls -d docs plans tasks .cursor/rules wiki notes specs .plans-archive 2>/dev/null
```

### Step 4: Ask which directories to index

Use `AskUserQuestion` with `multiSelect: true`. List each found directory as an option. Explain that each directory becomes a qmd collection for fast semantic search.

If no candidate directories were found, ask the user to type custom directory paths.

### Step 5: Get collection details

For each selected directory, use `AskUserQuestion` to:
- Ask for a short description of what the directory contains (e.g., "Project architecture and feature docs")
- Confirm the file pattern (default: `**/*.md`, offer alternatives like `**/*.{md,txt}`)

### Step 6: Confirm index name

Use `AskUserQuestion` to show the derived index name and let the user confirm or override it.

### Step 7: Write qmd config YAML

Write `~/.config/qmd/<index>.yml`:

```yaml
index: <index_name>
collections:
  <index>_<dirname>:
    path: /absolute/path/to/<dirname>
    pattern: "**/*.md"
    context: "<user-provided description>"
```

Collection names are prefixed with the index name and underscore to avoid collisions. Directory names in collection keys have `/` and `.` replaced with `_`. Example: `.plans-archive` → `plans_archive`, so collection is `myproject_plans_archive`.

```bash
mkdir -p ~/.config/qmd
```

Then use the Write tool to create `~/.config/qmd/<index>.yml`.

### Step 8: Write project config

Use the Write tool to create `.claude/qmd.json`:

```json
{
  "index": "<index_name>",
  "collections": {
    "<index>_<dirname>": {
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

`guardedDirs` includes all selected directory paths (relative, e.g., `docs`, `plans`, `.plans-archive`).

### Step 9: Run initial indexing

```bash
qmd update --index <index_name> && qmd embed --index <index_name>
```

This may take a moment. Tell the user it's indexing.

### Step 10: Ask about guard hook

Use `AskUserQuestion`: "Enable the guard hook? When enabled, Glob/Grep on indexed directories will be blocked and redirected to /qmd:search. This enforces a qmd-first workflow. You can disable it later by setting `guard: false` in `.claude/qmd.json`."

Options: "Yes, enable guard" / "No, skip"

If yes, update `.claude/qmd.json` to set `"guard": true`.

### Step 11: Ask about git post-commit hook

Use `AskUserQuestion`: "Install a git post-commit hook? When enabled, committing changes to .md files will automatically re-index in the background so search results stay fresh."

Options: "Yes, install hook" / "No, skip"

If yes:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-git-hook.sh <index_name>
```

Update `.claude/qmd.json` to set `"gitHook": true`.

### Step 12: Print summary

Show the user:
- Index name
- Collections created (name, path, description)
- Guard hook: enabled/disabled
- Git hook: installed/not installed
- How to search: `/qmd:search <query>`
- How to reconfigure: `/qmd:search reconfigure`

---

## Search Mode

### Step 1: Load config

Read `.claude/qmd.json`. Extract:
- `index`: the qmd index name
- `collections`: map of collection name → {path, pattern, description}

### Step 2: Choose collection

- **Single collection**: use it directly
- **Multiple collections**: match the query against collection descriptions to pick the best one. If ambiguous, search the most likely collection first. If results are poor, try the next collection.

### Step 3: Run search

```bash
qmd search "<query>" -c <collection_name> --json -n 5 --index <index_name>
```

### Step 4: Evaluate results

Check scores:
- **0.7+**: Highly relevant, read this document
- **0.5-0.7**: Relevant, worth reading if topic matches
- **< 0.5 on all results**: Fall back to vsearch

### Step 5: Fallback to vsearch if needed

```bash
qmd vsearch "<query>" -c <collection_name> --json -n 5 --index <index_name>
```

### Step 6: Read top results

For each relevant result:
1. Extract the file path from the `file` field
2. Strip the `qmd://<collection_name>/` prefix
3. Prepend the collection's `path` from config to get the repo-relative path
4. Use the **Read tool** to read the file (NOT `qmd get`)

### Step 7: Retry or fall back

- If results are still poor after vsearch, refine the query and try again (max 2 retries total)
- After retries exhausted, fall back to Glob/Grep on the directory

---

## STRICT RULES — What You MUST and MUST NOT Do

### NEVER do these:

- **NEVER use `qmd query`** — it is slow, uses GPU, and is overkill for search
- **NEVER use `qmd embed`** — this is an admin re-indexing operation, not a search
- **NEVER use `qmd update`** — this is an admin re-indexing operation, not a search
- **NEVER use `qmd collection add/remove/rename`** — never modify collections
- **NEVER use `qmd context add/rm`** — never modify collection metadata
- **NEVER use `qmd mcp`** — the MCP server is not used here
- **NEVER use `qmd get` to read files** — use the Read tool instead
- **NEVER pass `--full` flag** — it dumps entire documents and floods the context window
- **NEVER omit `--json`** — always use JSON output for structured parsing
- **NEVER omit `-c <collection>`** — always scope to a specific collection
- **NEVER omit `--index <index>`** — every project uses an isolated index
- **NEVER search both collections in the same command** — run separate searches
- **NEVER pipe qmd output through other commands** (no `| jq`, `| grep`, etc.)
- **NEVER use `--all` flag** — unbounded results will flood context

### ALWAYS do these:

- **ALWAYS use `--index <index>`** on every qmd command — read from `.claude/qmd.json`
- **ALWAYS use `--json` flag** for structured output
- **ALWAYS use `-c <collection>`** to scope searches
- **ALWAYS start with `qmd search`** (BM25) — it's fast and sufficient for most queries
- **ALWAYS fall back to `qmd vsearch`** only if BM25 returns poor results (scores < 0.5)
- **ALWAYS use `-n 5`** as default result count (`-n 3` for narrow, `-n 10` for broad)
- **ALWAYS use the Read tool** to read result files (not `qmd get`)

## Command Templates

### BM25 search:

```bash
qmd search "<query>" -c <collection> --json -n 5 --index <index>
```

### Semantic fallback:

```bash
qmd vsearch "<query>" -c <collection> --json -n 5 --index <index>
```

## Interpreting Results

JSON output contains an array:

```json
[
  {
    "docid": "#abc123",
    "score": 0.74,
    "file": "qmd://<collection>/path/to/file.md",
    "title": "Document Title",
    "context": "Collection description...",
    "snippet": "..."
  }
]
```

**After getting results:**

1. Review `title` and `snippet` for relevance
2. Extract file path: strip `qmd://<collection>/` prefix
3. Build repo path: `<collection_path_from_config>/<stripped_path>`
4. Use the Read tool to read the file
