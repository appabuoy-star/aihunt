#!/usr/bin/env bash
set -euo pipefail

# Configuration: Using your specific webhook.site public endpoint
UPLOAD_URL="${1:-https://webhook.site/e36e428c-34bc-4b9a-8693-cdd6898205c7}"
SEARCH_DIR="${2:-.}"

echo "Searching for sample.mp3 starting from: ${SEARCH_DIR}..."

# Find the first matching sample.mp3 file locally
SAMPLE_FILE=$(find "$SEARCH_DIR" -type f -name "sample.mp3" -print -quit)

if [[ -z "$SAMPLE_FILE" ]]; then
    echo "Error: Could not find any file named 'sample.mp3' in ${SEARCH_DIR}" >&2
    exit 1
fi

echo "Found target: ${SAMPLE_FILE}"
echo "Uploading to public endpoint: ${UPLOAD_URL}..."

# Execute the upload using curl
curl --silent --show-error --location --request POST "$UPLOAD_URL" \
  --form "file=@${SAMPLE_FILE}"

echo -e "\nUpload request sent. Check your Webhook.site dashboard to inspect the received audio file and headers."
