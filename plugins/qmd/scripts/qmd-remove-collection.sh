#!/bin/bash
# Wrapper: remove a collection from the default qmd index.
# Cleans up both YAML config and SQLite data.
# Usage: qmd-remove-collection.sh <collection_name>

set -euo pipefail

COLLECTION="${1:?Usage: qmd-remove-collection.sh <collection_name>}"

qmd collection remove "$COLLECTION"
