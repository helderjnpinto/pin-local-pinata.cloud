#!/bin/bash

# Calculate total bytes by summing '.size' from all JSON lines
total_bytes=$(jq -s '[.[].size] | add' all_files.jsonl)

# Convert bytes to megabytes and gigabytes using proper binary conversion (1 MB = 1024^2 bytes)
total_mb=$(awk "BEGIN {printf \"%.2f\", $total_bytes / (1024 * 1024)}")
total_gb=$(awk "BEGIN {printf \"%.2f\", $total_bytes / (1024 * 1024 * 1024)}")

# Output the results
echo "Total Size:"
echo "Bytes: $total_bytes"
echo "MB: $total_mb"
echo "GB: $total_gb"
