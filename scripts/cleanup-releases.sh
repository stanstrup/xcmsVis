#!/bin/bash
# cleanup-releases.sh
# This script deletes all existing GitHub releases and recreates them with correct versions
# Run this after sync-historical-tags.sh to ensure releases match the 0.99.x tags

set -e

echo "Listing all existing GitHub releases..."
gh release list --limit 50

echo ""
read -p "Do you want to delete all these releases? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Deleting all existing releases..."

# Get all release tags and delete them
gh release list --limit 50 | awk '{print $1}' | while read tag; do
  echo "Deleting release $tag..."
  gh release delete "$tag" --yes --cleanup-tag
done

echo ""
echo "✓ All old releases deleted"
echo ""
echo "Now creating new releases from git tags..."
echo ""

# Create releases for all 0.99.x tags
git tag --list | sort -V | while read tag; do
  commit=$(git rev-list -n 1 "$tag")

  # Extract release notes from NEWS.md for this version
  echo "Creating release $tag (commit: ${commit:0:7})..."

  # Create a simple release with notes pointing to NEWS.md
  gh release create "$tag" \
    --title "Release $tag" \
    --notes "See [NEWS.md](https://github.com/stanstrup/xcmsVis/blob/$tag/NEWS.md) for details." \
    --target "$commit"
done

echo ""
echo "✓ All releases recreated with correct 0.99.x versions"
echo ""
echo "Verification:"
gh release list --limit 20
