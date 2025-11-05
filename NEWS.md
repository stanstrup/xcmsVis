## Changes in v0.99.3


### Bug Fixes

* constrain version to 0.99.x for Bioconductor development ([5de5bfd](https://github.com/stanstrup/xcmsVis/commit/5de5bfd0250e6f7ae59a1c4c363865f39db0b99c))
* correct NEWS.md to use 0.99.x versioning ([f0978fd](https://github.com/stanstrup/xcmsVis/commit/f0978fde94476bb49ce52e1942c8185da222b30a))

## Changes in v0.99.2


### Features

* add gplotChromPeaks, gplotChromPeakImage, and ghighlightChromPeaks ([0893bfa](https://github.com/stanstrup/xcmsVis/commit/0893bfa073b1f26edb7f7114e3478604f3d8e6a7))
* add SystemRequirements for Quarto vignettes ([498afc6](https://github.com/stanstrup/xcmsVis/commit/498afc6704c0170096651405fe0be09ca0ce3ee3))
* add comprehensive vignette for peak visualization functions


### Bug Fixes

* constrain version to 0.99.x for Bioconductor development
* 1) convert from MsExperiment to XcmsExperiment to skip the peak picking ([707aadb](https://github.com/stanstrup/xcmsVis/commit/707aadb2b16d70c2e069997e9f4432919be88199))
* account for OnDiskMSnExp and get filenames if not in pData. ([b1af112](https://github.com/stanstrup/xcmsVis/commit/b1af11225513a780bf09cac9fcfa72d6f6f87299))
* add BiocParallel to Suggests and fix fileNames import ([69fb33e](https://github.com/stanstrup/xcmsVis/commit/69fb33e6c828329101eb5085d4f66cfac6048913))
* add missing dplyr::n import to utils.R ([dd8b918](https://github.com/stanstrup/xcmsVis/commit/dd8b9185762a2e3e48575bf637f8bd44db0d1a5b))
* add Quarto setup to GitHub Actions workflows
* address BiocCheck requirements ([b1c4d5f](https://github.com/stanstrup/xcmsVis/commit/b1c4d5fef22ed0f8d4e93bcc9065d395837c62d0))
* coerce instead of new peakpicking ([159c06a](https://github.com/stanstrup/xcmsVis/commit/159c06a9f25603e00943db8f4b5793afce1a4071))
* consistency of objects ([5e52665](https://github.com/stanstrup/xcmsVis/commit/5e5266556dd2e595bd5526089089e3f24607d0c4))
* correct version ordering in NEWS.md ([026dbcf](https://github.com/stanstrup/xcmsVis/commit/026dbcfe338f7752cf588ce856b969f16aa95502))
* corrected tests. ([3b61b79](https://github.com/stanstrup/xcmsVis/commit/3b61b79361a7ada898e6f8832a39be9c51297702))
* properly import is() from methods package ([4086c92](https://github.com/stanstrup/xcmsVis/commit/4086c92e4c877c82113a61b0ce17b774b1f895d3))
* remove BPPARAM from groupChromPeaks calls ([26eec03](https://github.com/stanstrup/xcmsVis/commit/26eec03cdeab6d6eac078819de9dc37fd4ed26ac))
* remove links from NEWS.md headings for pkgdown compatibility ([8262eec](https://github.com/stanstrup/xcmsVis/commit/8262eec7cd6e35cdd0b3196c7ec7fbce291b2178))
* remove unused methods from Imports ([358535b](https://github.com/stanstrup/xcmsVis/commit/358535bc4663e846b1269f78daf9f5334c54014c))
* resolve R CMD check warnings ([d892e19](https://github.com/stanstrup/xcmsVis/commit/d892e19dd13d14d9ad1e08b57a3c4f5ada25a101))
* use SerialParam in tests to avoid parallel processing warnings ([abbfb4f](https://github.com/stanstrup/xcmsVis/commit/abbfb4f58dd1151dad2e41921d40c5664e7d9a4c))


### Performance Improvements

* use SerialParam in vignette for faster processing ([382f301](https://github.com/stanstrup/xcmsVis/commit/382f301d2925e0da8d9392dfee4c9350c152974b))

## Changes in v0.99.0


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

## Changes in v0.2.0

### Bug Fixes

* correct GitHub Actions workflow and vignette workflow ([6dd52fd](https://github.com/stanstrup/xcmsVis/commit/6dd52fd2db53b6188958caa3e12cb3f4b18f7625))

### Features

* add semantic versioning and improve package infrastructure ([86a0704](https://github.com/stanstrup/xcmsVis/commit/86a0704ec2618a84806e8ed8e8c94e223ee100a7))

## Changes in v0.1.0

### Features

* Support for both XCMSnExp and XcmsExperiment objects
* Add utility functions for object type handling (.get_sample_data, .validate_xcms_object)
* Comprehensive test suite with faahKO example data
* Working vignette with executable code examples using faahKO data
* pkgdown documentation site

### Bug Fixes

* Fix vignette to use real data instead of eval=FALSE examples
* Update sample metadata extraction to handle both object types correctly

## Changes in v0.0.1

### Features

* Initial release
* Implement gplotAdjustedRtime() function
* ggplot2 visualization of retention time adjustment
* Interactive tooltip support for plotly
* Complete package infrastructure (CI/CD, documentation, tests)
* Comparison vignette showing XCMS vs xcmsVis approaches
