#!/bin/bash
# ============================================================================
# Name:        validate-marketplace.sh
# Version:     1.0.0
# Description: Comprehensive 10-check validation for Claude Code marketplaces
# Source:      claude-code-in-avinyc/scripts/validate-marketplace.sh
# Usage:       ./scripts/validate-marketplace.sh [marketplace-root] [--ci]
# Requires:    bash 4+, node (python3 fallback)
# Updated:     2026-03-13
# ============================================================================

# --- Configuration ---
CI_MODE=false
ROOT_DIR=""

for arg in "$@"; do
    if [ "$arg" = "--ci" ]; then
        CI_MODE=true
    elif [ -z "$ROOT_DIR" ] && [ "$arg" != "--ci" ]; then
        ROOT_DIR="$arg"
    fi
done

# Auto-detect marketplace root: walk up from script location
if [ -z "$ROOT_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    candidate="$SCRIPT_DIR"
    while [ "$candidate" != "/" ]; do
        if [ -f "$candidate/.claude-plugin/marketplace.json" ]; then
            ROOT_DIR="$candidate"
            break
        fi
        candidate="$(dirname "$candidate")"
    done
fi

if [ -z "$ROOT_DIR" ] || [ ! -f "$ROOT_DIR/.claude-plugin/marketplace.json" ]; then
    echo "Error: Cannot find marketplace root (no .claude-plugin/marketplace.json found)."
    echo "Usage: $0 [marketplace-root] [--ci]"
    exit 1
fi

# --- Colors ---
if [ "$CI_MODE" = true ]; then
    RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
    CHECK_MARK="OK"
    CROSS_MARK="FAIL"
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
    CHECK_MARK="\xe2\x9c\x93"
    CROSS_MARK="\xe2\x9c\x97"
fi

# --- JSON parser helper ---
# Uses node with python3 fallback
json_parse() {
    local file="$1"
    local expr="$2"
    local result
    result=$(node -e "const d=JSON.parse(require('fs').readFileSync('$file','utf8'));$expr" 2>/dev/null) && echo "$result" && return 0
    result=$(python3 -c "import json,sys;d=json.load(open('$file'));$expr" 2>/dev/null) && echo "$result" && return 0
    return 1
}

json_validate() {
    local file="$1"
    node -e "JSON.parse(require('fs').readFileSync('$file','utf8'))" 2>/dev/null && return 0
    python3 -c "import json; json.load(open('$file'))" 2>/dev/null && return 0
    return 1
}

# --- State ---
MARKETPLACE_JSON="$ROOT_DIR/.claude-plugin/marketplace.json"
MARKETPLACE_NAME=$(json_parse "$MARKETPLACE_JSON" "console.log(d.name)" 2>/dev/null || grep -o '"name": *"[^"]*"' "$MARKETPLACE_JSON" | head -1 | sed 's/"name": *"\([^"]*\)"/\1/')
TOTAL_CHECKS=10
PASSED=0
FAILED=0

# --- Output helpers ---
header() {
    echo ""
    echo -e "${CYAN}$(printf '\xe2\x95\x94')$(printf '\xe2\x95\x90%.0s' {1..50})$(printf '\xe2\x95\x97')${NC}"
    echo -e "${CYAN}$(printf '\xe2\x95\x91')  Marketplace Validation: ${BOLD}${MARKETPLACE_NAME}$(printf '%*s' $((24 - ${#MARKETPLACE_NAME})) '')${NC}${CYAN}$(printf '\xe2\x95\x91')${NC}"
    echo -e "${CYAN}$(printf '\xe2\x95\x9a')$(printf '\xe2\x95\x90%.0s' {1..50})$(printf '\xe2\x95\x9d')${NC}"
    echo ""
}

check_header() {
    echo -e "${BOLD}[$1/$TOTAL_CHECKS] $2${NC}"
}

pass() {
    echo -e "  ${GREEN}${CHECK_MARK} $1${NC}"
}

fail() {
    echo -e "  ${RED}${CROSS_MARK} $1${NC}"
}

warn() {
    echo -e "  ${YELLOW}! $1${NC}"
}

info() {
    echo -e "  ${CYAN}i $1${NC}"
}

footer() {
    echo ""
    echo -e "$(printf '\xe2\x95\x90%.0s' {1..52})"
    if [ "$FAILED" -eq 0 ]; then
        echo -e "  ${GREEN}${BOLD}RESULT: ${PASSED}/${TOTAL_CHECKS} checks passed ${CHECK_MARK}${NC}"
    else
        echo -e "  ${RED}${BOLD}RESULT: ${PASSED}/${TOTAL_CHECKS} checks passed, ${FAILED} failed ${CROSS_MARK}${NC}"
    fi
    echo -e "$(printf '\xe2\x95\x90%.0s' {1..52})"
    echo ""
}

# --- Gather plugin info ---
# Get plugin directories
PLUGIN_DIRS=()
if [ -d "$ROOT_DIR/plugins" ]; then
    for d in "$ROOT_DIR"/plugins/*/; do
        [ -d "$d" ] && PLUGIN_DIRS+=("$d")
    done
fi

# Get plugin names from marketplace.json plugins array
MARKETPLACE_PLUGIN_NAMES=()
if command -v node &>/dev/null; then
    while IFS= read -r name; do
        [ -n "$name" ] && MARKETPLACE_PLUGIN_NAMES+=("$name")
    done < <(node -e "const d=JSON.parse(require('fs').readFileSync('$MARKETPLACE_JSON','utf8'));(d.plugins||[]).forEach(p=>console.log(p.name))" 2>/dev/null)
elif command -v python3 &>/dev/null; then
    while IFS= read -r name; do
        [ -n "$name" ] && MARKETPLACE_PLUGIN_NAMES+=("$name")
    done < <(python3 -c "import json;d=json.load(open('$MARKETPLACE_JSON'));[print(p['name']) for p in d.get('plugins',[])]" 2>/dev/null)
fi

# ============================================================================
header

# --- Check 1: JSON Syntax ---
check_header 1 "JSON Syntax"
check1_ok=true

if json_validate "$MARKETPLACE_JSON"; then
    pass ".claude-plugin/marketplace.json"
else
    fail ".claude-plugin/marketplace.json - invalid JSON"
    check1_ok=false
fi

for plugin_dir in "${PLUGIN_DIRS[@]}"; do
    pname=$(basename "$plugin_dir")
    pjson="$plugin_dir.claude-plugin/plugin.json"
    if [ -f "$pjson" ]; then
        if json_validate "$pjson"; then
            pass "plugins/$pname/.claude-plugin/plugin.json"
        else
            fail "plugins/$pname/.claude-plugin/plugin.json - invalid JSON"
            check1_ok=false
        fi
    fi
done

if [ "$check1_ok" = true ]; then PASSED=$((PASSED+1)); else FAILED=$((FAILED+1)); fi
echo ""

# --- Check 2: Required Fields ---
check_header 2 "Required Fields"
check2_ok=true

# marketplace.json: name, owner, plugins
has_name=$(json_parse "$MARKETPLACE_JSON" "console.log(d.name?'yes':'no')" 2>/dev/null || echo "no")
has_owner=$(json_parse "$MARKETPLACE_JSON" "console.log(d.owner?'yes':'no')" 2>/dev/null || echo "no")
has_plugins=$(json_parse "$MARKETPLACE_JSON" "console.log(Array.isArray(d.plugins)?'yes':'no')" 2>/dev/null || echo "no")

if [ "$has_name" = "yes" ] && [ "$has_owner" = "yes" ] && [ "$has_plugins" = "yes" ]; then
    pass "marketplace.json: name, owner, plugins"
else
    missing=""
    [ "$has_name" != "yes" ] && missing="${missing}name "
    [ "$has_owner" != "yes" ] && missing="${missing}owner "
    [ "$has_plugins" != "yes" ] && missing="${missing}plugins "
    fail "marketplace.json: missing ${missing}"
    check2_ok=false
fi

# Each plugin.json: name
for plugin_dir in "${PLUGIN_DIRS[@]}"; do
    pname=$(basename "$plugin_dir")
    pjson="$plugin_dir.claude-plugin/plugin.json"
    if [ -f "$pjson" ]; then
        phas_name=$(json_parse "$pjson" "console.log(d.name?'yes':'no')" 2>/dev/null || echo "no")
        if [ "$phas_name" = "yes" ]; then
            pass "plugin.json ($pname): name"
        else
            fail "plugin.json ($pname): missing name"
            check2_ok=false
        fi
    fi
done

if [ "$check2_ok" = true ]; then PASSED=$((PASSED+1)); else FAILED=$((FAILED+1)); fi
echo ""

# --- Check 3: Version Sync ---
check_header 3 "Version Sync"
check3_ok=true

for plugin_dir in "${PLUGIN_DIRS[@]}"; do
    pname=$(basename "$plugin_dir")
    pjson="$plugin_dir.claude-plugin/plugin.json"
    if [ ! -f "$pjson" ]; then continue; fi

    plugin_ver=$(json_parse "$pjson" "console.log(d.version||'')" 2>/dev/null || echo "")
    marketplace_ver=""
    if command -v node &>/dev/null; then
        marketplace_ver=$(node -e "const d=JSON.parse(require('fs').readFileSync('$MARKETPLACE_JSON','utf8'));const p=(d.plugins||[]).find(x=>x.name==='$pname');console.log(p?p.version||'':'')" 2>/dev/null)
    elif command -v python3 &>/dev/null; then
        marketplace_ver=$(python3 -c "import json;d=json.load(open('$MARKETPLACE_JSON'));ps=[p for p in d.get('plugins',[]) if p['name']=='$pname'];print(ps[0].get('version','') if ps else '')" 2>/dev/null)
    fi

    if [ -z "$plugin_ver" ] && [ -z "$marketplace_ver" ]; then
        pass "$pname (no version fields)"
    elif [ -n "$plugin_ver" ] && [ -z "$marketplace_ver" ]; then
        warn "$pname: plugin.json=$plugin_ver but no version in marketplace.json plugin entry"
    elif [ "$plugin_ver" = "$marketplace_ver" ]; then
        pass "$pname ($plugin_ver)"
    else
        fail "$pname: plugin.json=$plugin_ver vs marketplace.json=$marketplace_ver"
        check3_ok=false
    fi
done

if [ "$check3_ok" = true ]; then PASSED=$((PASSED+1)); else FAILED=$((FAILED+1)); fi
echo ""

# --- Check 4: Plugin Registry ---
check_header 4 "Plugin Registry"
check4_ok=true

# Every dir in plugins/ must have entry in marketplace.json
for plugin_dir in "${PLUGIN_DIRS[@]}"; do
    pname=$(basename "$plugin_dir")
    found=false
    for mp_name in "${MARKETPLACE_PLUGIN_NAMES[@]}"; do
        if [ "$mp_name" = "$pname" ]; then
            found=true
            break
        fi
    done
    if [ "$found" = true ]; then
        pass "Directory plugins/$pname has marketplace entry"
    else
        fail "Directory plugins/$pname has NO marketplace entry"
        check4_ok=false
    fi
done

# Every marketplace entry must have a directory
for mp_name in "${MARKETPLACE_PLUGIN_NAMES[@]}"; do
    if [ -d "$ROOT_DIR/plugins/$mp_name" ]; then
        pass "Marketplace entry $mp_name has directory"
    else
        fail "Marketplace entry $mp_name has NO directory"
        check4_ok=false
    fi
done

if [ "$check4_ok" = true ]; then PASSED=$((PASSED+1)); else FAILED=$((FAILED+1)); fi
echo ""

# --- Check 5: SKILL.md Frontmatter ---
check_header 5 "SKILL.md Frontmatter"
check5_ok=true

SKILL_FILES=()
while IFS= read -r -d '' sf; do
    SKILL_FILES+=("$sf")
done < <(find "$ROOT_DIR/plugins" -name "SKILL.md" -print0 2>/dev/null)

if [ ${#SKILL_FILES[@]} -eq 0 ]; then
    warn "No SKILL.md files found"
else
    for skill_file in "${SKILL_FILES[@]}"; do
        rel_path="${skill_file#$ROOT_DIR/}"
        # Check for frontmatter
        first_line=$(head -1 "$skill_file")
        if [ "$first_line" != "---" ]; then
            fail "$rel_path: missing YAML frontmatter (no opening ---)"
            check5_ok=false
            continue
        fi

        # Find closing ---
        closing_line=$(tail -n +2 "$skill_file" | grep -n '^---$' | head -1 | cut -d: -f1)
        if [ -z "$closing_line" ]; then
            fail "$rel_path: missing closing --- in frontmatter"
            check5_ok=false
            continue
        fi

        # Extract frontmatter (between line 2 and closing_line - 1)
        fm_end=$closing_line
        if [ "$fm_end" -ge 2 ]; then
            frontmatter=$(sed -n "2,${fm_end}p" "$skill_file")
        else
            frontmatter=""
        fi

        # Check name field
        if echo "$frontmatter" | grep -q '^name:'; then
            :
        else
            fail "$rel_path: missing name: field"
            check5_ok=false
            continue
        fi

        # Check description field
        if echo "$frontmatter" | grep -q '^description:'; then
            :
        else
            fail "$rel_path: missing description: field"
            check5_ok=false
            continue
        fi

        # Check description is single-line (no block scalars)
        desc_line=$(echo "$frontmatter" | grep '^description:')
        if echo "$desc_line" | grep -qE '^description:\s*[|>]'; then
            fail "$rel_path: description uses block scalar (must be single-line, Issue #9817)"
            check5_ok=false
            continue
        fi

        pass "$rel_path"
    done
fi

if [ "$check5_ok" = true ]; then PASSED=$((PASSED+1)); else FAILED=$((FAILED+1)); fi
echo ""

# --- Check 6: Allowed Frontmatter Keys ---
check_header 6 "Allowed Frontmatter Keys"
check6_ok=true

ALLOWED_KEYS="name description argument-hint disable-model-invocation user-invocable allowed-tools model context agent hooks license metadata"

if [ ${#SKILL_FILES[@]} -eq 0 ]; then
    warn "No SKILL.md files to check"
else
    for skill_file in "${SKILL_FILES[@]}"; do
        rel_path="${skill_file#$ROOT_DIR/}"
        first_line=$(head -1 "$skill_file")
        if [ "$first_line" != "---" ]; then continue; fi

        closing_line=$(tail -n +2 "$skill_file" | grep -n '^---$' | head -1 | cut -d: -f1)
        if [ -z "$closing_line" ]; then continue; fi

        fm_end=$closing_line
        if [ "$fm_end" -ge 2 ]; then
            frontmatter=$(sed -n "2,${fm_end}p" "$skill_file")
        else
            frontmatter=""
        fi

        unknown_keys=""
        while IFS= read -r line; do
            # Skip empty lines and comments
            [ -z "$line" ] && continue
            echo "$line" | grep -q '^\s*#' && continue
            # Skip continuation lines (indented)
            echo "$line" | grep -q '^\s' && continue

            key=$(echo "$line" | sed 's/:.*//' | tr -d ' ')
            found=false
            for allowed in $ALLOWED_KEYS; do
                if [ "$key" = "$allowed" ]; then
                    found=true
                    break
                fi
            done
            if [ "$found" = false ]; then
                unknown_keys="${unknown_keys} ${key}"
            fi
        done <<< "$frontmatter"

        if [ -n "$unknown_keys" ]; then
            fail "$rel_path: unknown keys:${unknown_keys}"
            check6_ok=false
        else
            pass "$rel_path"
        fi
    done
fi

if [ "$check6_ok" = true ]; then PASSED=$((PASSED+1)); else FAILED=$((FAILED+1)); fi
echo ""

# --- Check 7: Prefix Consistency ---
check_header 7 "Prefix Consistency"
check7_ok=true

SKILL_NAMES=()
for skill_file in "${SKILL_FILES[@]}"; do
    first_line=$(head -1 "$skill_file")
    if [ "$first_line" != "---" ]; then continue; fi
    closing_line=$(tail -n +2 "$skill_file" | grep -n '^---$' | head -1 | cut -d: -f1)
    if [ -z "$closing_line" ]; then continue; fi
    sname=$(sed -n "2,${closing_line}p" "$skill_file" | grep '^name:' | head -1 | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'" | tr -d ' ')
    [ -n "$sname" ] && SKILL_NAMES+=("$sname")
done

if [ ${#SKILL_NAMES[@]} -lt 2 ]; then
    info "Not enough skills to check prefix consistency"
else
    # Extract prefixes and find the dominant one using sort/uniq (bash 3 compatible)
    total=${#SKILL_NAMES[@]}
    prefix_data=""
    for sname in "${SKILL_NAMES[@]}"; do
        if echo "$sname" | grep -q ':'; then
            prefix_data="${prefix_data}$(echo "$sname" | cut -d: -f1)"$'\n'
        fi
    done

    dominant_prefix=""
    dominant_count=0
    if [ -n "$prefix_data" ]; then
        top_line=$(echo "$prefix_data" | grep -v '^$' | sort | uniq -c | sort -rn | head -1)
        dominant_count=$(echo "$top_line" | awk '{print $1}')
        dominant_prefix=$(echo "$top_line" | awk '{print $2}')
    fi

    # Check if >50% use the same prefix
    threshold=$(( total / 2 ))
    if [ "${dominant_count:-0}" -gt "$threshold" ] && [ -n "$dominant_prefix" ]; then
        info "Detected prefix pattern: ${dominant_prefix}: (${dominant_count}/${total} skills)"
        for sname in "${SKILL_NAMES[@]}"; do
            if echo "$sname" | grep -q "^${dominant_prefix}:"; then
                pass "$sname"
            else
                fail "$sname does not match prefix ${dominant_prefix}:"
                check7_ok=false
            fi
        done
    else
        pass "No dominant prefix pattern found (ok)"
    fi
fi

if [ "$check7_ok" = true ]; then PASSED=$((PASSED+1)); else FAILED=$((FAILED+1)); fi
echo ""

# --- Check 8: No .DS_Store ---
check_header 8 "No .DS_Store"
ds_files=$(find "$ROOT_DIR" -name .DS_Store 2>/dev/null)
if [ -z "$ds_files" ]; then
    pass "No .DS_Store files found"
    PASSED=$((PASSED+1))
else
    while IFS= read -r f; do
        fail "${f#$ROOT_DIR/}"
    done <<< "$ds_files"
    FAILED=$((FAILED+1))
fi
echo ""

# --- Check 9: No Broken Symlinks ---
check_header 9 "No Broken Symlinks"
if [ "$CI_MODE" = true ]; then
    info "Skipped in CI mode (symlinks to shared repos are expected)"
    PASSED=$((PASSED+1))
else
    broken_links=$(find "$ROOT_DIR" -type l ! -exec test -e {} \; -print 2>/dev/null)
    if [ -z "$broken_links" ]; then
        pass "No broken symlinks found"
        PASSED=$((PASSED+1))
    else
        while IFS= read -r f; do
            fail "${f#$ROOT_DIR/}"
        done <<< "$broken_links"
        FAILED=$((FAILED+1))
    fi
fi
echo ""

# --- Check 10: Claude Plugin Validate ---
check_header 10 "Claude Plugin Validate"
if [ "$CI_MODE" = true ]; then
    info "Skipped in CI mode"
    PASSED=$((PASSED+1))
elif ! command -v claude &>/dev/null; then
    info "Skipped: claude CLI not found"
    PASSED=$((PASSED+1))
else
    if (cd "$ROOT_DIR" && claude plugin validate . 2>&1); then
        pass "claude plugin validate passed"
        PASSED=$((PASSED+1))
    else
        fail "claude plugin validate failed"
        FAILED=$((FAILED+1))
    fi
fi
echo ""

# --- Footer ---
footer

if [ "$FAILED" -gt 0 ]; then
    exit 1
else
    exit 0
fi
