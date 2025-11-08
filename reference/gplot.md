# ggplot2 Version of plot for XChromatogram

Creates a ggplot2 version of a chromatogram with detected peaks marked.
This is equivalent to the base R
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method for
XChromatogram objects.

## Usage

``` r
gplot(x, ...)

# S4 method for class 'XChromatogram'
gplot(
  x,
  col = "black",
  lty = 1,
  type = "l",
  xlab = "retention time",
  ylab = "intensity",
  main = NULL,
  peakType = c("polygon", "point", "rectangle", "none"),
  peakCol = "#00000060",
  peakBg = "#00000020",
  peakPch = 1,
  ...
)

# S4 method for class 'XChromatograms'
gplot(
  x,
  col = "#00000060",
  lty = 1,
  type = "l",
  xlab = "retention time",
  ylab = "intensity",
  main = NULL,
  peakType = c("polygon", "point", "rectangle", "none"),
  peakCol = "#00000060",
  peakBg = "#00000020",
  peakPch = 1,
  ...
)

# S4 method for class 'MChromatograms'
gplot(
  x,
  col = "#00000060",
  lty = 1,
  type = "l",
  xlab = "retention time",
  ylab = "intensity",
  main = NULL,
  peakType = c("polygon", "point", "rectangle", "none"),
  peakCol = "#00000060",
  peakBg = "#00000020",
  peakPch = 1,
  ...
)
```

## Arguments

- x:

  An `XChromatogram` or `MChromatograms` object.

- ...:

  Additional arguments (for compatibility with plot).

- col:

  Color for the chromatogram line (default: "black").

- lty:

  Line type for chromatogram (default: 1).

- type:

  Plot type (default: "l" for line).

- xlab:

  X-axis label (default: "retention time").

- ylab:

  Y-axis label (default: "intensity").

- main:

  Plot title (default: NULL).

- peakType:

  Type of peak annotation: "polygon", "point", "rectangle", or "none"
  (default: "polygon").

- peakCol:

  Color for peak markers (default: "#00000060").

- peakBg:

  Background color for peak markers (default: "#00000020").

- peakPch:

  Point character for peak markers when peakType = "point" (default: 1).

## Value

A ggplot object.

## Details

This function creates a complete chromatogram plot with detected peaks
automatically marked, similar to the base R
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method for
XChromatogram objects. If the chromatogram contains detected peaks, they
will be shown according to the `peakType` parameter.

## See also

[`plot,XChromatogram,ANY-method`](https://rdrr.io/pkg/xcms/man/XChromatogram.html)
for the original XCMS implementation

## Examples

``` r
# \donttest{
library(xcmsVis)
library(xcms)
library(faahKO)
library(MsExperiment)
library(ggplot2)

# Load and process example data
cdf_files <- system.file("cdf/KO/ko15.CDF", package = "faahKO")
xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files)
xdata <- xcms::findChromPeaks(xdata, param = xcms::CentWaveParam())

# Extract chromatogram
chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))
#> Extracting chromatographic data
#> Processing chromatographic peaks

# Plot with ggplot2
gplot(chr[1, 1])

# }
```
