# Bioconductor Semantic Release Setup - Execution Guide

This document explains how to set up and fix the semantic-release configuration for Bioconductor packages that need to stay below version 1.0.0.

## Background

Bioconductor requires new packages to have versions < 1.0.0 (typically in the 0.99.x range). However, this repository initially used standard semantic-release which created versions above 1.0.0 (up to 3.0.2).

The solution is a two-stage versioning system:
1. Semantic-release calculates versions using conventional commits (1.0.0, 2.0.0, 3.0.2, etc.)
2. Custom scripts convert these to Bioconductor format (0.99.1, 0.99.2, 0.99.4, etc.)

See `VERSION_EXPLANATION.md` for detailed explanation of how this works.

## Files Added/Modified

### Configuration Files
- `.releaserc.json` - Updated to use custom tag format and call the new scripts
- `.github/prepare-news.sh` - Converts semantic versions to 0.99.x format
- `.github/sync-bioc-tag.sh` - Creates GitHub releases with 0.99.x versions

### Cleanup Scripts (in scripts/ directory)
- `sync-historical-tags.sh` - Creates tags for all past release commits
- `cleanup-releases.sh` - Deletes and recreates GitHub releases with correct versions
- `cleanup-branches.sh` - Cleans up old development branches (optional)
- `VERSION_EXPLANATION.md` - Documentation about the versioning system
- `SETUP_INSTRUCTIONS.md` - This file

## Current State

Before running cleanup scripts, the repository has:
- ✅ DESCRIPTION file with correct version (0.99.4)
- ✅ Release commits with semantic versions in messages (3.0.2, 3.0.1, etc.)
- ❌ No git tags for releases
- ❌ Incorrect or missing GitHub releases

## One-Time Setup: Fix Historical Releases

Run these scripts **IN ORDER** to fix the existing repository state:

### Step 1: Create Tags for All Release Commits

```bash
cd /home/user/xcmsVis
./scripts/sync-historical-tags.sh
```

**What this does:**
- Finds all commits with "chore(release):" in the message
- Reads the DESCRIPTION version from each commit
- Creates a git tag with that version (e.g., 0.99.4, 0.99.3, etc.)
- Force-pushes all tags to GitHub

**Expected output:**
```
Creating tags for all release commits...
Creating tag 0.99.4 for commit 9cd26b6
Creating tag 0.99.3 for commit e55bd1d
...
✓ All historical tags have been synced to remote
```

**Verification:**
```bash
git tag --list | sort -V
```

You should see tags like: 0.99.1, 0.99.2, 0.99.3, 0.99.4, etc.

### Step 2: Recreate GitHub Releases with Correct Versions

```bash
./scripts/cleanup-releases.sh
```

**What this does:**
- Lists all existing GitHub releases
- Asks for confirmation
- Deletes all existing releases
- Creates new releases for each 0.99.x tag
- Links to NEWS.md for release notes

**Interactive prompt:**
```
Listing all existing GitHub releases...
...
Do you want to delete all these releases? (y/N):
```

Type `y` and press Enter to proceed.

**Expected output:**
```
Deleting all existing releases...
Deleting release 3.0.2...
✓ All old releases deleted

Now creating new releases from git tags...
Creating release 0.99.1 (commit: 169abac)...
Creating release 0.99.2 (commit: c2cfe50)...
...
✓ All releases recreated with correct 0.99.x versions
```

**Verification:**
Check the releases on GitHub - they should now all have 0.99.x versions.

### Step 3 (Optional): Clean Up Old Development Branches

```bash
./scripts/cleanup-branches.sh --dry-run  # Preview what will be deleted
./scripts/cleanup-branches.sh             # Actually delete branches
```

**What this does:**
- Deletes all local and remote branches except `main` and `gh-pages`
- Useful for cleaning up old feature/development branches

**Note:** This is optional and not required for the semantic-release setup to work.

## Future Releases: Automated Process

After the one-time setup, the release process is fully automated through GitHub Actions:

1. **Developer makes commits** using conventional commit format:
   ```bash
   git commit -m "feat: add new visualization function"
   git commit -m "fix: correct color scaling bug"
   ```

2. **Push to main branch:**
   ```bash
   git push origin main
   ```

3. **GitHub Actions automatically:**
   - Runs semantic-release
   - Semantic-release calculates version (e.g., "3.0.5")
   - `prepare-news.sh` converts to 0.99.x (e.g., "0.99.5")
   - Updates DESCRIPTION and NEWS.md
   - Commits changes
   - `sync-bioc-tag.sh` creates GitHub release and tag with 0.99.x version

4. **Result:**
   - Commit message: "chore(release): 0.99.5 [skip ci]"
   - DESCRIPTION: Version: 0.99.5
   - Git tag: 0.99.5
   - GitHub release: 0.99.5

## Troubleshooting

### Tags already exist
If you run `sync-historical-tags.sh` multiple times, it uses `-f` flag to force update tags. This is safe.

### Missing GITHUB_TOKEN
The cleanup scripts require GitHub CLI (`gh`) to be authenticated. Make sure you have:
```bash
gh auth status
```

If not authenticated:
```bash
gh auth login
```

### No releases found
If `cleanup-releases.sh` shows no releases, that's fine - it will still create new ones from the tags.

### Script permission denied
If you get "Permission denied" when running scripts:
```bash
chmod +x scripts/*.sh .github/*.sh
```

## After Bioconductor Acceptance

Once the package is accepted into Bioconductor and you want to move to version 1.0.0+:

1. Update `.releaserc.json` to remove the forced patch releases
2. Update `prepare-news.sh` to stop converting to 0.99.x
3. Remove or disable `sync-bioc-tag.sh`
4. Let semantic-release use standard versioning (1.0.0, 1.1.0, 2.0.0, etc.)

## Summary: What Changed

### Before (Broken State)
- Commit messages: "chore(release): 3.0.2 [skip ci]"
- DESCRIPTION: Version: 0.99.4 ✅
- Git tags: None ❌
- GitHub releases: Wrong or missing ❌

### After (Fixed State)
- Commit messages: "chore(release): 0.99.4 [skip ci]" ✅
- DESCRIPTION: Version: 0.99.4 ✅
- Git tags: 0.99.4 ✅
- GitHub releases: 0.99.4 ✅

All version numbers now consistently show 0.99.x format across all locations!
