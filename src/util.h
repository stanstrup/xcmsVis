/*
 * Utility functions for xcmsVis - copied from XCMS
 *
 * Header file for utility functions copied from XCMS package.
 * See util.c for detailed documentation and maintenance notes.
 *
 * XCMS Source: https://github.com/sneumann/xcms/blob/devel/src/util.h
 * License: GPL (>= 2) - same as XCMS
 * Copyright: Original XCMS authors
 */

#ifndef UTIL_H
#define UTIL_H

/*
 * DescendMin - Find boundaries of local minimum region
 *
 * See util.c for full documentation.
 */
void DescendMin(double *yvals, int *numin, int *istart,
                int *ilower, int *iupper);

#endif
