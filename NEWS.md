## Changes in v0.99.16


### Bug Fixes

* add 'Feature Group:' label to tooltip text ([13e2f84](https://github.com/stanstrup/xcmsVis/commit/13e2f8481732cdd2803e90c364d65c788c2c1df2))
* add text aesthetic to show Feature Group in plotly tooltips ([4b94020](https://github.com/stanstrup/xcmsVis/commit/4b94020baf9abc6dcac88ce46d7bae7d3d0c2d4b))


### Features

* improve tooltips and vignette clarity for feature groups ([bf6d4f8](https://github.com/stanstrup/xcmsVis/commit/bf6d4f852349781a2de62eb8178acb15ad6204ea))

## Changes in v0.99.15


### Bug Fixes

* properly separate line connections between feature groups ([876b706](https://github.com/stanstrup/xcmsVis/commit/876b7064130c32b1337b20ed132733665d9453dc))
* resolve gplotFeatureGroups example errors and warnings ([dbf8106](https://github.com/stanstrup/xcmsVis/commit/dbf8106327e51fc17963ea846abd471bb73c7191))
* sort features by m/z and limit vignette comparison plots ([7105e7f](https://github.com/stanstrup/xcmsVis/commit/7105e7f1daad02542839ff81462fc3f4998e5242))
* use geom_path instead of geom_line to preserve m/z ordering ([f2d8f23](https://github.com/stanstrup/xcmsVis/commit/f2d8f2311279e8c919180fdfc0dc52a2faeaf62d))


### Features

* Implement gplotFeatureGroups for feature group visualization ([75f7a9e](https://github.com/stanstrup/xcmsVis/commit/75f7a9e59fc4ebbbe9937d5be00ac1749373be75))

## Changes in v0.99.14


### Bug Fixes

* add missing geom_vline import to gplotChromPeakDensity ([405865a](https://github.com/stanstrup/xcmsVis/commit/405865a56d505f3583e140dadd23ea6ab2f48966))
* apply filterRt polygon fix to XChromatogram method ([92c19ac](https://github.com/stanstrup/xcmsVis/commit/92c19ac1b31669652459743f252c4751c00a02b8))
* completely rewrite gplotChromatogramsOverlay to match XCMS behavior ([2faec0a](https://github.com/stanstrup/xcmsVis/commit/2faec0a7173d097bac3b6286bee5b9ea26ce1a7a))
* correct layer ordering in gplotChromPeakDensity lower panel ([bec5673](https://github.com/stanstrup/xcmsVis/commit/bec5673fb03f46b303e0e99830440c6d360c6f79))
* correct rectangle positioning in gplotChromPeakDensity ([7479e45](https://github.com/stanstrup/xcmsVis/commit/7479e45ea8e1f491b192d7578c221e73bf6d4d5a))
* correct stacking behavior in gplotChromatogramsOverlay ([9194f79](https://github.com/stanstrup/xcmsVis/commit/9194f7968d32490ce0423d60c42d604b3f90579b))
* **doc:** formatting that makes rstudio live view happy ([a83ef91](https://github.com/stanstrup/xcmsVis/commit/a83ef91b1abeb60befa9850974f2efde47470e09))
* handle infinite values in gplot polygon rendering ([c8da796](https://github.com/stanstrup/xcmsVis/commit/c8da796dcb229372bbc5e01797693845b4c74da4))
* use Bootstrap grid instead of CSS flexbox for pkgdown compatibility ([f79605d](https://github.com/stanstrup/xcmsVis/commit/f79605d041c97c556426f64919d2bd98f918bcc2))
* use filterRt() for polygon rendering to match XCMS exactly ([1a5cb2a](https://github.com/stanstrup/xcmsVis/commit/1a5cb2ab9f54a49c2f59dbb3bce540ad54d5063f))
* use patchwork & operator in vignette custom_ggplot example ([dce3edc](https://github.com/stanstrup/xcmsVis/commit/dce3edc4be9ef82ec7b4f6833af54a6f813f9444))


### Features

* add gplot() method for XcmsExperiment and XCMSnExp ([8fd87fb](https://github.com/stanstrup/xcmsVis/commit/8fd87fbf5e2083b63352cd7ba80f119875629103))
* add side-by-side comparison for correspondence results ([b0113ad](https://github.com/stanstrup/xcmsVis/commit/b0113ad8ed7a9feee2ef81568a32ccdc6bdf561b))
* implement gplotChromatogramsOverlay for XChromatograms/MChromatograms ([acfe633](https://github.com/stanstrup/xcmsVis/commit/acfe633b604504cab5986a4bbe7e57a718f82af5))
* implement gplotChromPeakDensity for XChromatograms/MChromatograms ([beff00d](https://github.com/stanstrup/xcmsVis/commit/beff00d0957815f462fe476d38350202b010427c)), closes [hi#priority](https://github.com/hi/issues/priority)


### BREAKING CHANGES

* gplotChromatogramsOverlay now correctly overlays
multiple EICs (rows) from the same sample (column), not multiple
samples across the same EIC. This matches the original XCMS behavior.

Changes:
- Now loops through columns (samples) instead of rows (EICs)
- Overlays multiple rows (different EICs) in a single plot per sample
- Uses facet_wrap for multiple samples instead of patchwork
- Main titles now correspond to samples (columns) not EICs (rows)
- Updated all tests to reflect correct XCMS behavior

The key difference from XCMS plot():
- plot() overlays same EIC across different samples
- plotChromatogramsOverlay() overlays different EICs within same sample

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>

## Changes in v0.99.13


### Bug Fixes

* correct pkgdown deployment and documentation link ([a8f45ea](https://github.com/stanstrup/xcmsVis/commit/a8f45ea5ecc1d3c2ffa08fba3fa3fa9b13a459ab)), closes [#pages](https://github.com/stanstrup/xcmsVis/issues/pages)

## Changes in v0.99.12


### Bug Fixes

* re-add .nojekyll file creation to prevent Jekyll processing ([05e9fc6](https://github.com/stanstrup/xcmsVis/commit/05e9fc62da6e9fc84d03bd836518f6b8f5322b1c))

## Changes in v0.99.11


### Bug Fixes

* use JamesIves/github-pages-deploy-action instead ([65dc2bd](https://github.com/stanstrup/xcmsVis/commit/65dc2bd17812a6c5e8a237e35d65831e6bdfd9bd))

## Changes in v0.99.10


### Bug Fixes

* add github-pages environment to pkgdown workflow ([f2c20ef](https://github.com/stanstrup/xcmsVis/commit/f2c20efc87ba58fe5f8e2c7bfd9b68ec9c80882a))

## Changes in v0.99.9


### Bug Fixes

* configure BiocParallel for serial processing in tests ([e8b3979](https://github.com/stanstrup/xcmsVis/commit/e8b39796b2e25630385a4a515198620cc0c1c4c9))
* correct example code and cross-references ([bd86c11](https://github.com/stanstrup/xcmsVis/commit/bd86c11cd676de7b020d8d6e24656182a2a6b013))

## Changes in v0.99.8


### Bug Fixes

* **doc:** also used filtering for original function ([a43eaa5](https://github.com/stanstrup/xcmsVis/commit/a43eaa54e5fe4dd42f31bd6753cb373e92c4bc77))
* polygon type now matches original XCMS behavior exactly ([418668e](https://github.com/stanstrup/xcmsVis/commit/418668e51f5f4b8e02bc20beac728d73e36c3fc7))
* update tests to handle chromatograms without peaks correctly ([670a477](https://github.com/stanstrup/xcmsVis/commit/670a47727384520ccece591cc405f31b5790e5c1))

## Changes in v0.99.7


### Bug Fixes

* use GitHub Pages artifact deployment for pkgdown ([1ce3fc8](https://github.com/stanstrup/xcmsVis/commit/1ce3fc8c773495ee399ae3ad96215a43086d4606))

## Changes in v0.99.6


### Bug Fixes

* add complete example for ghighlightChromPeaks ([0a27bf1](https://github.com/stanstrup/xcmsVis/commit/0a27bf1873fcf505f96f893fbf43da6ac30837fc))

## Changes in v0.99.5


### Bug Fixes

* ensure .nojekyll file is created for pkgdown site ([29eb82c](https://github.com/stanstrup/xcmsVis/commit/29eb82c76dfb8cc544b8640c131d7d24691f1570))
* resolve R CMD check warnings in gplot ([86345f2](https://github.com/stanstrup/xcmsVis/commit/86345f241dde9140d17223af2f104785d05b6157))
* update prepare-news.sh path in release workflow ([f04ed39](https://github.com/stanstrup/xcmsVis/commit/f04ed39588c2f4fcf3933d9504e24fc0934668de))

## Changes in v0.99.4


### Bug Fixes

* highlightChromPeaks only works for XCMSnExp ([ebb1851](https://github.com/stanstrup/xcmsVis/commit/ebb18511129985b3a67a8a836a8ea10e1631af94))
* refactor gplot and ghighlightChromPeaks per code review ([14fb0de](https://github.com/stanstrup/xcmsVis/commit/14fb0de2a87424ef2dfe1c5348118127a84a47ca))
* remove library(xcmsVis) from vignettes for R CMD check ([0d1aad6](https://github.com/stanstrup/xcmsVis/commit/0d1aad611063e4a334bc1b3a9827afa1b26b3746))
* restore library(xcmsVis) in vignette ([070bae0](https://github.com/stanstrup/xcmsVis/commit/070bae0b02650123007d903e5eee082944953e44))
* reverse viridis scale in gplotChromPeakImage to match XCMS ([049d978](https://github.com/stanstrup/xcmsVis/commit/049d978bfaa868a78b52d01d80e94fe7e4af2668))


### Features

* add gplot() method for XChromatogram objects ([9dbbc33](https://github.com/stanstrup/xcmsVis/commit/9dbbc336da2e76416fe2819f91a05170366b3cf0))

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
