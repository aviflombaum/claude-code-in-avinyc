#!/bin/bash
# Derive a canonical qmd project name from the git repository folder name.
# Output: lowercase, non-alnum replaced with underscore, collapsed, trimmed.
# Usage: qmd-derive-name.sh
# Exit 0: prints name to stdout
# Exit 1: not in a git repository

set -euo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Error: not in a git repository" >&2
  exit 1
}

FOLDER=$(basename "$ROOT")
NAME=$(echo "$FOLDER" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g; s/__*/_/g; s/^_//; s/_$//')

echo "$NAME"
