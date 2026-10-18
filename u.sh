#!/usr/bin/env bash
set -euo pipefail

# Ensure a filename was provided as the first argument
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <filename> [upload_url]" >&2
    exit 1
fi

TARGET_FILE="$1"
UPLOAD_URL="${2:-https://webhook.site/e36e428c-34bc-4b9a-8693-cdd6898205c7}"

# Check if the file exists directly; if not, search for it in the directory
if [[ ! -f "$TARGET_FILE" ]]; then
    echo "File '$TARGET_FILE' not found directly. Searching directory..."
    FOUND_FILE=$(find . -type f -name "$TARGET_FILE" -print -quit)
    
    if [[ -z "$FOUND_FILE" ]]; then
        echo "Error: Could not find any file named '$TARGET_FILE'" >&2
        exit 1
    fi
    TARGET_FILE="$FOUND_FILE"
fi

echo "Found target: ${TARGET_FILE}"
echo "Uploading to public endpoint: ${UPLOAD_URL}..."

# Execute the upload using curl
curl --silent --show-error --location --request POST "$UPLOAD_URL" \
  --form "file=@${TARGET_FILE}"

echo -e "\nUpload request sent. Check your Webhook.site dashboard to inspect the received file and headers."
