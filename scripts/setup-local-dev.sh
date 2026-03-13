#!/bin/bash
# ============================================================================
# Name:        setup-local-dev.sh
# Version:     1.0.0
# Description: Configure Claude Code to load marketplace from local directory
# Source:      claude-code-in-avinyc/scripts/setup-local-dev.sh
# Usage:       ./scripts/setup-local-dev.sh [marketplace-name] [github-repo]
# Requires:    bash 4+, node
# Updated:     2026-03-13
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# Auto-detect or use args
if [ -n "$1" ]; then
    MARKETPLACE_NAME="$1"
else
    MARKETPLACE_NAME=$(node -e "const d=require('$ROOT_DIR/.claude-plugin/marketplace.json');console.log(d.name)" 2>/dev/null || grep -o '"name": *"[^"]*"' "$ROOT_DIR/.claude-plugin/marketplace.json" | head -1 | sed 's/"name": *"\([^"]*\)"/\1/')
fi
KNOWN_MARKETPLACES="$HOME/.claude/plugins/known_marketplaces.json"
LOCAL_SETTINGS="$ROOT_DIR/.claude/settings.local.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "Setting up local development for $MARKETPLACE_NAME..."
echo ""

# Step 1: Update known_marketplaces.json
echo "Step 1: Configuring marketplace source..."

if [ ! -f "$KNOWN_MARKETPLACES" ]; then
    echo -e "${RED}Error: $KNOWN_MARKETPLACES not found${NC}"
    echo "Make sure Claude Code is installed and has been run at least once."
    exit 1
fi

# Check current source type
current_source=$(grep -A3 "\"$MARKETPLACE_NAME\"" "$KNOWN_MARKETPLACES" | grep '"source":' | head -1 | grep -o '"source": *"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/' || echo "not found")

if [ "$current_source" = "directory" ]; then
    echo -e "${GREEN}  Already configured for local development${NC}"
else
    # Use node/jq to update JSON properly
    if command -v node &> /dev/null; then
        node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$KNOWN_MARKETPLACES', 'utf8'));
data['$MARKETPLACE_NAME'] = {
    source: { source: 'directory', path: '$ROOT_DIR' },
    installLocation: '$ROOT_DIR',
    lastUpdated: new Date().toISOString(),
    autoUpdate: true
};
fs.writeFileSync('$KNOWN_MARKETPLACES', JSON.stringify(data, null, 2));
"
        echo -e "${GREEN}  Updated to use local directory${NC}"
    else
        echo -e "${YELLOW}  Node.js not found. Please manually update $KNOWN_MARKETPLACES${NC}"
        echo "  Change source from 'github' to 'directory' with path: $ROOT_DIR"
    fi
fi

echo ""

# Step 2: Ensure all plugins are enabled in settings.local.json
echo "Step 2: Enabling all plugins in local settings..."

# Get list of all plugins from marketplace.json (using node for proper JSON parsing)
PLUGINS=$(node -e "
const data = require('$ROOT_DIR/.claude-plugin/marketplace.json');
data.plugins.forEach(p => console.log(p.name));
" 2>/dev/null)

if command -v node &> /dev/null; then
    # Create or update settings.local.json
    if [ ! -f "$LOCAL_SETTINGS" ]; then
        echo '{}' > "$LOCAL_SETTINGS"
    fi

    node -e "
const fs = require('fs');
const plugins = \`$PLUGINS\`.trim().split('\n').filter(p => p);
const settings = JSON.parse(fs.readFileSync('$LOCAL_SETTINGS', 'utf8'));

if (!settings.enabledPlugins) {
    settings.enabledPlugins = {};
}

let added = 0;
plugins.forEach(plugin => {
    const key = plugin + '@$MARKETPLACE_NAME';
    if (!settings.enabledPlugins[key]) {
        settings.enabledPlugins[key] = true;
        added++;
    }
});

fs.writeFileSync('$LOCAL_SETTINGS', JSON.stringify(settings, null, 2) + '\n');
console.log('  Added ' + added + ' plugin(s), ' + (plugins.length - added) + ' already enabled');
"
else
    echo -e "${YELLOW}  Node.js not found. Please manually add plugins to $LOCAL_SETTINGS${NC}"
fi

echo ""
echo -e "${GREEN}Local development setup complete.${NC}"
echo ""
echo "Next steps:"
echo "  1. Start a new Claude Code session in this directory"
echo "  2. Run /plugins to verify all plugins are loaded"
echo "  3. Changes to plugin files will be reflected immediately"
