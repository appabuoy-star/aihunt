#!/usr/bin/env bash
set -euo pipefail

# Configuration
UPLOAD_URL="${1:-https://api.trusources.ai/actions}"
SEARCH_DIR="${2:-.}"

echo "Searching for sample.png starting from: ${SEARCH_DIR}..."

# Find the first matching sample.png file locally
SAMPLE_FILE=$(find "$SEARCH_DIR" -type f -name "sample.png" -print -quit)

if [[ -z "$SAMPLE_FILE" ]]; then
    echo "Error: Could not find any file named 'sample.png' in ${SEARCH_DIR}" >&2
    exit 1
fi

echo "Found target: ${SAMPLE_FILE}"
echo "Uploading to ${UPLOAD_URL}..."

# Execute the upload using curl
RESPONSE=$(curl --silent --show-error --location --request POST "$UPLOAD_URL" \
  --form "file=@${SAMPLE_FILE}")

echo "Upload complete. Server response:"
echo "$RESPONSE"
