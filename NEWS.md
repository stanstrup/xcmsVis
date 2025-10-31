# xcmsVis 0.2.0

## New Features

* Added support for `XcmsExperiment` objects (XCMS version 4+)
* `gplotAdjustedRtime()` now works with both `XCMSnExp` and `XcmsExperiment` objects
* Created internal utility functions for object type handling

## Bug Fixes

* Updated sample metadata extraction to handle both object types correctly

## Documentation

* Updated function documentation to reflect support for both object types
* Added utility functions for cleaner code architecture

# xcmsVis 0.1.0

## Initial Release

* Initial package setup
* Implemented `gplotAdjustedRtime()` - ggplot2 version of XCMS's `plotAdjustedRtime()`
* Added pkgdown documentation site
* Created comparison vignette
