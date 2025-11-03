# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

1) ✅ in the vignette, data is loaded twice. only load one time and reuse and only do peak picking once.
2) ✅ every plot should have both the ggplot2 version and the original version. is it possible to compare them side by side? Quarto should have an option to create "columns" but I don't know if pkgdown uses quarto. If not is it possible to do the same as pkgdown in quarto? if so convert to quarto.
3) ✅ Tests should be all combinations of the following conditions: (XcmsExperiment, XCMSnExp), subset or not, filterFile or not. Can the data be loaded only once and all tests run down stream?
