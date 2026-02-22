#!/bin/bash
# PreToolUse guard: enforce qmd-search skill before Glob/Grep/Task on indexed directories.
# Reads guardedDirs from .claude/qmd.json — exits 0 (allow) if no config or guard disabled.
# Exit 2 = block with message, Exit 0 = allow

set -euo pipefail

CONFIG_FILE=".claude/qmd.json"

# No config → allow everything (plugin not configured for this project)
if [[ ! -f "$CONFIG_FILE" ]]; then
  exit 0
fi

# Check guard flag — if false or missing, allow
GUARD=$(jq -r '.guard // false' "$CONFIG_FILE" 2>/dev/null)

if [[ "$GUARD" != "true" ]]; then
  exit 0
fi

# Read guarded dirs and build regex pattern (properly escaping metacharacters)
escape_regex() {
  printf '%s' "$1" | sed 's/[.[\(*+?{|^$\\]/\\&/g'
}

GUARDED_PATTERN=""
while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  escaped=$(escape_regex "$dir")
  if [[ -z "$GUARDED_PATTERN" ]]; then
    GUARDED_PATTERN="($escaped"
  else
    GUARDED_PATTERN="$GUARDED_PATTERN|$escaped"
  fi
done < <(jq -r '.guardedDirs[]? // empty' "$CONFIG_FILE" 2>/dev/null)

# No guarded dirs → allow
if [[ -z "$GUARDED_PATTERN" ]]; then
  exit 0
fi
GUARDED_PATTERN="$GUARDED_PATTERN)"

# Parse hook input via jq
HOOK_DATA=$(cat)
TOOL_NAME=$(echo "$HOOK_DATA" | jq -r '.tool_name // ""' 2>/dev/null)
INPUT_PATH=$(echo "$HOOK_DATA" | jq -r '.tool_input.path // ""' 2>/dev/null)
INPUT_PATTERN=$(echo "$HOOK_DATA" | jq -r '.tool_input.pattern // ""' 2>/dev/null)
INPUT_PROMPT=$(echo "$HOOK_DATA" | jq -r '.tool_input.prompt // ""' 2>/dev/null)

# Check if a value targets a guarded directory
targets_guarded_dir() {
  local val="$1"
  [[ -z "$val" ]] && return 1
  echo "$val" | grep -qE "(^|/)${GUARDED_PATTERN}(/|$)"
}

MSG="BLOCKED: Use /qmd:search first to search indexed directories. It provides BM25-ranked results that are faster and more relevant. Fall back to Glob/Grep only after qmd-search returns poor results."

case "$TOOL_NAME" in
  Glob|Grep)
    if targets_guarded_dir "$INPUT_PATH" || targets_guarded_dir "$INPUT_PATTERN"; then
      echo "$MSG" >&2
      exit 2
    fi
    ;;
  Task)
    if echo "$INPUT_PROMPT" | grep -qiE "(search|explore|find|look|scan).{0,20}${GUARDED_PATTERN}"; then
      echo "$MSG" >&2
      exit 2
    fi
    ;;
esac

exit 0
