# xcmsVis

Modern, interactive visualizations for XCMS metabolomics data using
ggplot2.

## Overview

`xcmsVis` provides ggplot2 implementations of XCMS plotting functions,
enabling:

- Modern, publication-ready visualizations
- Interactive plots through plotly integration
- Consistent styling across all plots
- Full compatibility with both XCMSnExp and XcmsExperiment objects

This package complements the [XCMS
package](https://github.com/sneumann/xcms) by reimplementing its base
graphics plots using ggplot2.

## Status

**All 11 modern XCMS plotting functions are now implemented!**

| Metric         | Status                                          |
|----------------|-------------------------------------------------|
| Core Functions | 11/11 complete ✅                               |
| Object Support | XCMSnExp ✅ / XcmsExperiment ✅ / LamaParama ✅ |
| Vignettes      | 7 comprehensive guides                          |
| Test Coverage  | All tests passing ✅                            |

## Installation

``` r
# Install from GitHub
devtools::install_github("stanstrup/xcmsVis")
```

## Implemented Functions

### Retention Time and Alignment

- **[`gplotAdjustedRtime()`](https://stanstrup.github.io/xcmsVis/reference/gplotAdjustedRtime.md)** -
  Visualize retention time corrections
- **`gplot(LamaParama)`** - Landmark-based alignment parameters

### Peak Detection and Visualization

- **[`gplotChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeaks.md)** -
  Detected peaks in RT-m/z space
- **[`gplotChromPeakImage()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeakImage.md)** -
  Peak density heatmap across samples
- **[`gplotChromPeakDensity()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeakDensity.md)** -
  Peak density for parameter optimization
- **[`ghighlightChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/ghighlightChromPeaks.md)** -
  Peak annotation layers

### Chromatograms and EICs

- **`gplot(XChromatogram)`** - Single chromatogram with detected peaks
- **`gplot(XChromatograms)`** - Multiple chromatograms (stacked or
  separate)
- **[`gplotChromatogramsOverlay()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromatogramsOverlay.md)** -
  Overlay multiple EICs

### Feature Groups and MS/MS

- **[`gplotFeatureGroups()`](https://stanstrup.github.io/xcmsVis/reference/gplotFeatureGroups.md)** -
  Related features (isotopes, adducts, fragments)
- **[`gplotPrecursorIons()`](https://stanstrup.github.io/xcmsVis/reference/gplotPrecursorIons.md)** -
  MS/MS precursor ion visualization

### Full Experiment Visualization

- **`gplot(XcmsExperiment)`** - Base peak intensity and MS map

All functions work with both legacy (XCMSnExp) and modern
(XcmsExperiment) XCMS objects.

## Quick Start

``` r
library(xcmsVis)
library(xcms)
library(MsExperiment)

# Load data
xdata <- readMsExperiment(files = mzml_files)

# XCMS workflow
xdata <- findChromPeaks(xdata, param = CentWaveParam())
xdata <- groupChromPeaks(xdata, param = PeakDensityParam())
xdata <- adjustRtime(xdata, param = PeakGroupsParam())

# Visualize results
p <- gplotAdjustedRtime(xdata, color_by = sample_group)
print(p)

# Make it interactive
library(plotly)
ggplotly(p, tooltip = "text")

# Customize with ggplot2
p +
  theme_minimal() +
  labs(title = "RT Alignment Results")
```

## Example Visualizations

### Retention Time Alignment

``` r
gplotAdjustedRtime(xdata, color_by = sample_group)
```

### Chromatographic Peaks

``` r
gplotChromPeaks(xdata)
```

### Feature Groups

``` r
gplotFeatureGroups(xdata, featureGroups = c("FG.0001", "FG.0002"))
```

### Extract Ion Chromatograms

``` r
chr <- chromatogram(xdata, mz = c(305, 306), rt = c(2500, 3500))
gplot(chr)
```

## Vignettes

Comprehensive guides are available:

- [Retention Time Alignment
  Visualization](https://stanstrup.github.io/xcmsVis/articles/gplotAdjustedRtime.md)
- [Peak Detection and
  Visualization](https://stanstrup.github.io/xcmsVis/articles/peak-visualization.md)
- [Chromatogram
  Visualization](https://stanstrup.github.io/xcmsVis/articles/chromatogram-visualization.md)
- [Feature Groups
  Visualization](https://stanstrup.github.io/xcmsVis/articles/feature-groups-visualization.md)
- [RT Alignment Parameters
  (LamaParama)](https://stanstrup.github.io/xcmsVis/articles/alignment-parameters.md)
- [Precursor Ion
  Visualization](https://stanstrup.github.io/xcmsVis/articles/precursor-ions.md)

## Why xcmsVis?

### Interactive Plots

All plots are ggplot2 objects that seamlessly convert to interactive
plotly visualizations:

``` r
p <- gplotAdjustedRtime(xdata)
ggplotly(p)  # Instant interactivity with zoom, pan, hover tooltips
```

### Composable

Use patchwork to create custom layouts:

``` r
library(patchwork)
p1 <- gplotAdjustedRtime(xdata)
p2 <- gplotChromPeaks(xdata)
p1 / p2  # Stack vertically
```

### Publication-Ready

Full ggplot2 customization:

``` r
gplotAdjustedRtime(xdata) +
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Retention Time Correction",
       subtitle = "PeakGroups alignment method")
```

## Motivation

This package addresses the need discussed in [XCMS issue
\#551](https://github.com/sneumann/xcms/issues/551) for ggplot2-based
visualizations that can be easily made interactive using plotly.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Citation

This package reuses and adapts substantial code and algorithms from the
XCMS package, translating base R graphics implementations to ggplot2
while preserving the original visualization logic and functionality.

Original XCMS authors: - Colin A. Smith (original author) - Ralf
Tautenhahn (original author) - Steffen Neumann (original author) - And
many contributors

When using xcmsVis, please also cite the original XCMS package.
