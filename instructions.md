---
editor_options: 
  markdown: 
    wrap: 72
---

# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and
resources.**

✅ vignette 4 to fix manually:

the LamaParama example is weird. Model after the LamaParama example in
<https://sneumann.github.io/xcms/articles/xcms.html> instead.

OK, that fixed it. Lets move ahead. The vignette 4 is still not using
lamaparama as intended. it uses all features instead of a subset. Please
read the "Alignment to an external reference dataset" section from
<https://sneumann.github.io/xcms/articles/xcms.html> and follow a
similar workflow.

To fix your current repository state, run these **two required
scripts**:

```         
# 1. Create tags for all historical release commits (0.99.1, 0.99.2, etc.) ./scripts/sync-historical-tags.sh  # 2. Recreate GitHub releases with correct 0.99.x versions ./scripts/cleanup-releases.sh 
```

**Optional:**

```         
# 3. Clean up old development branches (preview first) ./scripts/cleanup-branches.sh --dry-run ./scripts/cleanup-branches.sh 
```

### **Next Steps**

1.  **Read `scripts/SETUP_INSTRUCTIONS.md`** - Contains detailed
    explanations and troubleshooting

2.  **Run the cleanup scripts** in the order above

3.  **Verify** tags and releases are correct on GitHub

4.  Future releases will be **fully automated** via GitHub Actions
