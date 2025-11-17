# Internal XCMS utility functions

These functions are copied from the XCMS package to avoid using `:::`
calls, which would generate R CMD check NOTEs and fail Bioconductor
standards.

## Source

https://github.com/sneumann/xcms/blob/devel/R/c.R

https://github.com/sneumann/xcms/blob/devel/R/do_adjustRtime-functions.R

https://github.com/sneumann/xcms/blob/devel/src/util.c

## Why Copy Instead of Import

R packages cannot use `package:::function()` to access internal
functions without generating a NOTE in R CMD check. Since Bioconductor
requires 0 errors, 0 warnings, and 0 notes, we copy these stable utility
functions rather than depending on XCMS internals.

## Maintenance

**Last synchronized:** 2024-11-17

**XCMS source version:** devel branch (accessed 2024-11-17)

**XCMS GitHub:** https://github.com/sneumann/xcms

**Functions copied:**

- `.descendMin()` - C + R wrapper from `R/c.R` and `src/util.c`

- `.applyRtAdjustment()` - Pure R from `R/do_adjustRtime-functions.R`

- `.rt_model()` - Pure R from `R/do_adjustRtime-functions.R`

- `.check_gam_library()` - Helper for `.rt_model()`

## Update Process

To update these functions:

1.  Check XCMS source at https://github.com/sneumann/xcms/tree/devel

2.  Compare with current implementation in this file

3.  Update both R wrapper and C code (if changed)

4.  Run tests in `tests/testthat/test-xcms-utils.R`

5.  Update "Last synchronized" date above

## Stability

These are low-level utility functions that have remained stable in XCMS
for many years. Breaking changes are unlikely but should be monitored.

## Alternative Approach

If these functions are needed by multiple packages, consider requesting
that XCMS maintainers export them officially. Open an issue at:
https://github.com/sneumann/xcms/issues

## Author

Original XCMS authors (Colin A. Smith, Ralf Tautenhahn, Steffen Neumann,
Johannes Rainer, et al.)
