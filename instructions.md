# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

1) Turns out I am wrong. correspondance (grouping) is removed when filtering files. So after filtering it has to be redone. But not before changing subset.
So please re-add the groupChromPeaks step after filtering.
Remember to re-get the sampleGroups from the filtered object first:

sample_data <- xcmsVis:::.get_sample_data(filtered_object)

pdp <- PeakDensityParam(
  sampleGroups = sample_data$sample_group,
  minFraction = 0.4,
  bw = 30
)

groupChromPeaks...

2) now the function works with both data types I'd like you to make them proper methods like functions are in XCMS.
