## Changes in v0.2.0

### Features

* Support for both XCMSnExp and XcmsExperiment objects
* Add utility functions for object type handling (.get_sample_data, .validate_xcms_object)
* Comprehensive test suite with faahKO example data
* Working vignette with executable code examples using faahKO data
* pkgdown documentation site

### Bug Fixes

* Fix vignette to use real data instead of eval=FALSE examples
* Update sample metadata extraction to handle both object types correctly

## Changes in v0.1.0

### Features

* Initial release
* Implement gplotAdjustedRtime() function
* ggplot2 visualization of retention time adjustment
* Interactive tooltip support for plotly
* Complete package infrastructure (CI/CD, documentation, tests)
* Comparison vignette showing XCMS vs xcmsVis approaches
