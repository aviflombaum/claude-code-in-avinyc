---
name: avinyc:qmd-search
description: Search project documentation using qmd semantic search. Invoke with /avinyc:qmd-search <query> to find docs, plans, or indexed markdown content in your project.
argument-hint: "<search query>"
---

# <span data-proof="authored" data-by="ai:claude">QMD Search</span>

<span data-proof="authored" data-by="ai:claude">Search your project's indexed markdown documentation using qmd's MCP tools. This skill reads your project's qmd configuration to know which collections to search, constructs structured queries, and retrieves relevant documents.</span>

## <span data-proof="authored" data-by="ai:claude">Step 1: Read Config</span>

<span data-proof="authored" data-by="ai:claude">Read</span> <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`</span> <span data-proof="authored" data-by="ai:claude">from the project root.</span>

<span data-proof="authored" data-by="ai:claude">If missing, tell the user:</span>

> <span data-proof="authored" data-by="ai:claude">qmd is not configured for this project. Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span> <span data-proof="authored" data-by="ai:claude">to set it up.</span>

<span data-proof="authored" data-by="ai:claude">Then STOP.</span>

<span data-proof="authored" data-by="ai:claude">Extract</span> <span data-proof="authored" data-by="ai:claude">`project`</span> <span data-proof="authored" data-by="ai:claude">name and</span> <span data-proof="authored" data-by="ai:claude">`collections`</span> <span data-proof="authored" data-by="ai:claude">— each has a name, path, and description. Pick the best collection for the query by matching against descriptions. If only one collection exists, use it.</span>

## <span data-proof="authored" data-by="ai:claude">Step 2: Search via MCP</span>

<span data-proof="authored" data-by="ai:claude">Use the</span> <span data-proof="authored" data-by="ai:claude">`mcp__qmd__query`</span> <span data-proof="authored" data-by="ai:claude">tool with a structured query. This is the primary search method — it's faster than CLI (models stay warm between queries) and supports multi-type queries with intent disambiguation.</span>

### <span data-proof="authored" data-by="ai:claude">Constructing the Query</span>

<span data-proof="authored" data-by="ai:claude">Every search should include at least two query types for best recall. The first query gets</span> **<span data-proof="authored" data-by="ai:claude">2x weight</span>** <span data-proof="authored" data-by="ai:claude">in fusion scoring, so put your best guess first.</span>

```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MjA4LCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
{
  "searches": [
    { "type": "lex", "query": "2-5 exact keywords, no filler" },
    { "type": "vec", "query": "full natural language question" }
  ],
  "collections": ["<collection_name>"],
  "limit": 10
}
```

### <span data-proof="authored" data-by="ai:claude">Query Types</span>

| <span data-proof="authored" data-by="ai:claude">Type</span>   | <span data-proof="authored" data-by="ai:claude">Method</span>           | <span data-proof="authored" data-by="ai:claude">When to use</span>                               | <span data-proof="authored" data-by="ai:claude">Writing tips</span>                                                                                                                                                                                         |
| ------------------------------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <span data-proof="authored" data-by="ai:claude">`lex`</span>  | <span data-proof="authored" data-by="ai:claude">BM25 keyword</span>     | <span data-proof="authored" data-by="ai:claude">You know the exact terms in the docs</span>      | <span data-proof="authored" data-by="ai:claude">2-5 terms. Exact phrases:</span> <span data-proof="authored" data-by="ai:claude">`"rate limiter"`. Exclude:</span> <span data-proof="authored" data-by="ai:claude">`-sports`. Code identifiers work.</span> |
| <span data-proof="authored" data-by="ai:claude">`vec`</span>  | <span data-proof="authored" data-by="ai:claude">Vector semantic</span>  | <span data-proof="authored" data-by="ai:claude">You don't know the vocabulary</span>             | <span data-proof="authored" data-by="ai:claude">Full question. Be specific: "how does the auth system handle session expiry?"</span>                                                                                                                        |
| <span data-proof="authored" data-by="ai:claude">`hyde`</span> | <span data-proof="authored" data-by="ai:claude">Hypothetical doc</span> | <span data-proof="authored" data-by="ai:claude">Complex topic, you can imagine the answer</span> | <span data-proof="authored" data-by="ai:claude">Write 50-100 words of what the answer looks like, using vocabulary you expect in the result.</span>                                                                                                         |

### <span data-proof="authored" data-by="ai:claude">When to Use What</span>

| <span data-proof="authored" data-by="ai:claude">Situation</span>                                                                    | <span data-proof="authored" data-by="ai:claude">Query types to include</span>                                                                                                                                                                                                                             |
| ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <span data-proof="authored" data-by="ai:claude">Know exact terms</span>                                                             | <span data-proof="authored" data-by="ai:claude">`lex`</span> <span data-proof="authored" data-by="ai:claude">only</span>                                                                                                                                                                                  |
| <span data-proof="authored" data-by="ai:claude">Don't know vocabulary</span>                                                        | <span data-proof="authored" data-by="ai:claude">`vec`</span> <span data-proof="authored" data-by="ai:claude">only</span>                                                                                                                                                                                  |
| <span data-proof="authored" data-by="ai:claude">Best recall</span>                                                                  | <span data-proof="authored" data-by="ai:claude">`lex`</span> <span data-proof="authored" data-by="ai:claude">+</span> <span data-proof="authored" data-by="ai:claude">`vec`</span>                                                                                                                        |
| <span data-proof="authored" data-by="ai:claude">Complex or broad topic</span>                                                       | <span data-proof="authored" data-by="ai:claude">`lex`</span> <span data-proof="authored" data-by="ai:claude">+</span> <span data-proof="authored" data-by="ai:claude">`vec`</span> <span data-proof="authored" data-by="ai:claude">+</span> <span data-proof="authored" data-by="ai:claude">`hyde`</span> |
| <span data-proof="authored" data-by="ai:claude">Ambiguous query (e.g., "performance" could mean web perf, team health, etc.)</span> | <span data-proof="authored" data-by="ai:claude">Any combination +</span> <span data-proof="authored" data-by="ai:claude">`intent`</span>                                                                                                                                                                  |

### <span data-proof="authored" data-by="ai:claude">Intent Disambiguation</span>

<span data-proof="authored" data-by="ai:claude">When a query term is ambiguous, add</span> <span data-proof="authored" data-by="ai:claude">`intent`</span> <span data-proof="authored" data-by="ai:claude">to steer all pipeline stages (expansion, reranking, snippet extraction):</span>

```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MjQwLCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
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

