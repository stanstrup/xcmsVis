# 1.0.0  (2025-11-01)


### Bug Fixes

* correct GitHub Actions workflow and vignette workflow ([6dd52fd](https://github.com/stanstrup/xcmsVis/commit/6dd52fd2db53b6188958caa3e12cb3f4b18f7625))


### Features

* add semantic versioning and improve package infrastructure ([86a0704](https://github.com/stanstrup/xcmsVis/commit/86a0704ec2618a84806e8ed8e8c94e223ee100a7))

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
