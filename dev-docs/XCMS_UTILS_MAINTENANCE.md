# XCMS Utility Functions Maintenance Guide

## Overview

This document describes how to maintain the XCMS utility functions copied into xcmsVis to avoid using `:::` which would generate R CMD check NOTEs.

## Why We Copy Instead of Import

**The Problem:**
- R packages cannot use `package:::function()` to access internal functions without generating NOTEs
- Bioconductor standards require **0 errors, 0 warnings, 0 notes**
- XCMS does not export these utility functions

**Our Solution:**
- Copy stable, low-level utility functions from XCMS
- Maintain proper attribution and documentation
- Monitor for upstream changes
- Validate behavior with comprehensive tests

**Alternative (Future):**
- Request XCMS maintainers to export these functions
- If exported, switch to importing from XCMS
- Open issue at: https://github.com/sneumann/xcms/issues

---

## Functions Copied from XCMS

### 1. `.descendMin()` - Peak Boundary Detection

**Location in xcmsVis:**
- R wrapper: `R/xcms-utils.R` (lines 55-100)
- C code: `src/util.c` (function `DescendMin`)
- C header: `src/util.h`

**XCMS Source:**
- R wrapper: https://github.com/sneumann/xcms/blob/devel/R/c.R
- C code: https://github.com/sneumann/xcms/blob/devel/src/util.c

**Used By:**
- `gplotChromPeakDensity()` - Peak density visualization
- `.simulate_feature_groups()` - Feature grouping simulation

**Stability:** Very stable (unchanged for years)

---

### 2. `.applyRtAdjustment()` - RT Correction

**Location in xcmsVis:**
- `R/xcms-utils.R` (lines 102-153)

**XCMS Source:**
- https://github.com/sneumann/xcms/blob/devel/R/do_adjustRtime-functions.R

**Used By:**
- `gplot.LamaParama()` - Alignment visualization

**Stability:** Stable (pure R implementation)

---

### 3. `.rt_model()` - RT Alignment Model

**Location in xcmsVis:**
- `R/xcms-utils.R` (lines 155-211)

**XCMS Source:**
- https://github.com/sneumann/xcms/blob/devel/R/do_adjustRtime-functions.R

**Used By:**
- `gplot.LamaParama()` - Alignment visualization

**Stability:** Stable (pure R implementation)

---

### 4. `.check_gam_library()` - Helper Function

**Location in xcmsVis:**
- `R/xcms-utils.R` (lines 213-217)

**XCMS Source:**
- https://github.com/sneumann/xcms/blob/devel/R/do_adjustRtime-functions.R

**Used By:**
- `.rt_model()` helper

**Stability:** Very stable (simple check)

---

## Maintenance Checklist

### Quarterly Review (Every 3 Months)

Run this checklist to check for XCMS updates:

```bash
# 1. Check XCMS devel branch for changes
git clone https://github.com/sneumann/xcms.git /tmp/xcms
cd /tmp/xcms
git log --since="3 months ago" -- R/c.R R/do_adjustRtime-functions.R src/util.c

# 2. If changes found, compare with our implementation
diff /tmp/xcms/R/c.R R/xcms-utils.R
diff /tmp/xcms/src/util.c src/util.c

# 3. If differences found, update our code
#    - Update R/xcms-utils.R
#    - Update src/util.c and src/util.h
#    - Update "Last synchronized" date in R/xcms-utils.R

# 4. Run tests to validate
Rscript -e "devtools::test_file('tests/testthat/test-xcms-utils.R')"

# 5. Run full package check
Rscript -e "devtools::check()"

# 6. Commit changes with clear message
git add R/xcms-utils.R src/util.c src/util.h
git commit -m "chore: sync XCMS utility functions (updated YYYY-MM-DD)"
```

### When XCMS Releases New Version

Check for changes when XCMS releases:

1. Go to: https://github.com/sneumann/xcms/releases
2. Review release notes for changes to copied functions
3. If changes, follow quarterly review steps above
4. Update xcmsVis NEWS.md if user-facing impact

---

## Testing Strategy

### Test Coverage

All copied functions have comprehensive tests in `tests/testthat/test-xcms-utils.R`:

| Function | Test Cases | Purpose |
|----------|-----------|---------|
| `.descendMin()` | 13 tests | Validate C implementation, edge cases, real-world usage |
| `.applyRtAdjustment()` | 4 tests | Step function, unsorted input, margins, names |
| `.rt_model()` | 4 tests | Loess/GAM, outliers, weights |
| `.check_gam_library()` | 2 tests | Package availability |

### Running Tests

```r
# Run all XCMS utils tests
devtools::test_file("tests/testthat/test-xcms-utils.R")

# Run specific test
testthat::test_that(".descendMin finds correct minimum region", {
  # ...
})

# Check test coverage
covr::file_coverage("R/xcms-utils.R", "tests/testthat/test-xcms-utils.R")
```

