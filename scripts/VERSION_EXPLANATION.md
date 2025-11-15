# Understanding Version Numbers in xcmsVis

## The Confusion: Why Do Commit Messages Show v2.0.2?

If you look at the git history, you'll see confusing commit messages like:
```
chore(release): 3.0.2 [skip ci]
chore(release): 3.0.1 [skip ci]
chore(release): 2.0.0 [skip ci]
```

But the actual files (DESCRIPTION, NEWS.md) in those commits show:
```
Version: 0.99.4
Version: 0.99.3
Version: 0.99.2
```

**Why does this happen?**

## The Two-Stage Versioning Process

This project uses a special two-stage versioning to meet Bioconductor requirements:

### Stage 1: Semantic-Release Calculates Version
- Semantic-release analyzes commit messages (`feat:`, `fix:`, etc.)
- It calculates what the version **would be** using standard semantic versioning
- With standard rules: `feat:` → minor bump, `fix:` → patch bump
- This results in versions like 1.0.0, 1.0.1, 2.0.0, etc.
- **This version appears in the commit message**

### Stage 2: prepare-news.sh Converts to 0.99.x
- **Before** the commit is created, `prepare-news.sh` runs
- It detects the semantic-release version (e.g., "2.0.2")
- It converts it to 0.99.x format (e.g., "0.99.17")
- It updates DESCRIPTION and NEWS.md with the correct 0.99.x version
- **This version appears in the actual files**

### Why Use This Complex System?

**Bioconductor Requirement:**
- Bioconductor requires new packages to start with version < 1.0.0
- Specifically, they expect versions in the 0.99.x range
- After acceptance, the package can move to 1.0.0+

**Semantic-Release Benefit:**
- We still want automatic versioning based on commit messages
- Semantic-release is the industry standard tool for this
- Rather than fight it, we let it calculate versions then convert them

## What Actually Matters

When working with this repository, **ignore the commit message versions**. Always look at:

1. **DESCRIPTION file** - The source of truth for package version
2. **NEWS.md headers** - Now include commit SHAs for clarity
3. **Git tags** - Will match DESCRIPTION (0.99.x format)

## Example: The Most Recent Release

```bash
$ git log --oneline -1 9cd26b6
9cd26b6 chore(release): 3.0.2 [skip ci]

$ git show 9cd26b6:DESCRIPTION | grep Version
Version: 0.99.4

$ git tag --points-at 9cd26b6
0.99.4
```

The commit message says "3.0.2" but the actual version is "0.99.4".

## After Bioconductor Acceptance

Once this package is accepted into Bioconductor:

1. Update `.releaserc.json` to use standard semantic versioning
2. Remove the version conversion logic from `prepare-news.sh`
3. Let semantic-release use its natural versioning:
   - `feat:` → minor bump (1.0.0 → 1.1.0)
   - `fix:` → patch bump (1.0.0 → 1.0.1)
   - `BREAKING CHANGE:` → major bump (1.0.0 → 2.0.0)

## Current Files That Control Versioning

- `.releaserc.json` - Forces all commits to be patch releases
- `.github/prepare-news.sh` - Converts semantic-release versions to 0.99.x
- `.github/sync-bioc-tag.sh` - Creates tags with 0.99.x versions
- `.bioc_version` - Stores the actual 0.99.x version used

## Summary

| Location | Version Format | Example | Notes |
|----------|---------------|---------|-------|
| Commit messages | Semantic versioning | 3.0.2 | Ignore this |
| DESCRIPTION | Bioconductor format | 0.99.4 | **Source of truth** |
| NEWS.md | Bioconductor format | 0.99.4 | Matches DESCRIPTION |
| Git tags | Bioconductor format | 0.99.4 | Matches DESCRIPTION |
| GitHub Releases | Bioconductor format | 0.99.4 | Matches DESCRIPTION |
