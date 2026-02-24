#!/bin/bash
# Wrapper: add a collection to the default qmd index.
# Runs qmd collection add + qmd context add.
# Usage: qmd-add-collection.sh <collection_name> <absolute_path> <pattern> <description>
# Exit 1 if collection already exists (caller handles overwrite flow).

set -euo pipefail

COLLECTION="${1:?Usage: qmd-add-collection.sh <name> <path> <pattern> <description>}"
PATH_ARG="${2:?Usage: qmd-add-collection.sh <name> <path> <pattern> <description>}"
PATTERN="${3:?Usage: qmd-add-collection.sh <name> <path> <pattern> <description>}"
DESCRIPTION="${4:?Usage: qmd-add-collection.sh <name> <path> <pattern> <description>}"

qmd collection add "$PATH_ARG" --name "$COLLECTION" --mask "$PATTERN"
qmd context add "qmd://$COLLECTION/" "$DESCRIPTION"
