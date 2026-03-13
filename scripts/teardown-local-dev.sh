#!/bin/bash
# ============================================================================
# Name:        teardown-local-dev.sh
# Version:     1.0.0
# Description: Revert marketplace to load from GitHub instead of local directory
# Source:      claude-code-in-avinyc/scripts/teardown-local-dev.sh
# Usage:       ./scripts/teardown-local-dev.sh [marketplace-name] [github-repo]
# Requires:    bash 4+, node
# Updated:     2026-03-13
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Auto-detect or use args
if [ -n "$1" ]; then
    MARKETPLACE_NAME="$1"
else
    MARKETPLACE_NAME=$(node -e "const d=require('$ROOT_DIR/.claude-plugin/marketplace.json');console.log(d.name)" 2>/dev/null || grep -o '"name": *"[^"]*"' "$ROOT_DIR/.claude-plugin/marketplace.json" | head -1 | sed 's/"name": *"\([^"]*\)"/\1/')
fi
GITHUB_REPO="${2:-}"
if [ -z "$GITHUB_REPO" ]; then
    # Try to detect from git remote
    GITHUB_REPO=$(cd "$ROOT_DIR" && git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$||' || echo "")
fi
if [ -z "$GITHUB_REPO" ]; then
    echo -e "${RED}Error: Cannot detect GitHub repo. Pass as second argument.${NC}"
    exit 1
fi
KNOWN_MARKETPLACES="$HOME/.claude/plugins/known_marketplaces.json"

echo "Reverting to GitHub source for $MARKETPLACE_NAME..."
echo ""

if [ ! -f "$KNOWN_MARKETPLACES" ]; then
    echo -e "${RED}Error: $KNOWN_MARKETPLACES not found${NC}"
    echo "Nothing to revert."
    exit 1
fi

# Check current source type
current_source=$(grep -A3 "\"$MARKETPLACE_NAME\"" "$KNOWN_MARKETPLACES" | grep '"source":' | head -1 | grep -o '"source": *"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/' || echo "not found")

if [ "$current_source" = "github" ]; then
    echo -e "${GREEN}Already configured for GitHub${NC}"
    exit 0
fi

if [ "$current_source" = "not found" ]; then
    echo -e "${YELLOW}Marketplace not found in known_marketplaces.json${NC}"
    exit 0
fi

# Use node to update JSON properly
if command -v node &> /dev/null; then
    node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$KNOWN_MARKETPLACES', 'utf8'));
if (data['$MARKETPLACE_NAME']) {
    data['$MARKETPLACE_NAME'].source = {
        source: 'github',
        repo: '$GITHUB_REPO'
    };
    data['$MARKETPLACE_NAME'].lastUpdated = new Date().toISOString();
    fs.writeFileSync('$KNOWN_MARKETPLACES', JSON.stringify(data, null, 2));
}
"
    echo -e "${GREEN}Reverted to GitHub source${NC}"
else
    echo -e "${YELLOW}Node.js not found. Please manually update $KNOWN_MARKETPLACES${NC}"
    echo "Change source from 'directory' to 'github' with repo: $GITHUB_REPO"
    exit 1
fi

echo ""
echo -e "${GREEN}Teardown complete.${NC}"
echo ""
echo "Next steps:"
echo "  1. Start a new Claude Code session"
echo "  2. Plugins will now load from GitHub"
