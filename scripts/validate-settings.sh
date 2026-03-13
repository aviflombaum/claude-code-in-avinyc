#!/bin/bash
# ============================================================================
# Name:        validate-settings.sh
# Version:     1.0.0
# Description: Validate settings.local.json has all plugins enabled for local testing
# Source:      claude-code-in-avinyc/scripts/validate-settings.sh
# Usage:       ./scripts/validate-settings.sh [marketplace-name]
# Requires:    bash 4+, node (python3 fallback)
# Updated:     2026-03-13
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# Auto-detect marketplace name from marketplace.json, or use $1
if [ -n "$1" ]; then
    MARKETPLACE_NAME="$1"
else
    MARKETPLACE_NAME=$(node -e "const d=require('$ROOT_DIR/.claude-plugin/marketplace.json');console.log(d.name)" 2>/dev/null || grep -o '"name": *"[^"]*"' "$ROOT_DIR/.claude-plugin/marketplace.json" | head -1 | sed 's/"name": *"\([^"]*\)"/\1/')
fi
MARKETPLACE_JSON="$ROOT_DIR/.claude-plugin/marketplace.json"
LOCAL_SETTINGS="$ROOT_DIR/.claude/settings.local.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ERRORS=0

echo "Validating settings.local.json completeness..."
echo ""

if [ ! -f "$LOCAL_SETTINGS" ]; then
    echo -e "${RED}Error: $LOCAL_SETTINGS not found${NC}"
    echo "Run ./scripts/setup-local-dev.sh to create it"
    exit 1
fi

# Get list of all plugins from marketplace.json (only from plugins array, not author names)
PLUGINS=$(node -e "
const data = require('$MARKETPLACE_JSON');
data.plugins.forEach(p => console.log(p.name));
" 2>/dev/null || grep -o '"name": *"[^"]*"' "$MARKETPLACE_JSON" | head -20 | sed 's/"name": *"\([^"]*\)"/\1/' | grep -v "$MARKETPLACE_NAME" | grep -v "Avi" | grep -v "Flombaum")

echo "Checking plugin enablement..."

for plugin in $PLUGINS; do
    key="${plugin}@${MARKETPLACE_NAME}"

    # Check if plugin is in settings.local.json
    if grep -q "\"$key\"" "$LOCAL_SETTINGS"; then
        echo -e "${GREEN}  OK: $plugin${NC}"
    else
        echo -e "${RED}  Missing: $plugin${NC}"
        echo "    Add to settings.local.json: \"$key\": true"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# Summary
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation failed: $ERRORS plugin(s) not enabled${NC}"
    echo ""
    echo "Fix by running: ./scripts/setup-local-dev.sh"
    exit 1
else
    echo -e "${GREEN}All plugins enabled in settings.local.json${NC}"
    exit 0
fi