<span data-proof="authored" data-by="ai:claude">Intent does not search on its own — it's a steering signal that disambiguates what you mean.</span>

## <span data-proof="authored" data-by="ai:claude">Step 3: Interpret Results</span>

<span data-proof="authored" data-by="ai:claude">Results include</span> <span data-proof="authored" data-by="ai:claude">`docid`,</span> <span data-proof="authored" data-by="ai:claude">`score`,</span> <span data-proof="authored" data-by="ai:claude">`file`,</span> <span data-proof="authored" data-by="ai:claude">`title`,</span> <span data-proof="authored" data-by="ai:claude">`context`, and</span> <span data-proof="authored" data-by="ai:claude">`snippet`.</span>

| <span data-proof="authored" data-by="ai:claude">Score</span>            | <span data-proof="authored" data-by="ai:claude">Meaning</span>                              |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| **<span data-proof="authored" data-by="ai:claude">0.7+</span>**         | <span data-proof="authored" data-by="ai:claude">Highly relevant — read this document</span> |
| **<span data-proof="authored" data-by="ai:claude">0.5–0.7</span>**      | <span data-proof="authored" data-by="ai:claude">Worth reading if topic matches</span>       |
| **<span data-proof="authored" data-by="ai:claude">< 0.5 on all</span>** | <span data-proof="authored" data-by="ai:claude">Try different query types or refine</span>  |

## <span data-proof="authored" data-by="ai:claude">Step 4: Retrieve Documents</span>

<span data-proof="authored" data-by="ai:claude">To read a full document from the results, use</span> <span data-proof="authored" data-by="ai:claude">`mcp__qmd__get`:</span>

