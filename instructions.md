# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

## Completed Tasks

1) ✅ **Upper plot margin removal** - Added `theme(axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank())` to upper panel in gplot-XcmsExperiment-methods.R:214-216

2) ✅ **Removed patchwork_integration block** - Removed broken demonstration that tried to access non-existent chromPeaks from xcmsexperiment-visualization.qmd

3) ✅ **Fixed ms_levels block** - Replaced non-functional example with MTBLS8735 data that has MS2 in xcmsexperiment-visualization.qmd

4) ✅ **Reorganized all vignettes** - Moved all XCMS comparisons to "Supplementary: Comparison with Original XCMS" section at the end of:
   - gplotAdjustedRtime.qmd
   - peak-visualization.qmd
   - chromatogram-visualization.qmd
   - xcmsexperiment-visualization.qmd

5) ✅ **Code cleanup** - Removed unnecessary `::` notation from all R files:
   - R/gplot-XcmsExperiment-methods.R
   - R/gplotChromPeaks-methods.R
   - R/gplotChromPeakImage-methods.R
   - R/utils.R

All tests passing: 130 tests, 0 failures
