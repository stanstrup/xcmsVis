#!/bin/bash
# prepare-news.sh
set -e

# Ensure NEXT_RELEASE_VERSION is set
NEXT_VERSION=${SEMANTIC_RELEASE_NEXT_RELEASE_VERSION:-$1}

if [ -z "$NEXT_VERSION" ]; then
  echo "ERROR: Next release version not set."
  exit 1
fi

# Force version to stay in 0.99.x range for Bioconductor development
# Extract the patch version and increment within 0.99.x
if [[ "$NEXT_VERSION" =~ ^0\.99\.([0-9]+)$ ]]; then
  # Already in 0.99.x range, use as-is
  BIOC_VERSION="$NEXT_VERSION"
elif [[ "$NEXT_VERSION" =~ ^[1-9].*$ ]]; then
  # Version >= 1.0.0, map back to 0.99.x
  # Get current version from DESCRIPTION
  CURRENT_VERSION=$(grep "^Version:" DESCRIPTION | sed 's/Version: //')
  if [[ "$CURRENT_VERSION" =~ ^0\.99\.([0-9]+)$ ]]; then
    PATCH="${BASH_REMATCH[1]}"
    BIOC_VERSION="0.99.$((PATCH + 1))"
  else
    # If current version is not 0.99.x, start at 0.99.1
    BIOC_VERSION="0.99.1"
  fi
else
  # Default case
  BIOC_VERSION="0.99.1"
fi

echo "Preparing NEWS.md and DESCRIPTION for version $BIOC_VERSION (from semantic-release: $NEXT_VERSION)..."
NEXT_VERSION="$BIOC_VERSION"

# Format NEWS.md for R/pkgdown
sed -i 's/^# \[\([0-9]\+\.[0-9]\+\.[0-9]\+\)\].*/## Changes in v\1/' NEWS.md
sed -i 's/^## \[\([0-9]\+\.[0-9]\+\.[0-9]\+\)\].*/## Changes in v\1/' NEWS.md
sed -i 's/^# \([0-9]\+\.[0-9]\+\.[0-9]\+\).*/## Changes in v\1/' NEWS.md
sed -i 's/^## \([0-9]\+\.[0-9]\+\.[0-9]\+\).*/## Changes in v\1/' NEWS.md
sed -i '/^# xcmsVis/d' NEWS.md
sed -i 's/(\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\))$/ (\1)/' NEWS.md
sed -i 's/### /### /' NEWS.md
sed -i 's/\[compare\/v[0-9].*//' NEWS.md

# Update DESCRIPTION version
sed -i "s/^Version: .*/Version: $NEXT_VERSION/" DESCRIPTION
