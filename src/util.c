/*
 * Utility functions for xcmsVis - copied from XCMS
 *
 * =============================================================================
 * MAINTENANCE NOTE: Code Duplication from XCMS
 * =============================================================================
 *
 * This file contains C code copied from the XCMS package to avoid using
 * internal functions via `:::` which would generate R CMD check NOTEs.
 *
 * XCMS Source: https://github.com/sneumann/xcms/blob/devel/src/util.c
 * Last Synced: 2024-11-17
 * License: GPL (>= 2) - same as XCMS
 * Copyright: Original XCMS authors (Colin A. Smith, Ralf Tautenhahn, et al.)
 *
 * Why Copy?
 * - R packages cannot use `:::` without R CMD check NOTEs
 * - Bioconductor requires 0 errors, 0 warnings, 0 notes
 * - XCMS does not export these utility functions
 * - This code is stable and unlikely to change
 *
 * Maintenance:
 * - Check XCMS source periodically for updates
 * - Run tests/testthat/test-xcms-utils.R to validate behavior
 * - Update "Last Synced" date when checking
 *
 * Alternative:
 * - Request XCMS maintainers to export these functions officially
 * - Open issue at: https://github.com/sneumann/xcms/issues
 *
 * =============================================================================
 */

#include "util.h"

/*
 * DescendMin - Find boundaries of local minimum region
 *
 * Starting from position 'istart', descend in both directions until
 * values stop decreasing. Used for peak density calculations to identify
 * feature boundaries.
 *
 * Parameters:
 *   yvals  - Array of intensity/density values
 *   numin  - Length of yvals array
 *   istart - Starting index (usually position of maximum)
 *   ilower - Output: lower boundary index
 *   iupper - Output: upper boundary index
 *
 * Algorithm:
 *   1. Descend left from istart while values are decreasing
 *   2. Descend right from istart while values are decreasing
 *   3. Return indices where descent stopped
 *
 * XCMS Source: src/util.c (function name: DescendMin)
 */
void DescendMin(double *yvals, int *numin, int *istart,
                int *ilower, int *iupper) {

    int i;

    /* Descend left: stop when next value is >= current value */
    for (i = *istart; i > 0; i--)
        if (yvals[i-1] >= yvals[i])
            break;
    *ilower = i;

    /* Descend right: stop when next value is >= current value */
    for (i = *istart; i < *numin-1; i++)
        if (yvals[i+1] >= yvals[i])
            break;
    *iupper = i;
}
