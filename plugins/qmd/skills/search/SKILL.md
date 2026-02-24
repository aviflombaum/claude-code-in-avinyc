---
name: search
description: Search project documentation using qmd semantic search. Use BEFORE grepping/globbing indexed directories. Triggers on any task involving finding docs, plans, or other indexed markdown content.
argument-hint: "<search query>"
user-invocable: true
allowed-tools: ["Bash", "Read"]
---

# QMD Search

Search indexed collections using qmd for fast, relevant results before falling back to manual file exploration.

## Prerequisites

Read `.claude/qmd.json`. If the file is missing, tell the user: "qmd is not configured for this project. Run `/qmd:configure` to set it up." Then STOP.

## Search Flow

### Step 1: Load config

Extract from `.claude/qmd.json`:
- `project`: the project name
- `collections`: map of collection name → {path, pattern, description}

### Step 2: Choose collection

- **Single collection**: use it directly
- **Multiple collections**: match the query against collection descriptions to pick the best one. If ambiguous, search the most likely collection first. If results are poor, try the next.

### Step 3: Run BM25 search

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-search.sh "<query>" "<collection_name>" 5
```

### Step 4: Evaluate results

- **0.7+**: Highly relevant, read this document
- **0.5-0.7**: Worth reading if topic matches
- **< 0.5 on all results**: Fall back to vsearch

### Step 5: Fallback to vsearch if needed

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qmd-vsearch.sh "<query>" "<collection_name>" 5
```

### Step 6: Read top results

For each relevant result:
1. Extract the file path from the `file` field
2. Strip the `qmd://<collection_name>/` prefix
3. Prepend the collection's `path` from config to get the repo-relative path
4. Use the **Read tool** to read the file

### Step 7: Retry or fall back

- If results are still poor after vsearch, refine the query and try again (max 2 retries)
- After retries exhausted, fall back to Glob/Grep on the directory

## Rules

- **Use wrapper scripts** in `${CLAUDE_PLUGIN_ROOT}/scripts/` for all qmd operations (direct `qmd` calls are blocked by a hook)
- **Start with BM25** (`qmd-search.sh`), fall back to vsearch only if scores < 0.5
- **Use the Read tool** to read result files, not `qmd get`
- **Default to 5 results** (3rd argument: use `3` for narrow queries, `10` for broad)

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

1. Review `title` and `snippet` for relevance
2. Extract file path: strip `qmd://<collection>/` prefix
3. Build repo path: `<collection_path_from_config>/<stripped_path>`
4. Use the Read tool to read the file
