#!/bin/bash
# IMPORTANT LEGAL NOTICE: This script should only be used with websites where you have
# permission to access content or where such access is permitted under applicable law.
# Circumventing access controls may violate the CFAA, 18 U.S.C. § 1030, and similar laws.

TARGET_URL=$1
OUTPUT_DIR="./local-dir"

# Basic parameter validation
if [ -z "$TARGET_URL" ]; then
  echo "Usage: $0 <target_url>"
  exit 1
fi

echo "Starting retrieval of: $TARGET_URL"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Modified wget command with additional parameters to address common 403 issues
wget --mirror \
     -rkpNp \
     -e robots=off \
     --no-check-certificate \
     --random-wait \
     --wait=2 \
     --tries=3 \
     --timeout=15 \
     --convert-links \
     -P "$OUTPUT_DIR" \
     --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
     --header="Accept-Language: en-US,en;q=0.5" \
     --header="Connection: keep-alive" \
     --header="DNT: 1" \
     --header="Upgrade-Insecure-Requests: 1" \
     --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0" \
     "$TARGET_URL"

echo "Download attempt completed for: $TARGET_URL"
