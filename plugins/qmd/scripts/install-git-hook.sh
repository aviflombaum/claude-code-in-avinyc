#!/bin/bash
# Install a git post-commit hook that auto-updates qmd index when .md files change.
# Usage: install-git-hook.sh <index-name>
# Idempotent: checks for marker comment before adding.

set -euo pipefail

INDEX_NAME="${1:?Usage: install-git-hook.sh <index-name>}"
HOOK_FILE=".git/hooks/post-commit"
MARKER="# qmd-auto-index:${INDEX_NAME}"

# Ensure .git/hooks exists
if [[ ! -d ".git/hooks" ]]; then
  echo "Error: not in a git repository (no .git/hooks directory)" >&2
  exit 1
fi

# Check if already installed
if [[ -f "$HOOK_FILE" ]] && grep -qF "$MARKER" "$HOOK_FILE"; then
  echo "qmd post-commit hook already installed for index '${INDEX_NAME}'"
  exit 0
fi

# Create hook file if it doesn't exist
if [[ ! -f "$HOOK_FILE" ]]; then
  echo '#!/bin/bash' > "$HOOK_FILE"
  chmod +x "$HOOK_FILE"
fi

# Ensure file is executable
chmod +x "$HOOK_FILE"

# Append hook logic
cat >> "$HOOK_FILE" << EOF

${MARKER}
# Auto-update qmd index when markdown files change
export PATH="\$HOME/.bun/bin:\$HOME/.local/bin:\$PATH"
if command -v qmd &>/dev/null; then
  if git diff-tree --no-commit-id --name-only -r HEAD | grep -q '\.md\$'; then
    (qmd update --index ${INDEX_NAME} && qmd embed --index ${INDEX_NAME}) &>/dev/null &
  fi
fi
EOF

echo "qmd post-commit hook installed for index '${INDEX_NAME}'"
