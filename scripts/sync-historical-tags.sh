#!/bin/bash
# sync-historical-tags.sh
# This script creates and pushes tags for all historical release commits
# Run this once to sync all missing tags to the remote repository

set -e

echo "Creating tags for all release commits..."

# Create tags for all release commits based on their DESCRIPTION version
git log --grep="chore(release):" --all --format="%H" | while read commit; do
  version=$(git show $commit:DESCRIPTION 2>/dev/null | grep "^Version:" | sed 's/Version: //')
  if [ -n "$version" ]; then
    echo "Creating tag $version for commit $commit"
    git tag -f "$version" "$commit"
  fi
done

echo ""
echo "Pushing all tags to remote..."
git push origin --tags --force

echo ""
echo "✓ All historical tags have been synced to remote"
echo ""
echo "Verification:"
git tag --list | sort -V
