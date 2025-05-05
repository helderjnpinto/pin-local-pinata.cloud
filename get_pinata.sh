#!/usr/bin/env bash
set -euo pipefail

# —— Optional: load .env for PINATA_JWT if present
if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

# —— Validate JWT is set
: "${PINATA_JWT:?Need to set PINATA_JWT (your Pinata JWT)}"

# —— Configuration
NETWORK="${1:-public}"            # "public" or "private"
PAGE_SIZE=1000                    # max per request
OUTPUT_FILE="all_files.jsonl"     # one JSON object per line

# —— Initialize
> "$OUTPUT_FILE"
PAGE_TOKEN=""

echo "Fetching all files from the '${NETWORK}' network..."

# —— Loop until no more pages
while :; do
  # Build URL with or without pageToken
  if [[ -z "$PAGE_TOKEN" ]]; then
    URL="https://api.pinata.cloud/v3/files/${NETWORK}?limit=${PAGE_SIZE}"
  else
    URL="https://api.pinata.cloud/v3/files/${NETWORK}?limit=${PAGE_SIZE}&pageToken=${PAGE_TOKEN}"
  fi

  # Fetch one page
  RESPONSE=$(curl -s \
    -H "Authorization: Bearer ${PINATA_JWT}" \
    "$URL")

  # Append each file object as a compact JSON line
  echo "$RESPONSE" \
    | jq -c '.data.files[]' \
    >> "$OUTPUT_FILE"

  # Extract next_page_token (will be null when done)
  PAGE_TOKEN=$(echo "$RESPONSE" | jq -r '.data.next_page_token')

  # Stop if no further pages
  if [[ -z "$PAGE_TOKEN" ]] || [[ "$PAGE_TOKEN" == "null" ]]; then
    echo "No more pages—fetched complete set."
    break
  fi

  echo "Fetched a page; continuing with token: $PAGE_TOKEN"
done

echo "Done! All file metadata saved to ${OUTPUT_FILE}"
