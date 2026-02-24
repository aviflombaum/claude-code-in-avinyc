#!/bin/bash
# QMD Doctor: comprehensive health check for qmd plugin configuration.
# Calls wrapper scripts internally — never calls qmd directly.
# Usage: qmd-doctor.sh
# Output: diagnostic report with [PASS], [FAIL], [WARN] prefixes
# Exit 0: all checks pass, Exit 1: one or more failures

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG=".claude/qmd.json"
GLOBAL_YAML="$HOME/.config/qmd/index.yml"
GLOBAL_DB="$HOME/.cache/qmd/index.sqlite"
FAILURES=0

check() {
  local status="$1" msg="$2"
  if [[ "$status" == "PASS" ]]; then
    echo "[PASS] $msg"
  elif [[ "$status" == "WARN" ]]; then
    echo "[WARN] $msg"
  else
    echo "[FAIL] $msg"
    FAILURES=$((FAILURES + 1))
  fi
}

# 1. qmd binary
if command -v qmd &>/dev/null; then
  check "PASS" "qmd binary found: $(command -v qmd)"
else
  check "FAIL" "qmd binary not found — install with: bun install -g @tobilu/qmd"
fi

# 2. Project config exists
if [[ ! -f "$CONFIG" ]]; then
  check "FAIL" ".claude/qmd.json not found — run /qmd:configure"
  echo ""
  echo "$FAILURES issue(s) found."
  exit 1
fi
check "PASS" ".claude/qmd.json exists"

# 3. Valid JSON
if ! jq empty "$CONFIG" 2>/dev/null; then
  check "FAIL" ".claude/qmd.json is not valid JSON"
  echo ""
  echo "$FAILURES issue(s) found."
  exit 1
fi
check "PASS" ".claude/qmd.json is valid JSON"

# 4. Has "project" field
PROJECT=$(jq -r '.project // empty' "$CONFIG" 2>/dev/null)
if [[ -n "$PROJECT" ]]; then
  check "PASS" "Project name: $PROJECT"
else
  check "FAIL" "No 'project' field in .claude/qmd.json — run /qmd:configure"
fi

# 5. Default index DB
if [[ -f "$GLOBAL_DB" ]]; then
  check "PASS" "Default index database exists: $GLOBAL_DB"
else
  check "FAIL" "Default index database missing: $GLOBAL_DB"
fi

# 6. Global YAML config
if [[ -f "$GLOBAL_YAML" ]]; then
  check "PASS" "Global config exists: $GLOBAL_YAML"
else
  check "FAIL" "Global config missing: $GLOBAL_YAML"
fi

# 7-8. Collection checks via wrapper script
COLLECTIONS=$(jq -r '.collections | keys[]' "$CONFIG" 2>/dev/null)
QMD_LIST=$("$SCRIPT_DIR/qmd-list-collections.sh" 2>/dev/null || echo "")

for col in $COLLECTIONS; do
  # 7. Collection in qmd
  if echo "$QMD_LIST" | grep -qF "$col"; then
    check "PASS" "Collection '$col' found in qmd index"
  else
    check "FAIL" "Collection '$col' NOT in qmd index — run /qmd:configure"
  fi

  # 9. Naming convention
  if [[ -n "$PROJECT" ]]; then
    if [[ "$col" == "${PROJECT}_"* ]]; then
      check "PASS" "Collection '$col' follows naming convention"
    else
      check "WARN" "Collection '$col' does not start with '${PROJECT}_'"
    fi
  fi
done

# 10-11. Git hook checks
GIT_HOOK=$(jq -r '.gitHook // false' "$CONFIG" 2>/dev/null)
if [[ "$GIT_HOOK" == "true" ]]; then
  HOOK_FILE=".git/hooks/post-commit"
  if [[ -f "$HOOK_FILE" ]]; then
    if [[ -n "$PROJECT" ]] && grep -qF "# qmd-auto-index:${PROJECT}" "$HOOK_FILE"; then
      check "PASS" "Git post-commit hook installed for '$PROJECT'"
    elif grep -qF "# qmd-auto-index" "$HOOK_FILE"; then
      check "WARN" "Git hook installed but marker doesn't match project '$PROJECT'"
    else
      check "FAIL" "gitHook is true but post-commit hook has no qmd marker"
    fi
    # 11. Check for old --index flag
    if grep -q '\-\-index' "$HOOK_FILE"; then
      check "WARN" "Git hook contains old --index flag — reinstall with install-git-hook.sh"
    else
      check "PASS" "Git hook uses default index (no --index)"
    fi
  else
    check "FAIL" "gitHook is true but .git/hooks/post-commit not found"
  fi
fi

# 12. Guard config consistency
GUARD=$(jq -r '.guard // false' "$CONFIG" 2>/dev/null)
if [[ "$GUARD" == "true" ]]; then
  GUARDED_COUNT=$(jq -r '.guardedDirs | length' "$CONFIG" 2>/dev/null)
  if [[ "$GUARDED_COUNT" -gt 0 ]]; then
    check "PASS" "Guard enabled with $GUARDED_COUNT guarded directories"
  else
    check "WARN" "Guard enabled but guardedDirs is empty"
  fi
fi

# 13. YAML config has matching entries
if [[ -f "$GLOBAL_YAML" ]]; then
  for col in $COLLECTIONS; do
    if grep -qF "$col:" "$GLOBAL_YAML"; then
      check "PASS" "YAML config has entry for '$col'"
    else
      check "FAIL" "YAML config missing entry for '$col'"
    fi
  done
fi

# Summary
echo ""
if [[ $FAILURES -eq 0 ]]; then
  echo "All checks passed."
else
  echo "$FAILURES issue(s) found."
fi

exit $([[ $FAILURES -eq 0 ]] && echo 0 || echo 1)
