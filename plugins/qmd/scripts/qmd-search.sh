#!/bin/bash
# Wrapper: BM25 keyword search via qmd. Ensures correct flags every time.
# Usage: qmd-search.sh "<query>" "<collection>" [n]
# Output: JSON array of results to stdout

set -euo pipefail

QUERY="${1:?Usage: qmd-search.sh <query> <collection> [n]}"
COLLECTION="${2:?Usage: qmd-search.sh <query> <collection> [n]}"
COUNT="${3:-5}"

qmd search "$QUERY" -c "$COLLECTION" --json -n "$COUNT"
