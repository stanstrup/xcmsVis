# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

✅ vignette 2 completed (commit 1a684ad):

✅ 1) Use loadXcmsData("faahko_sub2") instead that has already been peak picked and remove the custom peak picking
✅ 2) in gplot for chromatogram it would be useful if the tooltip for the polygon gave teh peak ID. that would be in the rowname from chromPeaks(x).
✅ 3) check if whichPeaks ghighlightChromPeaks is doing what it is supposed to. in the example the peaks are the same. compare to the original in xcms-reference


✅ vignette 3 completed (commit 874d113):

✅ 1) gplotChromPeakDensity shows x and y in hte tooltip when using ggplotly. rename the variables in gplotChromPeakDensity before plotting so that they have proper names. "Peak density" seems appropiate for the y axis. "Retention time" for the x axis.


vignette 4 related:

✅ 1) don't use the internal function, sample_data <- xcmsVis:::.get_sample_data(xdata_peaks), in the vignette. SampleData should work (commit 874d113)
2) The LamaParama example is weird. Model after the LamaParama example in https://sneumann.github.io/xcms/articles/xcms.html instead.
3) also see if you can understand Lama better from https://sneumann.github.io/xcms/articles/xcms.html and change the description that is a bit unclear.
4) missing side by side of gplot(LamaParama) and original from XCMS.


vignette 5 related:
1) Use loadXcmsData("faahko_sub2") instead that has already been peak picked and remove the custom peak picking


general for all vignettes:
vignette 5 has a section called "API Differences". check if similar is needed for other vignettes
