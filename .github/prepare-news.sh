#!/bin/bash
# prepare-news.sh
set -e

# Get parameters from semantic-release
SEMANTIC_VERSION=${SEMANTIC_RELEASE_NEXT_RELEASE_VERSION:-$1}
RELEASE_NOTES=$2

if [ -z "$SEMANTIC_VERSION" ]; then
  echo "ERROR: Next release version not set."
  exit 1
fi

echo "Semantic-release version: $SEMANTIC_VERSION"

# Force version to stay in 0.99.x range for Bioconductor development
# Extract the patch version and increment within 0.99.x
if [[ "$SEMANTIC_VERSION" =~ ^0\.99\.([0-9]+)$ ]]; then
  # Already in 0.99.x range, use as-is
  BIOC_VERSION="$SEMANTIC_VERSION"
elif [[ "$SEMANTIC_VERSION" =~ ^[1-9].*$ ]]; then
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

echo "Preparing NEWS.md and DESCRIPTION for version $BIOC_VERSION..."

# Export for potential use by other scripts
echo "$BIOC_VERSION" > .bioc_version

# Get current date
RELEASE_DATE=$(date +%Y-%m-%d)

# Get current commit SHA for traceability
COMMIT_SHA=$(git rev-parse --short HEAD)

# Clean up release notes - remove the version header that semantic-release adds
# It can be in formats like:
# "## [1.0.2](url) (2025-11-13)" or "# 1.0.2 (2025-11-13)"
# We want to keep section headers like "### Bug Fixes"
CLEANED_NOTES=$(echo "$RELEASE_NOTES" | sed -E '/^#{1,2} (\[)?[0-9]+\.[0-9]+\.[0-9]+/d')

# Create new NEWS.md entry at the top
# First, save existing NEWS.md content
if [ -f NEWS.md ]; then
  cp NEWS.md NEWS.md.bak
else
  touch NEWS.md.bak
fi

# Create new NEWS.md with new entry at the top
{
  echo "## Changes in v$BIOC_VERSION (commit: $COMMIT_SHA)"
  echo ""
  echo "$CLEANED_NOTES"
  echo ""
  # Add existing content below
  cat NEWS.md.bak
} > NEWS.md

# Clean up backup
rm NEWS.md.bak

# Update DESCRIPTION version
sed -i "s/^Version: .*/Version: $BIOC_VERSION/" DESCRIPTION

# Create git commit with Bioconductor version
echo "Creating git commit for version $BIOC_VERSION..."

# Configure git if not already configured
git config user.name "github-actions[bot]" || true
git config user.email "github-actions[bot]@users.noreply.github.com" || true

# Delete any semantic-release tags that were created locally
echo "Cleaning up any semantic-release tags..."
SEMANTIC_TAGS=$(git tag | grep "^semantic-release-" || true)
if [ -n "$SEMANTIC_TAGS" ]; then
  for tag in $SEMANTIC_TAGS; do
    echo "Deleting local semantic-release tag: $tag"
    git tag -d "$tag" || true
  done
fi

# Add modified files
git add NEWS.md DESCRIPTION .bioc_version

# Create commit with Bioconductor version (not semantic version)
git commit -m "chore(release): $BIOC_VERSION [skip ci]

$RELEASE_NOTES"

# Push the commit using GITHUB_TOKEN
# Use --no-follow-tags to prevent pushing any tags
git push --no-follow-tags

echo "Committed and pushed version $BIOC_VERSION"
