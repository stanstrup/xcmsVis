# ggplot2 Version of plot for XcmsExperiment and XCMSnExp

Creates a two-panel visualization of MS data showing:

- Upper panel: Base Peak Intensity (BPI) chromatogram vs retention time

- Lower panel: m/z vs retention time scatter plot with intensity-based
  coloring

This is a ggplot2 implementation of XCMS's
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method for
MsExperiment objects, enabling modern visualization and interactive
plotting capabilities.

## Usage

``` r
# S4 method for class 'XcmsExperiment'
gplot(
  x,
  msLevel = 1L,
  peakCol = "#ff000060",
  col = "grey",
  colramp = grDevices::topo.colors,
  pch = 21,
  main = NULL,
  xlab = "Retention time",
  ...
)

# S4 method for class 'XCMSnExp'
gplot(
  x,
  msLevel = 1L,
  peakCol = "#ff000060",
  col = "grey",
  colramp = grDevices::topo.colors,
  pch = 21,
  main = NULL,
  xlab = "Retention time",
  ...
)
```

## Arguments

- x:

  XcmsExperiment or XCMSnExp object

- msLevel:

  integer(1) MS level to visualize (default: 1)

- peakCol:

  character(1) color for peak rectangles (default: "#ff000060")

- col:

  character(1) color for point borders (default: "grey")

- colramp:

  function color ramp for intensity mapping (default:
  grDevices::topo.colors)

- pch:

  integer(1) point shape (default: 21 = filled circle)

- main:

  character vector of titles (one per sample). If NULL, uses sample
  names.

- xlab:

  character(1) x-axis label (default: "Retention time")

- ...:

  additional arguments (for compatibility)

## Value

A ggplot or patchwork object showing the two-panel visualization. For
single samples, returns a patchwork object with two panels. For multiple
samples, returns a patchwork object with all sample plots stacked.

## Details

The function:

- Extracts spectra data filtered by MS level

- Applies adjusted retention times if available

- Upper panel: plots BPI (max intensity per retention time) with
  intensity-colored points

- Lower panel: plots m/z vs retention time scatter with
  intensity-colored points

- Overlays detected peaks as rectangles (if available)

- Uses consistent color scale across both panels based on intensity

## See also

[`plot,MsExperiment,missing-method`](https://rdrr.io/pkg/xcms/man/XcmsExperiment.html)
for the original XCMS implementation

## Examples

``` r
if (FALSE) { # \dontrun{
library(xcmsVis)
library(xcms)
library(MsExperiment)

# Load and filter data
fticr_xdata <- readMSData2(...)
mse <- filterRt(fticr_xdata, rt = c(175, 189)) %>%
       filterMzRange(mz = c(106.02, 106.07))

# Plot MS data
gplot(mse)

# With detected peaks
mse_peaks <- findChromPeaks(mse, ...)
gplot(mse_peaks, peakCol = "red")

# Multiple samples
gplot(mse[1:3])
} # }
```
