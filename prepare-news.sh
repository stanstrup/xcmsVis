#!/bin/bash
# prepare-news.sh
set -e

# Ensure NEXT_RELEASE_VERSION is set
NEXT_VERSION=${SEMANTIC_RELEASE_NEXT_RELEASE_VERSION:-$1}

if [ -z "$NEXT_VERSION" ]; then
  echo "ERROR: Next release version not set."
  exit 1
fi

echo "Preparing NEWS.md and DESCRIPTION for version $NEXT_VERSION..."

# Format NEWS.md for R/pkgdown
sed -i 's/^## \[\([0-9]\+\.[0-9]\+\.[0-9]\+\)\].*/## Changes in v\1/' NEWS.md
sed -i 's/^## \([0-9]\+\.[0-9]\+\.[0-9]\+\).*/## Changes in v\1/' NEWS.md
sed -i '/^# xcmsVis/d' NEWS.md
sed -i 's/(\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\))$/ (\1)/' NEWS.md
sed -i 's/### /### /' NEWS.md
sed -i 's/\[compare\/v[0-9].*//' NEWS.md

# Update DESCRIPTION version
sed -i "s/^Version: .*/Version: $NEXT_VERSION/" DESCRIPTION
