# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

vignette 2 related: 

1) Use loadXcmsData("faahko_sub2") instead that has already been peak picked and remove the custom peak picking
2) in gplot for chromatogram it would be useful if the tooltip for the polygon gave teh peak ID. that would be in the rowname from chromPeaks(x).
3) check if whichPeaks ghighlightChromPeaks is doing what it is supposed to. in the example the peaks are the same. compare to the original in xcms-reference


vignette 3 related:  
1) gplotChromPeakDensity shows x and y in hte tooltip when using ggplotly. rename the variables in gplotChromPeakDensity before plotting so that they have proper names. "Peak density" seems appropiate for the y axis. "Retention time" for the x axis.


vignette 4 related: 

1) don't use the internal function, sample_data <- xcmsVis:::.get_sample_data(xdata_peaks), in the vignette. SampleData should work
2) 