### What Tests Validate

1. **Correctness:** Functions produce expected results
2. **Edge Cases:** Boundary conditions, empty inputs, extreme values
3. **Compatibility:** Behavior matches XCMS reference implementation
4. **Regression:** Detect when upstream XCMS changes behavior
5. **Integration:** Functions work correctly in actual use cases

---

## Documentation Requirements

### R Documentation (R/xcms-utils.R)

Each function must have:

✅ **@description** - What it does and why copied
✅ **@details** - Algorithm explanation
✅ **@source** - Direct links to XCMS source
✅ **@keywords internal** - Mark as internal
✅ **Maintenance Note** - How to update
✅ **Used by** - Which xcmsVis functions depend on it

### C Documentation (src/util.c)

Each function must have:

✅ **File header** - Why code is copied, license, copyright
✅ **Function comment** - Algorithm, parameters, return value
✅ **XCMS source reference** - Direct link to original
✅ **Maintenance notes** - Update process

### Test Documentation (tests/testthat/test-xcms-utils.R)

Each test file must have:

✅ **Header comment** - Purpose of tests
✅ **Test sections** - Organized by function
✅ **Test descriptions** - Clear test_that() descriptions
✅ **Comments** - Explain non-obvious test cases

---

## Troubleshooting

### If Tests Fail After XCMS Update

1. **Check XCMS changelog** - Understand what changed
2. **Compare implementations** - Diff our code vs XCMS source
3. **Update tests** - If XCMS behavior legitimately changed
4. **Update code** - Sync with XCMS if necessary
5. **Update vignettes** - If user-facing impact

### If C Code Won't Compile

1. **Check R version** - Ensure compatibility
2. **Check compiler** - GCC/Clang versions
3. **Review XCMS** - See if they fixed compilation issues
4. **Test on multiple platforms** - macOS, Linux, Windows
5. **GitHub Actions** - Check CI/CD results

### If Function Behavior Diverges

1. **Run XCMS directly** - Compare output
2. **Update tests** - Add test case capturing difference
3. **Sync implementation** - Update our code
4. **Document change** - Update NEWS.md if user-visible

---

## Risk Assessment

### Low Risk ✅

- **Pure R functions** (`.applyRtAdjustment`, `.rt_model`)
  - Easy to maintain
  - No compilation issues
  - Can be updated quickly

- **Simple C code** (`.descendMin`)
  - Small, focused function (15 lines)
  - Stable for years
  - Well-tested

### Mitigation Strategies

1. **Comprehensive testing** - Catch changes early
2. **Regular monitoring** - Quarterly review
3. **Clear documentation** - Easy to update
4. **Community engagement** - Request XCMS export functions

---

## Communication with XCMS Maintainers

### If Multiple Packages Need These Functions

Consider opening a GitHub issue:

**Title:** "Request: Export utility functions for ecosystem use"

**Content:**
```markdown
## Background

We're developing xcmsVis, which provides ggplot2 versions of XCMS plots.
We need several XCMS internal functions (`.descendMin`, `.applyRtAdjustment`,
etc.) for our implementations.

## Problem

R packages cannot use `:::` to access internal functions without generating
R CMD check NOTEs, which fails Bioconductor standards.

## Current Solution

We've copied these functions with full attribution (see:
https://github.com/stanstrup/xcmsVis/blob/main/R/xcms-utils.R)

## Request

Would you consider:
1. Exporting these utility functions, OR
2. Creating an xcmsUtils package, OR
3. Documenting official way for ecosystem packages to use these functions

This would benefit the entire XCMS ecosystem and avoid code duplication.

## Functions Needed

- `.descendMin()` - Peak boundary detection
- `.applyRtAdjustment()` - RT correction
- `.rt_model()` - Alignment modeling

## Impact

Multiple packages could benefit from official access to these stable utilities.
```

---

## Version History

| Date | Action | XCMS Version | Notes |
|------|--------|--------------|-------|
| 2024-11-17 | Initial copy | devel branch | All 4 functions copied |
| YYYY-MM-DD | Review | | (Add entries during maintenance) |

---

## References

- **XCMS Repository:** https://github.com/sneumann/xcms
- **XCMS Documentation:** https://bioconductor.org/packages/xcms
- **R CMD check:** https://r-pkgs.org/r-cmd-check.html
- **Bioconductor Guidelines:** https://bioconductor.org/developers/package-guidelines/
- **xcmsVis Development:** See `CLAUDE.md` for full workflow

---

## Contact

**Questions?** Open an issue at: https://github.com/stanstrup/xcmsVis/issues

**XCMS Questions?** Contact: https://github.com/sneumann/xcms/issues
