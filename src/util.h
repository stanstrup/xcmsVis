/*
 * Utility functions for xcmsVis
 *
 * DescendMin function copied from XCMS package
 * Source: https://github.com/sneumann/xcms/blob/devel/src/util.h
 * License: GPL (>= 2)
 * Copyright: Original XCMS authors
 */

#ifndef UTIL_H
#define UTIL_H

void DescendMin(double *yvals, int *numin, int *istart,
                int *ilower, int *iupper);

#endif
