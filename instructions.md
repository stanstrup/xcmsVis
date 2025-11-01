# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

1) fix the github pipeline. fetch yourself the result
2) fix following warning when making the pkgdown site:
✖ URLs not ok.
  In DESCRIPTION, URL is missing package url
  (https://stanstrup.github.io/xcmsVis).
  See details in `vignette(pkgdown::metadata)`.
3) error when making the vignette. please try and fix until it works:
Error
: 
! in callr subprocess.
Caused by error in `.f(.x[[i]], ...)`:
! Failed to render vignettes/comparing-visualizations.Rmd.
✖ Quitting from comparing-visualizations.Rmd:70-96 [example_workflow]
Caused by error:
! No feature definitions present in 'object'. Please perform first a correspondence analysis using 'groupChromPeaks'
ℹ See `$stdout` and `$stderr` for standard output and error.
Type .Last.error to see the more details.
  
