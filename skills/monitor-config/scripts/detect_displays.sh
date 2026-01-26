#!/bin/bash
# Detect and display monitor information using displayplacer
# Requires: brew install displayplacer

# Check if displayplacer is installed
if ! command -v displayplacer &> /dev/null; then
    echo "ERROR: displayplacer not installed"
    echo "Install with: brew install displayplacer"
    exit 1
fi

# Get display information
displayplacer list
