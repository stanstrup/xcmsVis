/*
 * C function registration for xcmsVis
 *
 * Registers C functions to make them available to R via .C()
 */

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include "util.h"

/* Declare .C callable functions */
static const R_CMethodDef CEntries[] = {
    {"DescendMin", (DL_FUNC) &DescendMin, 5},
    {NULL, NULL, 0}
};

/* Register functions when package is loaded */
void R_init_xcmsVis(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, NULL, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
