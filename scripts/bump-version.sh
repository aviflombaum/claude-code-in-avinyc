#!/bin/bash
# ============================================================================
# Name:        bump-version.sh
# Version:     1.0.0
# Description: Bump plugin version in both plugin.json and marketplace.json
# Source:      claude-code-in-avinyc/scripts/bump-version.sh
# Usage:       ./scripts/bump-version.sh <plugin-name> <bump-type>
# Requires:    bash 4+, perl, sed
# Updated:     2026-03-13
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

PLUGIN_NAME="$1"
BUMP_TYPE="$2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <plugin-name> <bump-type>"
    echo ""
    echo "Arguments:"
    echo "  plugin-name  Name of the plugin directory in plugins/"
    echo "  bump-type    Type of version bump: patch, minor, or major"
    echo ""
    echo "Examples (using first available plugin):"
    first_plugin=$(ls -1 "$ROOT_DIR/plugins" 2>/dev/null | head -1)
    if [ -n "$first_plugin" ]; then
        echo "  $0 $first_plugin patch    # 1.2.0 -> 1.2.1"
        echo "  $0 $first_plugin minor    # 1.2.0 -> 1.3.0"
        echo "  $0 $first_plugin major    # 1.1.0 -> 2.0.0"
    fi
    echo ""
    echo "Available plugins:"
    ls -1 "$ROOT_DIR/plugins" 2>/dev/null | sed 's/^/  /'
    exit 1
}

# Validate arguments
if [ -z "$PLUGIN_NAME" ] || [ -z "$BUMP_TYPE" ]; then
    usage
fi

if [[ ! "$BUMP_TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo -e "${RED}Error: bump-type must be 'patch', 'minor', or 'major'${NC}"
    exit 1
fi

PLUGIN_JSON="$ROOT_DIR/plugins/$PLUGIN_NAME/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$ROOT_DIR/.claude-plugin/marketplace.json"

# Check plugin exists
if [ ! -f "$PLUGIN_JSON" ]; then
    echo -e "${RED}Error: Plugin '$PLUGIN_NAME' not found${NC}"
    echo "Expected: $PLUGIN_JSON"
    echo ""
    echo "Available plugins:"
    ls -1 "$ROOT_DIR/plugins" 2>/dev/null | sed 's/^/  /'
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep -o '"version": *"[^"]*"' "$PLUGIN_JSON" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${RED}Error: Could not read version from $PLUGIN_JSON${NC}"
    exit 1
fi

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Bump version
case "$BUMP_TYPE" in
    patch)
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"
        ;;
    minor)
        NEW_MINOR=$((MINOR + 1))
        NEW_VERSION="$MAJOR.$NEW_MINOR.0"
        ;;
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_VERSION="$NEW_MAJOR.0.0"
        ;;
esac

echo -e "${YELLOW}Bumping $PLUGIN_NAME: $CURRENT_VERSION -> $NEW_VERSION${NC}"

# Update plugin.json
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/\"version\": *\"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$PLUGIN_JSON"
else
    # Linux
    sed -i "s/\"version\": *\"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$PLUGIN_JSON"
fi

echo -e "${GREEN}Updated: $PLUGIN_JSON${NC}"

# Update marketplace.json - need to find the right plugin entry
# Using a more precise pattern to match only this plugin's version
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use perl for more precise multi-line matching
    perl -i -0pe "s/(\"name\": *\"$PLUGIN_NAME\"[^}]*\"version\": *)\"$CURRENT_VERSION\"/\$1\"$NEW_VERSION\"/" "$MARKETPLACE_JSON"
else
    # Linux
    perl -i -0pe "s/(\"name\": *\"$PLUGIN_NAME\"[^}]*\"version\": *)\"$CURRENT_VERSION\"/\$1\"$NEW_VERSION\"/" "$MARKETPLACE_JSON"
fi

echo -e "${GREEN}Updated: $MARKETPLACE_JSON${NC}"

# Verify the updates
PLUGIN_NEW=$(grep -o '"version": *"[^"]*"' "$PLUGIN_JSON" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
MARKETPLACE_NEW=$(grep -A5 "\"name\": *\"$PLUGIN_NAME\"" "$MARKETPLACE_JSON" | grep -o '"version": *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

echo ""
if [ "$PLUGIN_NEW" = "$NEW_VERSION" ] && [ "$MARKETPLACE_NEW" = "$NEW_VERSION" ]; then
    echo -e "${GREEN}Version bump successful.${NC}"
    echo "  plugin.json:      $NEW_VERSION"
    echo "  marketplace.json: $NEW_VERSION"
else
    echo -e "${RED}Warning: Version mismatch detected. Please verify manually.${NC}"
    echo "  plugin.json:      $PLUGIN_NEW"
    echo "  marketplace.json: $MARKETPLACE_NEW"
    exit 1
fi
