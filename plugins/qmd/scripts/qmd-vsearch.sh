#!/bin/bash
# Wrapper: semantic (vector) search via qmd. Fallback when BM25 scores are low.
# Usage: qmd-vsearch.sh "<query>" "<collection>" [n]
# Output: JSON array of results to stdout

set -euo pipefail

QUERY="${1:?Usage: qmd-vsearch.sh <query> <collection> [n]}"
COLLECTION="${2:?Usage: qmd-vsearch.sh <query> <collection> [n]}"
COUNT="${3:-5}"

qmd vsearch "$QUERY" -c "$COLLECTION" --json -n "$COUNT"
