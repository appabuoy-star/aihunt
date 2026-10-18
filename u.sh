#!/usr/bin/env bash
set -euo pipefail

# Ensure a filename was provided
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <filename>" >&2
    exit 1
fi

TARGET_FILE="$1"

# Check if the file exists locally
if [[ ! -f "$TARGET_FILE" ]]; then
    echo "Error: File '$TARGET_FILE' not found." >&2
    exit 1
fi

echo "Staging $TARGET_FILE..."
git add "$TARGET_FILE"

echo "Committing changes..."
git commit -m "Add $TARGET_FILE to repository"

echo "Pushing to remote repository..."
git push origin main

echo "Successfully uploaded and pushed $TARGET_FILE to aihunt."
