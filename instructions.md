# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

All tasks completed!

## Completed

1) ✅ Re-added groupChromPeaks step after filterFile in vignette (correspondence is removed by filtering)
2) ✅ Converted gplotAdjustedRtime to proper S4 methods (XCMSnExp and XcmsExperiment)
   - Created R/AllGenerics.R with generic declaration
   - Implemented S4 methods in R/gplotAdjustedRtime-methods.R
   - Removed old function-based implementation
   - Added comprehensive S4 implementation guides in dev-docs/

## Next Steps

Once Bioconductor packages finish installing:
- Run `devtools::document()` to regenerate documentation
- Run `devtools::check()` to verify S4 methods work correctly
- Test with both XCMSnExp and XcmsExperiment objects in vignette
