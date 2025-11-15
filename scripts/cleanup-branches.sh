#!/bin/bash

# Script to delete all git branches except 'main' and 'gh-pages' (both local and remote)
# Usage: ./cleanup-branches.sh [--dry-run]

set -e

DRY_RUN=false

# Parse arguments
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🔍 DRY RUN MODE - No branches will be deleted"
  echo ""
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🌿 Branch Cleanup Script"
echo "======================="
echo ""

# Make sure we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  echo -e "${YELLOW}⚠️  Switching to 'main' branch first...${NC}"
  if [[ "$DRY_RUN" == false ]]; then
    git checkout main
  else
    echo "  Would run: git checkout main"
  fi
  echo ""
fi

# Fetch latest from remote to get accurate branch list
echo "📡 Fetching latest from remote..."
if [[ "$DRY_RUN" == false ]]; then
  git fetch --prune
else
  echo "  Would run: git fetch --prune"
fi
echo ""

# Get list of local branches (excluding main and gh-pages)
echo "🔍 Finding local branches to delete..."
LOCAL_BRANCHES=$(git branch | grep -v "main" | grep -v "gh-pages" | sed 's/^[ *]*//' || true)

if [[ -z "$LOCAL_BRANCHES" ]]; then
  echo -e "${GREEN}✓ No local branches to delete${NC}"
else
  echo -e "${YELLOW}Local branches to delete:${NC}"
  echo "$LOCAL_BRANCHES" | sed 's/^/  - /'
  echo ""

  if [[ "$DRY_RUN" == false ]]; then
    echo "Deleting local branches..."
    echo "$LOCAL_BRANCHES" | xargs -r git branch -D
    echo -e "${GREEN}✓ Local branches deleted${NC}"
  else
    echo "  Would run: git branch -D <branches>"
  fi
fi
echo ""

# Get list of remote branches (excluding main and gh-pages)
echo "🔍 Finding remote branches to delete..."
REMOTE_BRANCHES=$(git branch -r | grep -v "main" | grep -v "gh-pages" | grep -v "HEAD" | sed 's|origin/||' | sed 's/^[ ]*//' || true)

if [[ -z "$REMOTE_BRANCHES" ]]; then
  echo -e "${GREEN}✓ No remote branches to delete${NC}"
else
  echo -e "${YELLOW}Remote branches to delete:${NC}"
  echo "$REMOTE_BRANCHES" | sed 's/^/  - origin\//'
  echo ""

  if [[ "$DRY_RUN" == false ]]; then
    # Ask for confirmation before deleting remote branches
    echo -e "${RED}⚠️  WARNING: This will delete remote branches!${NC}"
    read -p "Are you sure you want to continue? (yes/no): " CONFIRM

    if [[ "$CONFIRM" == "yes" ]]; then
      echo "Deleting remote branches..."
      # Use GitHub CLI for authentication (works with modern GitHub auth)
      while IFS= read -r branch; do
        if [[ -n "$branch" ]]; then
          echo "  Deleting origin/$branch..."
          gh api -X DELETE "repos/:owner/:repo/git/refs/heads/$branch" 2>/dev/null || \
            git push origin --delete "$branch" 2>/dev/null || \
            echo "    Failed to delete $branch (may not exist or no permissions)"
        fi
      done <<< "$REMOTE_BRANCHES"
      echo -e "${GREEN}✓ Remote branches deleted${NC}"
    else
      echo "Cancelled. Remote branches were not deleted."
    fi
  else
    echo "  Would run: gh api -X DELETE repos/:owner/:repo/git/refs/heads/<branch>"
  fi
fi

echo ""
echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""
echo "📊 Remaining branches:"
git branch -a | grep -E "(^\*|main|gh-pages)"
