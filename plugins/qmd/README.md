# <span data-proof="authored" data-by="ai:claude">qmd Plugin</span>

<span data-proof="authored" data-by="ai:claude">Semantic search for any project's documentation using qmd's MCP tools. Interviews you on first use, configures collections in the default qmd index, and provides fast MCP-powered search from that point forward.</span>

## <span data-proof="authored" data-by="ai:claude">Prerequisites</span>

* [<span data-proof="authored" data-by="ai:claude">qmd</span>](https://github.com/tobi/qmd) <span data-proof="authored" data-by="ai:claude">2.0+ installed (`npm install -g @tobilu/qmd`)</span>

* <span data-proof="authored" data-by="ai:claude">qmd MCP server configured in Claude Code settings (recommended for best performance)</span>

## <span data-proof="authored" data-by="ai:claude">Installation</span>

<span data-proof="authored" data-by="ai:claude">Enable</span> <span data-proof="authored" data-by="ai:claude">`qmd@claude-code-in-avinyc`</span> <span data-proof="authored" data-by="ai:claude">in your Claude Code settings.</span>

## <span data-proof="authored" data-by="ai:claude">Skills</span>

| <span data-proof="authored" data-by="ai:claude">Skill</span>     | <span data-proof="authored" data-by="ai:claude">Invocation</span>                   | <span data-proof="authored" data-by="ai:claude">Purpose</span>                                    |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| <span data-proof="authored" data-by="ai:claude">search</span>    | <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-search <query>`</span> | <span data-proof="authored" data-by="ai:claude">Search indexed collections via MCP</span>         |
| <span data-proof="authored" data-by="ai:claude">configure</span> | <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`</span>      | <span data-proof="authored" data-by="ai:claude">Set up or reconfigure qmd for this project</span> |
| <span data-proof="authored" data-by="ai:claude">status</span>    | <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-status`</span>         | <span data-proof="authored" data-by="ai:claude">Show project config and index status</span>       |
| <span data-proof="authored" data-by="ai:claude">doctor</span>    | <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-doctor`</span>         | <span data-proof="authored" data-by="ai:claude">Run health check</span>                           |

<span data-proof="authored" data-by="ai:claude">All skills are user-invocable only (not auto-triggered).</span>

### <span data-proof="authored" data-by="ai:claude">Configure (first run)</span>

```
/avinyc:qmd-configure
```

<span data-proof="authored" data-by="ai:claude">Interactive interview that:</span>

1. <span data-proof="authored" data-by="ai:claude">Checks qmd is installed and MCP server is configured</span>
2. <span data-proof="authored" data-by="ai:claude">Derives project name from git folder (user can override)</span>
3. <span data-proof="authored" data-by="ai:claude">Detects indexable directories (`docs/`,</span> <span data-proof="authored" data-by="ai:claude">`plans/`,</span> <span data-proof="authored" data-by="ai:claude">`tasks/`, etc.)</span>
4. <span data-proof="authored" data-by="ai:claude">Asks which to index and what each contains</span>
5. <span data-proof="authored" data-by="ai:claude">Adds collections to the default qmd index</span>
6. <span data-proof="authored" data-by="ai:claude">Writes</span> <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`</span> <span data-proof="authored" data-by="ai:claude">with project config</span>
7. <span data-proof="authored" data-by="ai:claude">Generates embeddings</span>
8. <span data-proof="authored" data-by="ai:claude">Optionally installs git post-commit hook for auto-reindex</span>

<span data-proof="authored" data-by="ai:claude">Idempotent — run again to reconfigure.</span>

### <span data-proof="authored" data-by="ai:claude">Search</span>

```
/avinyc:qmd-search how does authentication work
/avinyc:qmd-search deployment configuration
```

<span data-proof="authored" data-by="ai:claude">Uses qmd's MCP tools with structured queries (lex + vec + hyde) for best results. The skill reads your project config to target the right collection, constructs multi-type queries with intent disambiguation, and retrieves documents via MCP</span> <span data-proof="authored" data-by="ai:claude">`get`/`multi_get`.</span>

<span data-proof="authored" data-by="ai:claude">Falls back to CLI if MCP is unavailable.</span>

### <span data-proof="authored" data-by="ai:claude">Status</span>

```
/avinyc:qmd-status
```

<span data-proof="authored" data-by="ai:claude">Shows project config alongside live index health via MCP.</span>

### <span data-proof="authored" data-by="ai:claude">Doctor</span>

```
/avinyc:qmd-doctor
```

<span data-proof="authored" data-by="ai:claude">Runs checks for: qmd binary, config validity, collection existence, naming conventions, git hook state, YAML/SQLite sync, and MCP server connectivity.</span>

## <span data-proof="authored" data-by="ai:claude">Config Format</span>

<span data-proof="authored" data-by="ai:claude">Per-project config at</span> <span data-proof="authored" data-by="ai:claude">`.claude/qmd.json`:</span>

```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6MjcwLCJhdHRycyI6eyJieSI6ImFpOmNsYXVkZSJ9fV0=
{
  "project": "myproject",
  "collections": {
    "myproject_docs": { "path": "docs", "pattern": "**/*.md", "description": "Project docs" },
    "myproject_plans": { "path": "plans", "pattern": "**/*.md", "description": "Implementation plans" }
  },
  "gitHook": true
}
```

<span data-proof="authored" data-by="ai:claude">Collection naming convention:</span> <span data-proof="authored" data-by="ai:claude">`{project}_{type}`</span> <span data-proof="authored" data-by="ai:claude">with underscores. All collections live in the default qmd index (`~/.cache/qmd/index.sqlite`).</span>

## <span data-proof="authored" data-by="ai:claude">MCP Setup</span>

<span data-proof="authored" data-by="ai:claude">For best performance, configure qmd's MCP server in your Claude Code settings:</span>

```json proof:W3sidHlwZSI6InByb29mQXV0aG9yZWQiLCJmcm9tIjowLCJ0byI6NzQsImF0dHJzIjp7ImJ5IjoiYWk6Y2xhdWRlIn19XQ==
{
  "mcpServers": {
    "qmd": { "command": "qmd", "args": ["mcp"] }
  }
}
```

<span data-proof="authored" data-by="ai:claude">The MCP server keeps qmd's GGUF models (~3GB) warm between queries, making subsequent searches significantly faster than CLI cold-starts.</span>

## <span data-proof="authored" data-by="ai:claude">Git Post-Commit Hook</span>

<span data-proof="authored" data-by="ai:claude">When enabled via</span> <span data-proof="authored" data-by="ai:claude">`/avinyc:qmd-configure`, auto-runs</span> <span data-proof="authored" data-by="ai:claude">`qmd update && qmd embed`</span> <span data-proof="authored" data-by="ai:claude">in the background on commits that touch</span> <span data-proof="authored" data-by="ai:claude">`.md`</span> <span data-proof="authored" data-by="ai:claude">files.</span>

## <span data-proof="authored" data-by="ai:claude">Scripts</span>

<span data-proof="authored" data-by="ai:claude">Utility scripts in</span> <span data-proof="authored" data-by="ai:claude">`scripts/`</span> <span data-proof="authored" data-by="ai:claude">used by configure and doctor:</span>

| <span data-proof="authored" data-by="ai:claude">Script</span>                     | <span data-proof="authored" data-by="ai:claude">Purpose</span>                                                                                                                                                |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <span data-proof="authored" data-by="ai:claude">`install-git-hook.sh`</span>      | <span data-proof="authored" data-by="ai:claude">Git post-commit hook installer</span>                                                                                                                         |
| <span data-proof="authored" data-by="ai:claude">`qmd-add-collection.sh`</span>    | <span data-proof="authored" data-by="ai:claude">`qmd collection add`</span> <span data-proof="authored" data-by="ai:claude">+</span> <span data-proof="authored" data-by="ai:claude">`qmd context add`</span> |
| <span data-proof="authored" data-by="ai:claude">`qmd-remove-collection.sh`</span> | <span data-proof="authored" data-by="ai:claude">`qmd collection remove`</span>                                                                                                                                |
| <span data-proof="authored" data-by="ai:claude">`qmd-list-collections.sh`</span>  | <span data-proof="authored" data-by="ai:claude">`qmd collection list`</span>                                                                                                                                  |
| <span data-proof="authored" data-by="ai:claude">`qmd-index.sh`</span>             | <span data-proof="authored" data-by="ai:claude">`qmd update`</span> <span data-proof="authored" data-by="ai:claude">+</span> <span data-proof="authored" data-by="ai:claude">`qmd embed`</span>               |
| <span data-proof="authored" data-by="ai:claude">`qmd-derive-name.sh`</span>       | <span data-proof="authored" data-by="ai:claude">Project name from git folder</span>                                                                                                                           |