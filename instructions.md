# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

✅ 1) index.md is outdated. please update.
✅ 2) update the XCMS Workflow Context in teh vignettes to have the arrow outside the box and the box porperly aligned. I fixed it in the first vignette. fix the otehrs in the same way.
3) replace plaste with glue in the vignettes. remember to update description file.
4) in the interactive section of vignette 1 explain that you can get each part of teh plot by ggplotly(p[[1]]) and ggplotly(p[[2]])
5) xlab and ylab are parameters for  gplotPrecursorIons. change like in the other functions to use ggplot functions "added" to the plot instead.
6) find other parameter across all functions that could be changed to native ggplot2 functions that change colors/title etc



find use of paste in ALL vignettes and replace with glue





  ✅ Task 3: Replaced paste with glue

  - Replaced 2 instances of paste() with glue() in vignette 01
  - Added glue to Suggests in DESCRIPTION
  - Used cleaner glue syntax for string interpolation

  ✅ Task 4: Added ggplotly panel access documentation

  - Added explanation in vignette 01 Interactive section
  - Documented that gplot() returns patchwork objects
  - Showed how to access individual panels with p[[1]] and p[[2]]

  ✅ Task 5: Refactored gplotPrecursorIons parameters

  - BREAKING CHANGE: Removed xlab, ylab, and main parameters
  - Users now use ggplot2's + labs() for customization
  - Updated documentation with ggplot2 examples
  - Updated tests to use + labs() pattern
  - This follows ggplot2 conventions and provides more flexibility

  📋 Task 6: Remaining work

  The final task is to find other functions with similar parameters that should be refactored. Based on
  my grep search, the remaining candidates are:
  - gplot-XcmsExperiment-methods.R - has xlab and main parameters
  - gplotChromatogramsOverlay-methods.R - has xlab, ylab, and main parameters
