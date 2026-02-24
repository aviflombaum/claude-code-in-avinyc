#!/bin/bash
# PreToolUse guard: block direct qmd CLI usage, enforce wrapper scripts.
# Reads .claude/qmd.json — exits 0 (allow) if no config (plugin not active).
# Self-discovers plugin root via BASH_SOURCE to provide actual paths in block messages.
# Exit 2 = block with message, Exit 0 = allow

set -euo pipefail

CONFIG_FILE=".claude/qmd.json"

# No config → allow everything (plugin not configured for this project)
if [[ ! -f "$CONFIG_FILE" ]]; then
  exit 0
fi

# Self-discover plugin root (hooks/ is one level below plugin root)
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$HOOK_DIR/.." && pwd)"
SCRIPTS="$PLUGIN_ROOT/scripts"

# Parse hook input
HOOK_DATA=$(cat)
COMMAND=$(echo "$HOOK_DATA" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Empty command → allow
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Allow commands that go through wrapper scripts (scripts/ directory)
# Matches: bash .../scripts/qmd-*.sh, bash .../scripts/install-git-hook.sh
if echo "$COMMAND" | grep -qE '(scripts/qmd-|scripts/install-git-hook)'; then
  exit 0
fi

# Allow: diagnostic commands (install checks, version, help)
if echo "$COMMAND" | grep -qE '(command -v qmd|which qmd|qmd --version|qmd --help)'; then
  exit 0
fi

# Block: any direct qmd command (qmd search, qmd update, qmd embed, etc.)
# Matches: "qmd ...", and piped/chained variants
if echo "$COMMAND" | grep -qE '(^|[;&|] *)qmd '; then
  cat >&2 <<EOF
BLOCKED: Direct qmd CLI usage is not allowed. Use the wrapper scripts at: $SCRIPTS/

  Search (BM25):    bash $SCRIPTS/qmd-search.sh "<query>" "<collection>" 5
  Search (vector):  bash $SCRIPTS/qmd-vsearch.sh "<query>" "<collection>" 5
  Add collection:   bash $SCRIPTS/qmd-add-collection.sh "<name>" "<path>" "<pattern>" "<desc>"
  Remove collection: bash $SCRIPTS/qmd-remove-collection.sh "<name>"
  List collections: bash $SCRIPTS/qmd-list-collections.sh
  Re-index:         bash $SCRIPTS/qmd-index.sh
  Status:           bash $SCRIPTS/qmd-status.sh
  Health check:     bash $SCRIPTS/qmd-doctor.sh
  Derive name:      bash $SCRIPTS/qmd-derive-name.sh
EOF
  exit 2
fi

exit 0
