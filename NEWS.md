# [1.1.0](https://github.com/stanstrup/xcmsVis/compare/v1.0.0...v1.1.0)  (2025-11-04)


### Bug Fixes

* 1) provide spectraOrigin_base for matching column names and omit files filtered away after alignment. ([8aceeae](https://github.com/stanstrup/xcmsVis/commit/8aceeae0c8f3bdf977b26904284559c04489c357))
* actually working version of gplotAdjustedRtime that for now works on XcmsExperiment objects. some imports missing. will fix later ([5f9898c](https://github.com/stanstrup/xcmsVis/commit/5f9898c3a62c25b2c437856dc85355056bdb21f0))
* add groupChromPeaks after filterFile in tests ([73b30f4](https://github.com/stanstrup/xcmsVis/commit/73b30f4498a7ffc78d6cab82b67734df38307400))
* add MSnbase to Imports and fix missing global variables ([772346e](https://github.com/stanstrup/xcmsVis/commit/772346edef8c6ddcbb7cf6c6a7348fed73035760))
* correct test fixtures and helper functions for dual-class support ([cf9b1bd](https://github.com/stanstrup/xcmsVis/commit/cf9b1bd6d3261de0593841f87fd55f33cc5a65b0))
* exclude quarto cache from R package builds ([764d68f](https://github.com/stanstrup/xcmsVis/commit/764d68f307e8b373c2721d19315d02a78bced1e0))
* fixed .get_spectra_data to ahve the same columns ([75b2b2b](https://github.com/stanstrup/xcmsVis/commit/75b2b2ba2b424df17ec808b67c84f9bfe09d4090))
* fixed imports in gplotAdjustedRtime ([39aa2b3](https://github.com/stanstrup/xcmsVis/commit/39aa2b3b8106821f6926660d9d538c9b296a3265))
* re-add groupChromPeaks after filterFile in vignette ([fe46d99](https://github.com/stanstrup/xcmsVis/commit/fe46d9915b00af73de70f54a006102a1df28a065))
* replace Quarto columns with HTML flexbox for pkgdown compatibility ([646b3ef](https://github.com/stanstrup/xcmsVis/commit/646b3ef643016f3073914f9e59dd7cdf0a92ad52))


### Features

* add comprehensive alt-text to all vignette figures ([89a33aa](https://github.com/stanstrup/xcmsVis/commit/89a33aad851b12a1477feb601975ea5272901f8f))
* add comprehensive testing and documentation for gplotAdjustedRtime ([552315e](https://github.com/stanstrup/xcmsVis/commit/552315ea8a83a0ab75e0a00c44ec09b2414e5395))
* add helper function to get spectra data from both object types ([47038d7](https://github.com/stanstrup/xcmsVis/commit/47038d7ded63a1fb661028456cce79c7746557e0))

# 1.0.0   (2025-11-01)


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