```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MjAsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
{ "path": "#docid" }
```

<span data-proof="authored" data-by="ai:claude">Or by file path:</span>

```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NDUsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
{ "path": "collection_name/path/to/file.md" }
```

<span data-proof="authored" data-by="ai:claude">For multiple related documents, use</span> <span data-proof="authored" data-by="ai:claude">`mcp__qmd__multi_get`</span> <span data-proof="authored" data-by="ai:claude">to batch retrieve:</span>

```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NDIsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
{ "pattern": "collection_name/docs/*.md" }
```

<span data-proof="authored" data-by="ai:claude">This is faster than reading files one at a time.</span>

## <span data-proof="authored" data-by="ai:claude">Error Handling</span>

<span data-proof="authored" data-by="ai:claude">If MCP tools fail, diagnose the issue:</span>

| <span data-proof="authored" data-by="ai:claude">Error</span>                                                                                  | <span data-proof="authored" data-by="ai:claude">Likely cause</span>                  | <span data-proof="authored" data-by="ai:claude">Fix</span>                                                                                                                                                                                                                                                                                         |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <span data-proof="authored" data-by="ai:claude">`mcp__qmd__query`</span> <span data-proof="authored" data-by="ai:claude">not available</span> | <span data-proof="authored" data-by="ai:claude">MCP server not configured</span>     | <span data-proof="authored" data-by="ai:claude">Add</span> <span data-proof="authored" data-by="ai:claude">`"mcpServers": {"qmd": {"command": "qmd", "args": ["mcp"]}}`</span> <span data-proof="authored" data-by="ai:claude">to Claude Code settings. Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`.</span> |
| <span data-proof="authored" data-by="ai:claude">MCP call returns error</span>                                                                 | <span data-proof="authored" data-by="ai:claude">Server not running or crashed</span> | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`qmd mcp`</span> <span data-proof="authored" data-by="ai:claude">to verify. Check</span> <span data-proof="authored" data-by="ai:claude">`qmd status`.</span>                                                                           |
| <span data-proof="authored" data-by="ai:claude">Collection not found</span>                                                                   | <span data-proof="authored" data-by="ai:claude">Config out of sync</span>            | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-doctor`</span> <span data-proof="authored" data-by="ai:claude">to diagnose.</span>                                                                                                                                         |
| <span data-proof="authored" data-by="ai:claude">No results</span>                                                                             | <span data-proof="authored" data-by="ai:claude">Index empty or stale</span>          | <span data-proof="authored" data-by="ai:claude">Run</span> <span data-proof="authored" data-by="ai:claude">`qmd update && qmd embed`</span> <span data-proof="authored" data-by="ai:claude">to rebuild.</span>                                                                                                                                     |

## <span data-proof="authored" data-by="ai:claude">CLI Fallback</span>

<span data-proof="authored" data-by="ai:claude">If MCP tools are unavailable, fall back to the CLI. The</span> <span data-proof="authored" data-by="ai:claude">`qmd query`</span> <span data-proof="authored" data-by="ai:claude">command supports structured queries via multiline strings:</span>

```bash proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MTAzLCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
qmd query $'lex: exact keywords here\nvec: natural language question here' -c <collection> --json -n 10
```

<span data-proof="authored" data-by="ai:claude">This single command subsumes</span> <span data-proof="authored" data-by="ai:claude">`qmd search`</span> <span data-proof="authored" data-by="ai:claude">(BM25 only) and</span> <span data-proof="authored" data-by="ai:claude">`qmd vsearch`</span> <span data-proof="authored" data-by="ai:claude">(vector only). Always use</span> <span data-proof="authored" data-by="ai:claude">`--json`</span> <span data-proof="authored" data-by="ai:claude">for parseable output.</span>

## <span data-proof="authored" data-by="ai:claude">Fallback to Glob/Grep</span>

<span data-proof="authored" data-by="ai:claude">After 2 poor query attempts (different query types, refined terms), fall back to Glob/Grep on the collection's directory path from config. qmd can't find everything — sometimes a direct file search is faster.</span>