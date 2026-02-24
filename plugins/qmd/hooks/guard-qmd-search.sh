#!/bin/bash
# PreToolUse guard: enforce qmd-search before Glob/Grep/Task on indexed directories.
# Reads guardedDirs from .claude/qmd.json — exits 0 (allow) if no config or guard disabled.
# Exit 2 = block with message, Exit 0 = allow
# No external dependencies (no jq required).

set -euo pipefail

CONFIG_FILE=".claude/qmd.json"

# No config → allow everything (plugin not configured for this project)
if [[ ! -f "$CONFIG_FILE" ]]; then
  exit 0
fi

# Check guard flag — if false or missing, allow
if ! grep -q '"guard"[[:space:]]*:[[:space:]]*true' "$CONFIG_FILE" 2>/dev/null; then
  exit 0
fi

# Extract guardedDirs array entries via grep/tr (no jq)
# Handles both single-line and multi-line JSON arrays
escape_regex() {
  printf '%s' "$1" | sed 's/[.[\(*+?{|^$\\]/\\&/g'
}

GUARDED_PATTERN=""
# Flatten file, extract "guardedDirs":[...], pull out quoted strings, skip the key
GUARDED_DIRS=$(tr -d '\n' < "$CONFIG_FILE" | grep -o '"guardedDirs"[^]]*\]' | grep -o '"[^"]*"' | grep -v 'guardedDirs' | tr -d '"') || true

while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  escaped=$(escape_regex "$dir")
  if [[ -z "$GUARDED_PATTERN" ]]; then
    GUARDED_PATTERN="($escaped"
  else
    GUARDED_PATTERN="$GUARDED_PATTERN|$escaped"
  fi
done <<< "$GUARDED_DIRS"

# No guarded dirs → allow
if [[ -z "$GUARDED_PATTERN" ]]; then
  exit 0
fi
GUARDED_PATTERN="$GUARDED_PATTERN)"

# Read hook input from stdin
HOOK_DATA=$(cat)

# Extract JSON values via grep/sed (no jq)
# These patterns work on the single-line JSON that Claude Code sends to hooks.
extract_json_string() {
  local key="$1" data="$2"
  echo "$data" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*:[[:space:]]*"\(.*\)"/\1/'
}

TOOL_NAME=$(extract_json_string "tool_name" "$HOOK_DATA") || true
INPUT_PATH=$(extract_json_string "path" "$HOOK_DATA") || true
INPUT_PATTERN=$(extract_json_string "pattern" "$HOOK_DATA") || true
INPUT_PROMPT=$(extract_json_string "prompt" "$HOOK_DATA") || true

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
