#!/bin/bash
# Install a git post-commit hook that auto-updates qmd index when .md files change.
# Usage: install-git-hook.sh <project-name>
# The project name is used in the marker comment for identification only.
# Idempotent: checks for marker comment before adding.

set -euo pipefail

PROJECT_NAME="${1:?Usage: install-git-hook.sh <project-name>}"
HOOK_FILE=".git/hooks/post-commit"
MARKER="# qmd-auto-index:${PROJECT_NAME}"

# Ensure .git/hooks exists
if [[ ! -d ".git/hooks" ]]; then
  echo "Error: not in a git repository (no .git/hooks directory)" >&2
  exit 1
fi

# Clean up old v1.0 hook blocks that contain --index
if [[ -f "$HOOK_FILE" ]]; then
  if grep -q 'qmd.*--index' "$HOOK_FILE"; then
    # Remove old blocks: from any qmd-auto-index marker through the closing fi
    sed -i '' '/^# qmd-auto-index/,/^fi$/d' "$HOOK_FILE"
    echo "Removed old v1.0 qmd hook block(s) with --index"
  fi
fi

# Check if already installed (current format)
if [[ -f "$HOOK_FILE" ]] && grep -qF "$MARKER" "$HOOK_FILE"; then
  echo "qmd post-commit hook already installed for project '${PROJECT_NAME}'"
  exit 0
fi

# Create hook file if it doesn't exist
if [[ ! -f "$HOOK_FILE" ]]; then
  echo '#!/bin/bash' > "$HOOK_FILE"
fi

# Ensure file is executable
chmod +x "$HOOK_FILE"

# Append hook logic — quoted heredoc so $HOME/$PATH are not expanded at install time
cat >> "$HOOK_FILE" << 'HOOK_EOF'

HOOK_EOF

# Now append with the marker (needs variable expansion for project name only)
cat >> "$HOOK_FILE" << EOF
${MARKER}
# Auto-update qmd index when markdown files change
EOF

# Rest uses quoted heredoc — no variable expansion
cat >> "$HOOK_FILE" << 'HOOK_EOF'
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"
if command -v qmd &>/dev/null; then
  if git diff-tree --no-commit-id --name-only -r HEAD | grep -q '\.md$'; then
    (qmd update && qmd embed) &>/dev/null &
  fi
fi
HOOK_EOF

echo "qmd post-commit hook installed for project '${PROJECT_NAME}'"
