# xcmsVis

<!-- badges: start -->
[![R-CMD-check](https://github.com/stanstrup/xcmsVis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/stanstrup/xcmsVis/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

Modern, interactive visualizations for XCMS metabolomics data using ggplot2.

## Overview

`xcmsVis` provides ggplot2 implementations of XCMS plotting functions, enabling:

- Modern, publication-ready visualizations
- Interactive plots through plotly integration
- Consistent styling across all plots
- Full compatibility with both XCMSnExp and XcmsExperiment objects

This package complements the [XCMS package](https://github.com/sneumann/xcms) by reimplementing its base graphics plots using ggplot2.

## Installation

```r
# Install from GitHub (development version)
# devtools::install_github("yourusername/xcmsVis")
```

## Features

### Current Functions

- `gplotAdjustedRtime()` - ggplot2 version of `plotAdjustedRtime()`
- `gplotChromPeaks()` - ggplot2 version of `plotChromPeaks()`
- `gplotChromPeakImage()` - ggplot2 version of `plotChromPeakImage()`
- `gplot()` - ggplot2 version of `plot()` for XChromatogram objects
- `ghighlightChromPeaks()` - ggplot2 version of `highlightChromPeaks()`

### Planned Functions

Future releases will include ggplot2 versions of:
- `plotQC()`
- `plotChromPeakDensity()`
- And more!

## Usage

```r
library(xcmsVis)
library(xcms)

# Works with XcmsExperiment (XCMS v4+)
xdata <- readMsExperiment(files = mzml_files)
# ... perform peak detection, alignment, etc.

# Create retention time adjustment plot
p <- gplotAdjustedRtime(xdata, color_by = sample_group)
print(p)

# Make it interactive
library(plotly)
ggplotly(p, tooltip = "text")

# Also works with XCMSnExp (XCMS v3)
xdata_v3 <- readMSData(files = mzml_files, mode = "onDisk")
# ... perform XCMS workflow
p <- gplotAdjustedRtime(xdata_v3, color_by = sample_group)
```

## Motivation

This package addresses the need discussed in [XCMS issue #551](https://github.com/sneumann/xcms/issues/551) for ggplot2-based visualizations that can be easily made interactive using plotly.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details
