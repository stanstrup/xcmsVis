/*
 * Utility functions for xcmsVis
 *
 * DescendMin function copied from XCMS package
 * Source: https://github.com/sneumann/xcms/blob/devel/src/util.c
 * License: GPL (>= 2)
 * Copyright: Original XCMS authors
 */

#include "util.h"

void DescendMin(double *yvals, int *numin, int *istart,
                int *ilower, int *iupper) {

    int i;

    for (i = *istart; i > 0; i--)
        if (yvals[i-1] >= yvals[i])
            break;
    *ilower = i;

    for (i = *istart; i < *numin-1; i++)
        if (yvals[i+1] >= yvals[i])
            break;
    *iupper = i;
}
