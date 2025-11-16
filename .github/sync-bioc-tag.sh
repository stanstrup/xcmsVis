#!/bin/bash
# sync-bioc-tag.sh - Create 0.99.x tag and GitHub release
set -e

# Get parameters from semantic-release (via environment variables)
SEMANTIC_VERSION=${SEMANTIC_RELEASE_NEXT_RELEASE_VERSION:-$1}
RELEASE_NOTES=${SEMANTIC_RELEASE_NEXT_RELEASE_NOTES:-$2}

echo "Semantic-release version: $SEMANTIC_VERSION"

# Read the Bioconductor version that was set by prepare-news.sh
if [ ! -f ".bioc_version" ]; then
  echo "ERROR: .bioc_version file not found"
  exit 1
fi

BIOC_VERSION=$(cat .bioc_version)
echo "Creating Bioconductor release: $BIOC_VERSION"

# Extract release notes from NEWS.md (first section after the version header)
# This ensures we use the properly formatted NEWS.md content
NEWS_CONTENT=$(awk '/## Changes in v'"$BIOC_VERSION"'/,/## Changes in v[0-9]/ {
  if (/## Changes in v[0-9]/ && !/## Changes in v'"$BIOC_VERSION"'/) exit;
  if (!/## Changes in v'"$BIOC_VERSION"'/) print
}' NEWS.md)

# Create GitHub release using gh CLI
# Note: gh release create automatically creates and pushes the tag
if [ -n "$GITHUB_TOKEN" ]; then
  echo "Creating GitHub release for $BIOC_VERSION..."

  # Check if release already exists and delete it
  if gh release view "$BIOC_VERSION" &>/dev/null; then
    echo "Release $BIOC_VERSION already exists, deleting it first..."
    gh release delete "$BIOC_VERSION" --yes --cleanup-tag
  fi

  # Check if tag exists locally and delete it
  if git rev-parse "$BIOC_VERSION" >/dev/null 2>&1; then
    echo "Deleting existing local tag $BIOC_VERSION..."
    git tag -d "$BIOC_VERSION"
  fi

  # Create the release with NEWS.md content
  # This automatically creates and pushes the tag using GITHUB_TOKEN
  gh release create "$BIOC_VERSION" \
    --title "xcmsVis v$BIOC_VERSION" \
    --notes "$NEWS_CONTENT" \
    --latest

  echo "GitHub release and tag created successfully for $BIOC_VERSION"
else
  echo "ERROR: GITHUB_TOKEN not set, cannot create GitHub release"
  exit 1
fi
