#!/bin/bash
# Wrapper: re-index the default qmd index (update documents + generate embeddings).
# Incremental — only processes changed files.
# Usage: qmd-index.sh

set -euo pipefail

qmd update
qmd embed
