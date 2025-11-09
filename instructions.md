# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**


1) Add to your instructions to use the local copy of XCMS's source code in xcms-reference. Do not try to get it only.
2) Go through all vignettes and ensure a similar structure.
3) Again, no need to explain why ggplot2 is better in any vignette. that is done on the front page.
4) Many of the functions in this package use parameters like main and xlab and ylab. These parameters can be set with ggtitle and labs instead afterwards. Remove these parameters and instead show in the vignette how to set them with the ggplot2 functions. Make especially sure that the comparison to XCMS gives the same plot. Keep current defaults for those parameters you remove.
5) As in point 4 give suggestions for other parameters that can be handle outside the functions more elegantly.
