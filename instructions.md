# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

* continue with the fix for the windows build on github
* gplot for XChromatogram doesn't do what it's supposed to do. it should be a chromatogram with picked peaks marked. now it is just dots. Please check the original code and revise. The code used might be in Msnbase instead of XCMS.
* highlightChromPeaks several things wrong:
  - There is missing a comparison to the original for highlightChromPeaks. Please add that. 
   -it needs as(xdata, "XCMSnExp") to run with the original version.
   - you use ggplot directly in the vignette instead of ggplot. the whole point is to not extract manually the data matrix.
   - ghighlightChromPeaks should also take the XCMSnExp/xcmsExperiment as input. not chr_data
* add badges to the github page
* there is too much justification everywhere. it reads like the old is bad and here we are with something better than that crap. it is not a nice approach to my colleague that made the original. for example "Modern styling with customizable appearance". there is no reason to repeat that. stating why once on teh front page is enough. Remove all this from the vignettes and stick to dry facts.
* when I have confirmed that all works then next is implementing all other plots. Follow the same recipe. If you need to also get plots from Msnbase then do so.
