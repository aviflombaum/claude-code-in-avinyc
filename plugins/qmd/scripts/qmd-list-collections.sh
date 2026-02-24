#!/bin/bash
# Wrapper: list all collections in the default qmd index.
# Usage: qmd-list-collections.sh

set -euo pipefail

qmd collection list
