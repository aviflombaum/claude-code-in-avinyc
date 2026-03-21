---
name: avinyc:qmd-search
description: Search project documentation using qmd semantic search. Invoke with /avinyc:qmd-search <query> to find docs, plans, or indexed markdown content in your project.
argument-hint: "<search query>"
---

# QMD Search

Search your project's indexed markdown documentation using qmd's MCP tools. This skill reads your project's qmd configuration to know which collections to search, constructs structured queries, and retrieves relevant documents.

## Step 1: Read Config

Read `.claude/qmd.json` from the project root.

If missing, tell the user:

> qmd is not configured for this project. Run `/avinyc:qmd-configure` to set it up.

Then STOP.

Extract `project` name and `collections` — each has a name, path, and description. Pick the best collection for the query by matching against descriptions. If only one collection exists, use it.

## Step 2: Search via MCP

Use the `mcp__qmd__query` tool with a structured query. This is the primary search method — it's faster than CLI (models stay warm between queries) and supports multi-type queries with intent disambiguation.

### Constructing the Query

Every search should include at least two query types for best recall. The first query gets **2x weight** in fusion scoring, so put your best guess first.

```json
{
  "searches": [
    { "type": "lex", "query": "2-5 exact keywords, no filler" },
    { "type": "vec", "query": "full natural language question" }
  ],
  "collections": ["<collection_name>"],
  "limit": 10
}
```

### Query Types

| Type | Method | When to use | Writing tips |
|------|--------|-------------|--------------|
| `lex` | BM25 keyword | You know the exact terms in the docs | 2-5 terms. Exact phrases: `"rate limiter"`. Exclude: `-sports`. Code identifiers work. |
| `vec` | Vector semantic | You don't know the vocabulary | Full question. Be specific: "how does the auth system handle session expiry?" |
| `hyde` | Hypothetical doc | Complex topic, you can imagine the answer | Write 50-100 words of what the answer looks like, using vocabulary you expect in the result. |

### When to Use What

| Situation | Query types to include |
|-----------|----------------------|
| Know exact terms | `lex` only |
| Don't know vocabulary | `vec` only |
| Best recall | `lex` + `vec` |
| Complex or broad topic | `lex` + `vec` + `hyde` |
| Ambiguous query (e.g., "performance" could mean web perf, team health, etc.) | Any combination + `intent` |

### Intent Disambiguation

When a query term is ambiguous, add `intent` to steer all pipeline stages (expansion, reranking, snippet extraction):

```json
{
  "searches": [
    { "type": "lex", "query": "performance" },
    { "type": "vec", "query": "how to improve page load speed" }
  ],
  "intent": "web page load times and Core Web Vitals",
  "collections": ["project_docs"],
  "limit": 10
}
```

Intent does not search on its own — it's a steering signal that disambiguates what you mean.

## Step 3: Interpret Results

Results include `docid`, `score`, `file`, `title`, `context`, and `snippet`.

| Score | Meaning |
|-------|---------|
| **0.7+** | Highly relevant — read this document |
| **0.5–0.7** | Worth reading if topic matches |
| **< 0.5 on all** | Try different query types or refine |

## Step 4: Retrieve Documents

To read a full document from the results, use `mcp__qmd__get`:

```json
{ "file": "#docid" }
```

Or by file path:

```json
{ "file": "collection_name/path/to/file.md" }
```

For multiple related documents, use `mcp__qmd__multi_get` to batch retrieve:

```json
{ "pattern": "collection_name/docs/*.md" }
```

This is faster than reading files one at a time.

## Error Handling

If MCP tools fail, diagnose the issue:

| Error | Likely cause | Fix |
|-------|-------------|-----|
| `mcp__qmd__query` not available | MCP server not configured | Run `claude mcp add qmd -- qmd mcp` or add qmd to `.mcp.json`. Run `/avinyc:qmd-configure`. |
| MCP call returns error | Server not running or crashed | Run `qmd mcp` to verify. Check `qmd status`. |
| Collection not found | Config out of sync | Run `/avinyc:qmd-doctor` to diagnose. |
| No results | Index empty or stale | Run `qmd update && qmd embed` to rebuild. |

## CLI Fallback

If MCP tools are unavailable, fall back to the CLI. The `qmd query` command supports structured queries via multiline strings:

```bash
qmd query $'lex: exact keywords here\nvec: natural language question here' -c <collection> --json -n 10
```

This single command subsumes `qmd search` (BM25 only) and `qmd vsearch` (vector only). Always use `--json` for parseable output.

## Fallback to Glob/Grep

After 2 poor query attempts (different query types, refined terms), fall back to Glob/Grep on the collection's directory path from config. qmd can't find everything — sometimes a direct file search is faster.
