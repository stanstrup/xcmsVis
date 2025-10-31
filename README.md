# xcmsVis

Modern, interactive visualizations for XCMS metabolomics data using ggplot2.

## Overview

`xcmsVis` provides ggplot2 implementations of XCMS plotting functions, enabling:

- Modern, publication-ready visualizations
- Interactive plots through plotly integration
- Consistent styling across all plots
- Full compatibility with XCMSnExp objects

This package complements the [XCMS package](https://github.com/sneumann/xcms) by reimplementing its base graphics plots using ggplot2.

## Installation

```r
# Install from GitHub (development version)
# devtools::install_github("yourusername/xcmsVis")
```

## Features

### Current Functions

- `gplotAdjustedRtime()` - ggplot2 version of XCMS's `plotAdjustedRtime()`

### Planned Functions

Future releases will include ggplot2 versions of:
- `plotQC()`
- `plotChromPeaks()`
- `plotChromPeakDensity()`
- And more!

## Usage

```r
library(xcmsVis)
library(xcms)

# Load your XCMSnExp object
# data <- readMSData(...)
# Perform peak detection, alignment, etc.

# Create an interactive retention time adjustment plot
p <- gplotAdjustedRtime(data, color_by = sample_group)

# Make it interactive
library(plotly)
ggplotly(p, tooltip = "text")
```

## Motivation

This package addresses the need discussed in [XCMS issue #551](https://github.com/sneumann/xcms/issues/551) for ggplot2-based visualizations that can be easily made interactive using plotly.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details
