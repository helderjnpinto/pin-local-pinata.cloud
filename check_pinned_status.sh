#!/bin/bash

# Input file
FILE="all_files.jsonl"

# Output report
REPORT="pinning_report.txt"
> "$REPORT"  # clear previous report

# IPFS API endpoint
IPFS_API="${IPFS_API:-http://127.0.0.1:5001/api/v0}"

# Counters
total=0
pinned=0
missing=0

echo "🔍 Checking pin status of CIDs in $FILE..."
echo "" >> "$REPORT"

while IFS= read -r line; do
  ((total++))
  name=$(echo "$line" | jq -r '.name')
  cid=$(echo "$line" | jq -r '.cid')

  # Check pin status using the IPFS API
  response=$(curl -s -X POST "$IPFS_API/pin/ls?arg=$cid" 2>/dev/null)

  if echo "$response" | grep -q "\"$cid\""; then
    echo "✅ Pinned: $name ($cid)"
    echo "✅ Pinned: $name ($cid)" >> "$REPORT"
    ((pinned++))
  else
    echo "❌ Missing: $name ($cid)"
    echo "❌ Missing: $name ($cid)" >> "$REPORT"
    ((missing++))
  fi
done < "$FILE"

# Summary
echo ""
echo "📊 Summary:"
echo "Total:   $total"
echo "Pinned:  $pinned"
echo "Missing: $missing"

echo "" >> "$REPORT"
echo "📊 Summary:" >> "$REPORT"
echo "Total:   $total" >> "$REPORT"
echo "Pinned:  $pinned" >> "$REPORT"
echo "Missing: $missing" >> "$REPORT"

echo ""
echo "📄 Full report saved to: $REPORT"
