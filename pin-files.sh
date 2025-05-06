#!/bin/bash

# File with CID records
FILE="all_files.jsonl"
REPORT="check_and_pin_report.txt"
> "$REPORT"  # clear previous report

# Counters
total=0
already_pinned=0
pinned_now=0
failed=0

echo "🚀 Checking and pinning CIDs from: $FILE"
echo "" >> "$REPORT"

while IFS= read -r line; do
  ((total++))
  name=$(echo "$line" | jq -r '.name')
  cid=$(echo "$line" | jq -r '.cid')

  # Check if already pinned
  check_response=$(curl -s "http://127.0.0.1:5001/api/v0/pin/ls?arg=$cid")
  if echo "$check_response" | grep -q "\"$cid\""; then
    echo "✅ Already pinned: $name ($cid)"
    echo "✅ Already pinned: $name ($cid)" >> "$REPORT"
    ((already_pinned++))
  else
    # Try to pin
    echo "📌 Pinning: $name ($cid)"
    pin_response=$(curl -s -X POST "http://127.0.0.1:5001/api/v0/pin/add?arg=$cid")
    if echo "$pin_response" | grep -q "$cid"; then
      echo "✅ Pinned now: $name ($cid)"
      echo "✅ Pinned now: $name ($cid)" >> "$REPORT"
      ((pinned_now++))
    else
      echo "❌ Failed to pin: $name ($cid)"
      echo "❌ Failed to pin: $name ($cid)" >> "$REPORT"
      echo "Response: $pin_response" >> "$REPORT"
      ((failed++))
    fi
  fi
done < "$FILE"

# Summary
echo ""
echo "📊 Summary:"
echo "Total checked: $total"
echo "Already pinned: $already_pinned"
echo "Pinned now: $pinned_now"
echo "Failed: $failed"

echo "" >> "$REPORT"
echo "📊 Summary:" >> "$REPORT"
echo "Total checked: $total" >> "$REPORT"
echo "Already pinned: $already_pinned" >> "$REPORT"
echo "Pinned now: $pinned_now" >> "$REPORT"
echo "Failed: $failed" >> "$REPORT"

echo ""
echo "📄 Report saved to: $REPORT"
