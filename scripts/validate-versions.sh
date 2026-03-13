#!/bin/bash
# ============================================================================
# Name:        validate-versions.sh
# Version:     1.0.0
# Description: Validate plugin versions are consistent and bumped when needed
# Source:      claude-code-in-avinyc/scripts/validate-versions.sh
# Usage:       ./scripts/validate-versions.sh [base-branch]
# Requires:    bash 4+, git
# Updated:     2026-03-13
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BASE_BRANCH="${1:-main}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ERRORS=0

echo "Validating plugin versions..."
echo ""

# Check 1: Version consistency between plugin.json and marketplace.json
echo "Checking version consistency..."

for plugin_dir in "$ROOT_DIR"/plugins/*/; do
    plugin_name=$(basename "$plugin_dir")
    plugin_json="$plugin_dir.claude-plugin/plugin.json"

    if [ ! -f "$plugin_json" ]; then
        echo -e "${RED}  Missing: $plugin_json${NC}"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # Get version from plugin.json
    plugin_version=$(grep -o '"version": *"[^"]*"' "$plugin_json" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

    # Get version from marketplace.json
    marketplace_version=$(grep -A5 "\"name\": *\"$plugin_name\"" "$ROOT_DIR/.claude-plugin/marketplace.json" | grep -o '"version": *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

    if [ "$plugin_version" != "$marketplace_version" ]; then
        echo -e "${RED}  Mismatch: $plugin_name${NC}"
        echo "    plugin.json:      $plugin_version"
        echo "    marketplace.json: $marketplace_version"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}  OK: $plugin_name ($plugin_version)${NC}"
    fi
done

echo ""

# Check 2: If plugin files changed, version should be bumped
echo "Checking for unbumped changes..."

# Only run this check if we're in a git repo and have a base branch to compare
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Check if base branch exists
    if git rev-parse --verify "$BASE_BRANCH" > /dev/null 2>&1; then

        for plugin_dir in "$ROOT_DIR"/plugins/*/; do
            plugin_name=$(basename "$plugin_dir")
            plugin_json="$plugin_dir.claude-plugin/plugin.json"

            # Get changed files in this plugin (excluding plugin.json itself)
            changed_files=$(git diff --name-only "$BASE_BRANCH" -- "$plugin_dir" 2>/dev/null | grep -v "plugin.json" || true)

            if [ -n "$changed_files" ]; then
                # Plugin has changes - check if version was bumped
                version_changed=$(git diff "$BASE_BRANCH" -- "$plugin_json" 2>/dev/null | grep '"version"' || true)

                if [ -z "$version_changed" ]; then
                    echo -e "${RED}  Unbumped: $plugin_name${NC}"
                    echo "    Changed files:"
                    echo "$changed_files" | sed 's/^/      /'
                    echo "    Run: ./scripts/bump-version.sh $plugin_name patch"
                    ERRORS=$((ERRORS + 1))
                else
                    echo -e "${GREEN}  OK: $plugin_name (version bumped)${NC}"
                fi
            fi
        done
    else
        echo -e "${YELLOW}  Skipped: Base branch '$BASE_BRANCH' not found${NC}"
    fi
else
    echo -e "${YELLOW}  Skipped: Not a git repository${NC}"
fi

echo ""

# Summary
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation failed with $ERRORS error(s)${NC}"
    exit 1
else
    echo -e "${GREEN}All validations passed.${NC}"
    exit 0
fi
