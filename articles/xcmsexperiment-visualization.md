# Visualizing XcmsExperiment MS Data

## Introduction

This vignette demonstrates the
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
function for visualizing XcmsExperiment and XCMSnExp objects. The
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
method creates a two-panel visualization showing:

- **Upper panel**: Base Peak Intensity (BPI) chromatogram vs retention
  time
- **Lower panel**: m/z vs retention time scatter plot

Both panels use intensity-based coloring to highlight signal strength,
and detected peaks are automatically overlaid as rectangles.

This is a ggplot2 reimplementation of XCMS’s
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method for
MsExperiment objects, enabling modern visualization capabilities
including:

- Interactive plots with plotly
- Customizable color schemes
- Easy composition with patchwork
- Publication-quality graphics

## Setup

``` r
library(xcms)
library(xcmsVis)
library(ggplot2)
library(plotly)
library(patchwork)
```

## Data Preparation

We’ll use pre-processed test data from XCMS for demonstration:

``` r
# Load pre-processed data with detected peaks
xdata <- loadXcmsData("faahko_sub2")

# Check data
cat("Samples:", length(xdata), "\n")
#> Samples: 3
cat("Total peaks detected:", nrow(chromPeaks(xdata)), "\n")
#> Total peaks detected: 248
```

For visualization purposes, we’ll filter to a specific retention time
and m/z region:

``` r
# Filter to focused region
mse <- filterRt(xdata, rt = c(2500, 2800))
mse <- filterMzRange(mse, mz = c(218, 220.5))

cat("Filtered data:\n")
#> Filtered data:
cat("  RT range:", paste(range(rtime(spectra(mse[1]))), collapse = " - "), "\n")
#>   RT range: 2501.378 - 2798.719
cat("  Number of spectra in sample 1:", length(spectra(mse[1])), "\n")
#>   Number of spectra in sample 1: 191
```

## Basic Usage

### Single Sample Visualization

The most basic usage is to plot a single sample:

``` r
gplot(mse[1])
```

![Two-panel plot showing BPI chromatogram (upper panel) and m/z vs
retention time scatter plot (lower panel) with intensity-based
coloring.](xcmsexperiment-visualization_files/figure-html/gplot_basic-1.png)

### Understanding the Two Panels

The visualization consists of two complementary views:

#### Upper Panel: BPI Chromatogram

The **Base Peak Intensity (BPI)** shows the maximum intensity at each
retention time across all m/z values in the filtered range. This gives
an overview of when signals are present in the chromatogram.

- Each point represents one retention time
- Y-axis shows the maximum intensity observed at that time
- Color indicates intensity magnitude
- Useful for identifying retention time regions with strong signals

#### Lower Panel: m/z vs RT Scatter

The **m/z vs retention time scatter** shows the complete mass spectral
data:

- X-axis: retention time
- Y-axis: m/z values
- Each point represents one data point from the raw spectra
- Color indicates intensity of that specific m/z at that retention time
- Shows the full two-dimensional structure of the LC-MS data

#### Peak Overlays

If chromatographic peaks have been detected (via
[`findChromPeaks()`](https://rdrr.io/pkg/xcms/man/findChromPeaks.html)),
they are automatically overlaid as rectangles showing:

- Peak retention time boundaries (left/right edges)
- Peak m/z boundaries (top/bottom edges)
- Semi-transparent red color by default

## Multiple Samples

When visualizing multiple samples,
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
creates a vertically stacked layout:

``` r
# Plot all three samples
gplot(mse)
```

![Three sets of two-panel plots stacked vertically, one for each sample,
showing BPI and m/z scatter
plots.](xcmsexperiment-visualization_files/figure-html/multiple_samples-1.png)

Each sample gets its own two-panel visualization, making it easy to
compare across samples.

## Customization

### Custom Colors

You can customize the line colors and peak colors:

``` r
gplot(mse[1],
      col = "blue",           # Point border color
      peakCol = "red")        # Peak rectangle color
```

![Two-panel plot with blue point borders and red peak rectangles,
demonstrating color
customization.](xcmsexperiment-visualization_files/figure-html/custom_colors-1.png)

### Custom Color Ramps

The intensity coloring uses a color ramp function. You can use any R
color ramp:

``` r
# Default: topo.colors
p1 <- gplot(mse[1]) +
  ggtitle("topo.colors (default)")

# Viridis (reversed for low=dark, high=bright)
library(viridisLite)
viridis_rev <- function(n) rev(viridis(n))
p2 <- gplot(mse[1], colramp = viridis_rev) +
  ggtitle("viridis (reversed)")

# Magma (reversed)
magma_rev <- function(n) rev(magma(n))
p3 <- gplot(mse[1], colramp = magma_rev) +
  ggtitle("magma (reversed)")

(p1 | p2 | p3)
```

![Three side-by-side plots showing different color ramps: topo.colors
(default), viridis, and
magma.](xcmsexperiment-visualization_files/figure-html/color_ramps-1.png)

> **Color Scale Direction**
>
> For MS data, it’s conventional to have **low intensity = dark** and
> **high intensity = bright**. The viridis scales are reversed
> (`rev(viridis(n))`) to follow this convention, where:
>
> - Dark purple/black = low intensity (noise, baseline)
> - Bright yellow = high intensity (strong signals)
>
> This makes it easier to identify strong signals at a glance.

#### More Viridis Palettes

The viridisLite package provides several perceptually-uniform color
scales:

``` r
library(viridisLite)

# Create reversed versions for MS convention
viridis_rev <- function(n) rev(viridis(n))
magma_rev <- function(n) rev(magma(n))
plasma_rev <- function(n) rev(plasma(n))
inferno_rev <- function(n) rev(inferno(n))

p1 <- gplot(mse[1], colramp = viridis_rev) + ggtitle("Viridis")
p2 <- gplot(mse[1], colramp = magma_rev) + ggtitle("Magma")
p3 <- gplot(mse[1], colramp = plasma_rev) + ggtitle("Plasma")
p4 <- gplot(mse[1], colramp = inferno_rev) + ggtitle("Inferno")

(p1 | p2) / (p3 | p4)
```

![Four plots showing different viridis palette options: viridis, magma,
plasma, and
inferno.](xcmsexperiment-visualization_files/figure-html/viridis_palettes-1.png)

**Choosing a palette:**

- **Viridis**: Good general-purpose, colorblind-friendly
- **Magma**: High contrast, good for presentations
- **Plasma**: Vibrant, good for highlighting features
- **Inferno**: Warm colors, good for print

All viridis palettes are: - Perceptually uniform (equal steps appear
equal) - Colorblind-friendly - Print-friendly (grayscale conversion
works well)

### Custom Titles

Provide custom titles for each sample:

``` r
# Custom sample names
gplot(mse, main = c("Knockout 1", "Knockout 2", "Wild Type"))
```

![Three stacked two-panel plots with custom sample names as
titles.](xcmsexperiment-visualization_files/figure-html/custom_titles-1.png)

### Point Styles

Customize the point shape using standard R `pch` values:

``` r
p1 <- gplot(mse[1], pch = 21) + ggtitle("Filled circles (pch = 21)")
p2 <- gplot(mse[1], pch = 22) + ggtitle("Filled squares (pch = 22)")

p1 | p2
```

![Two plots side by side showing different point shapes: filled circles
(pch=21) and filled squares
(pch=22).](xcmsexperiment-visualization_files/figure-html/point_styles-1.png)

## Interactive Visualization

Convert to interactive plotly for data exploration:

``` r
# Create static ggplot
p <- gplot(mse[1])

# Convert to interactive plotly
ggplotly(p)
```

The interactive version allows you to:

- **Hover** over points to see exact values
- **Zoom** into regions of interest
- **Pan** to explore different areas
- **Toggle** legend items to focus on specific features

### Accessing Individual Panels

When [`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
returns a patchwork object,
[`ggplotly()`](https://rdrr.io/pkg/plotly/man/ggplotly.html) only
converts the last panel to interactive. To access individual panels for
interactive conversion, use list indexing:

``` r
# Create the plot
p <- gplot(mse[1])

# Access and convert individual panels
ggplotly(p[[1]])  # Upper panel (BPI chromatogram) - interactive
ggplotly(p[[2]])  # Lower panel (m/z scatter) - interactive
```

This approach gives you full interactive control over each panel
separately, which can be useful when you want to:

- Examine the BPI chromatogram in detail
- Zoom into specific m/z regions in the scatter plot
- Export individual panels as interactive HTML widgets

**Note:** For patchwork objects with multiple samples, use `p[[i]]` to
access each sample’s plot, where `i` is the sample number. Each sample
plot itself contains two panels that can be further accessed with
`p[[i]][[j]]` where `j` is 1 for BPI or 2 for m/z scatter.

## Advanced Workflows

### Comparing Different MS Levels

This example uses data from MetaboLights (MTBLS8735) that contains both
MS1 and MS2 data:

``` r
# Load MS2 data from MetaboLights
library(MetaboLights)
library(MsExperiment)

param <- MetaboLightsParam(mtblsId = "MTBLS8735",
                           assayName = paste0("a_MTBLS8735_LC-MSMS_positive_",
                                            "hilic_metabolite_profiling.txt"),
                           filePattern = "MSMS_2_(E|A).*\\.mzML")

lcms2 <- readMsObject(MsExperiment(),
                     param,
                     keepOntology = FALSE,
                     keepProtocol = FALSE,
                     simplify = TRUE)

# Filter to a sensible range
lcms2_filtered <- filterRt(lcms2, rt = c(50, 150))
lcms2_filtered <- filterMzRange(lcms2_filtered, mz = c(200, 400))

# MS1 data (default)
p_ms1 <- gplot(lcms2_filtered[1], msLevel = 1L) + ggtitle("MS1")

# MS2 data
p_ms2 <- gplot(lcms2_filtered[1], msLevel = 2L) + ggtitle("MS2")

p_ms1 / p_ms2
```

This demonstrates how
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md) can
visualize different MS levels in the same experiment, useful for
examining fragmentation patterns alongside precursor ions.

### Focused Region Analysis

Combine filtering with visualization for detailed inspection:

``` r
# Focus on narrow RT window
mse_focused <- filterRt(xdata, rt = c(2700, 2820))
mse_focused <- filterMzRange(mse_focused, mz = c(204, 208))

gplot(mse_focused[1]) +
  ggtitle("Focused: RT 2700-2820, m/z 204-208")
```

![Highly zoomed plot showing a very narrow retention time window for
detailed peak
analysis.](xcmsexperiment-visualization_files/figure-html/focused_region-1.png)

### Comparing Samples

Create a comprehensive comparison across all samples:

``` r
# Filter to consistent region
mse_compare <- filterRt(xdata, rt = c(2600, 2800))
mse_compare <- filterMzRange(mse_compare, mz = c(206, 209))

# Plot all samples with custom titles
gplot(mse_compare,
      main = c("Sample A (KO)", "Sample B (KO)", "Sample C (WT)"),
      peakCol = "#ff000080")
```

![Multi-panel figure comparing all three samples with consistent scales
and
styling.](xcmsexperiment-visualization_files/figure-html/sample_comparison-1.png)

## Integration with Other Packages

### Custom ggplot2 Modifications

Add additional ggplot2 layers or modify themes. Use the `&` operator to
apply themes to all panels in the patchwork object:

``` r
gplot(mse[1]) &
  theme_minimal() &
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14)
  )
```

![gplot output with custom theme modifications and additional
annotations.](xcmsexperiment-visualization_files/figure-html/custom_ggplot-1.png)

> **Patchwork Operators**
>
> Since
> [`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
> returns a patchwork object (two panels combined), use:
>
> - `&` operator to apply themes/scales to **all panels**
> - `+` operator to add individual layers (but may cause issues with
>   multi-panel plots)
>
> For single-panel plots, both work. For multi-panel patchwork objects,
> `&` is safer.

## Use Cases

### Quality Control

Visualize raw MS data to check for:

- Signal intensity across retention time
- Presence of expected m/z ranges
- Peak detection quality
- Sample-to-sample consistency

``` r
# QC check: visualize all samples in a batch
gplot(mse, main = paste("QC:", c("Sample 1", "Sample 2", "Sample 3")))
```

![QC visualization showing all three samples for comparison of data
quality.](xcmsexperiment-visualization_files/figure-html/qc_example-1.png)

### Method Development

During method development, use
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md) to:

- Evaluate extraction efficiency across m/z ranges
- Optimize retention time windows
- Assess peak shapes and detection

### Publication Figures

Create publication-ready figures with custom styling:

``` r
# Use reversed viridis for conventional MS coloring
viridis_rev <- function(n) rev(viridis(n))

gplot(mse[1],
      main = "LC-MS Analysis: Sample KO15",
      col = "black",
      peakCol = "#d62728",
      colramp = viridis_rev) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    text = element_text(size = 12),
    legend.position = "right"
  )
```

![Publication-quality figure with clean aesthetics and appropriate
sizing.](xcmsexperiment-visualization_files/figure-html/publication_example-1.png)

## Performance Considerations

For large datasets, consider:

1.  **Filter first**: Use
    [`filterRt()`](https://rdrr.io/pkg/ProtGenerics/man/protgenerics.html)
    and
    [`filterMzRange()`](https://rdrr.io/pkg/ProtGenerics/man/protgenerics.html)
    to reduce data size
2.  **Subset samples**: Plot one sample at a time for interactive work
3.  **Static plots**: Use static ggplot2 for final figures (faster than
    plotly)

``` r
# Good: Filter to focused region
mse_small <- filterRt(large_data, rt = c(100, 200))
mse_small <- filterMzRange(mse_small, mz = c(200, 300))
gplot(mse_small[1])

# Avoid: Plotting huge unfiltered datasets
# gplot(large_data)  # May be slow
```

## Summary

The [`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
function for XcmsExperiment provides:

- **Two-panel visualization**: BPI chromatogram + m/z scatter
- **Automatic peak overlay**: Shows detected peaks as rectangles
- **Intensity coloring**: Highlights signal strength across the data
- **Full customization**: Colors, themes, point styles
- **Interactivity**: Easy conversion to plotly
- **Composition**: Integrates with patchwork and ggplot2 ecosystem

### Key Functions

| Function                                                                                            | Purpose                    | Input                 |
|-----------------------------------------------------------------------------------------------------|----------------------------|-----------------------|
| `gplot(XcmsExperiment)`                                                                             | Visualize full MS data     | XcmsExperiment object |
| `gplot(XChromatogram)`                                                                              | Visualize EIC              | XChromatogram object  |
| [`gplotChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeaks.md)             | Show peaks in RT/m/z space | XcmsExperiment object |
| [`gplotChromPeakDensity()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeakDensity.md) | Optimize correspondence    | XChromatograms object |

### When to Use Each

- **`gplot(XcmsExperiment)`**: Explore raw MS acquisitions, QC, method
  development
- **`gplot(XChromatogram)`**: Analyze specific compounds, peak
  integration
- **[`gplotChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeaks.md)**:
  Overview all detected peaks, retention time distribution
- **[`gplotChromPeakDensity()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeakDensity.md)**:
  Optimize peak grouping parameters

## Supplementary: Comparison with Original XCMS

This supplementary section provides side-by-side comparisons between the
original XCMS base R plotting functions and the new xcmsVis
ggplot2-based implementations. These comparisons are useful for
developers and users migrating from the original XCMS plotting
functions.

### gplot() vs plot()

#### Basic Single Sample Plot

##### XCMS plot()

``` r
# Base R graphics version
plot(mse[1])
```

![XCMS base R plot showing two panels: upper panel displays BPI
chromatogram, lower panel shows m/z vs retention time scatter plot with
intensity
colors.](xcmsexperiment-visualization_files/figure-html/supp_xcms_basic-1.png)

**Characteristics:** - Base R graphics - Fixed styling - Static output -
Direct to graphics device

##### xcmsVis gplot()

``` r
# ggplot2 version
gplot(mse[1])
```

![ggplot2 version of the same two-panel plot with cleaner aesthetics,
shared legend, and modern
styling.](xcmsexperiment-visualization_files/figure-html/supp_xcmsvis_basic-1.png)

**Characteristics:** - ggplot2 graphics - Fully customizable - Supports
interactivity - Returns ggplot object

#### With Custom Styling

##### XCMS plot()

``` r
# Base R version with custom colors
plot(mse[1], col = "blue", peakCol = "red")
```

![XCMS base R plot with custom colors
applied.](xcmsexperiment-visualization_files/figure-html/supp_xcms_styled-1.png)

##### xcmsVis gplot()

``` r
# ggplot2 version with custom colors and theme
gplot(mse[1], col = "blue", peakCol = "red") &
  theme_minimal()
```

![ggplot2 version with custom colors and additional theme
modifications.](xcmsexperiment-visualization_files/figure-html/supp_xcmsvis_styled-1.png)

### Feature Comparison Table

| Feature         | XCMS [`plot()`](https://rdrr.io/r/graphics/plot.default.html) | xcmsVis [`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md) |
|-----------------|---------------------------------------------------------------|-----------------------------------------------------------------------------|
| Graphics system | Base R                                                        | ggplot2                                                                     |
| Customization   | Limited                                                       | Extensive via ggplot2                                                       |
| Interactivity   | None                                                          | Via plotly                                                                  |
| Composition     | Difficult                                                     | Easy with patchwork                                                         |
| Return value    | NULL (side effect)                                            | ggplot/patchwork object                                                     |
| Theme support   | No                                                            | Yes (full ggplot2 themes)                                                   |
| Export quality  | Good                                                          | Publication-ready                                                           |
| Color scales    | Fixed                                                         | Fully customizable                                                          |
| Point styles    | Limited                                                       | Full pch support                                                            |
| Multi-sample    | Fixed layout                                                  | Flexible with patchwork                                                     |
| Adding layers   | Not possible                                                  | Via `+` or `&` operators                                                    |

### All Plot Types Comparison

#### XcmsExperiment Visualization (Full MS Data)

##### XCMS plot(XcmsExperiment)

``` r
# Base R version
plot(mse[1])
```

![XCMS base R plot showing full MS data: BPI and m/z
scatter.](xcmsexperiment-visualization_files/figure-html/supp_xcms_experiment-1.png)

Shows **raw MS data** (all m/z vs RT)

**Use when:** - Exploring raw MS data - Quality control of
acquisitions - Understanding full spectral information

##### xcmsVis gplot(XcmsExperiment)

``` r
# ggplot2 version
gplot(mse[1])
```

![ggplot2 version showing full MS data with modern
aesthetics.](xcmsexperiment-visualization_files/figure-html/supp_xcmsvis_experiment-1.png)

Shows **raw MS data** (all m/z vs RT)

**Additional capabilities:** - Interactive with plotly - Custom color
ramps - Theme customization

#### Chromatogram Visualization (EIC)

##### XCMS plot(XChromatogram)

``` r
# Base R chromatogram
chr <- chromatogram(xdata, mz = c(207, 208), rt = c(2600, 2800))
plot(chr[1, 1])
```

![XCMS base R chromatogram showing intensity vs retention
time.](xcmsexperiment-visualization_files/figure-html/supp_xcms_chromatogram-1.png)

Shows **extracted ion chromatogram (EIC)**

**Use when:** - Focusing on specific m/z - Peak integration - Comparing
specific compounds

##### xcmsVis gplot(XChromatogram)

``` r
# ggplot2 chromatogram
chr <- chromatogram(xdata, mz = c(207, 208), rt = c(2600, 2800))
gplot(chr[1, 1])
```

![ggplot2 chromatogram with enhanced styling and
customization.](xcmsexperiment-visualization_files/figure-html/supp_xcmsvis_chromatogram-1.png)

Shows **extracted ion chromatogram (EIC)**

**Additional capabilities:** - ggplot2 styling - Easy faceting for
multiple samples - Interactive tooltips

#### Multiple Samples

##### XCMS plot()

``` r
# Base R version - fixed layout
plot(mse)
```

![XCMS base R plot with multiple samples in fixed
layout.](xcmsexperiment-visualization_files/figure-html/supp_xcms_multi-1.png)

Fixed vertical stacking

##### xcmsVis gplot()

``` r
# ggplot2 version - flexible with patchwork
gplot(mse)
```

![ggplot2 version with multiple samples in flexible patchwork
layout.](xcmsexperiment-visualization_files/figure-html/supp_xcmsvis_multi-1.png)

Flexible layout with patchwork operators

### Key Advantages of xcmsVis

#### 1. Interactivity

``` r
# Convert to interactive plotly
p <- gplot(mse[1])
ggplotly(p)
```

The ggplot2 foundation allows seamless conversion to interactive plotly
plots with hover information, zoom, and pan capabilities.

#### 2. Composition

``` r
# Easy side-by-side comparison with patchwork
p1 <- gplot(mse[1]) + ggtitle("Sample 1")
p2 <- gplot(mse[2]) + ggtitle("Sample 2")
p1 | p2
```

![Side-by-side comparison using patchwork
composition.](xcmsexperiment-visualization_files/figure-html/supp_composition_demo-1.png)

Patchwork integration makes it trivial to create custom layouts and
comparisons.

#### 3. Theme Consistency

``` r
# Apply consistent theme across all plots
my_theme <- theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "bottom"
  )

gplot(mse[1]) & my_theme
```

![Multiple plots with consistent custom theme
applied.](xcmsexperiment-visualization_files/figure-html/supp_theme_demo-1.png)

Use the `&` operator to apply themes consistently across all panels in a
patchwork object.

### Migration Guide

For users transitioning from XCMS
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) to xcmsVis
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md):

#### Basic Replacement

``` r
# Old XCMS
plot(mse[1])

# New xcmsVis
gplot(mse[1])
```

#### With Color Customization

``` r
# Old XCMS
plot(mse[1], col = "blue", peakCol = "red")

# New xcmsVis (same syntax)
gplot(mse[1], col = "blue", peakCol = "red")
```

#### Saving Plots

``` r
# Old XCMS - must use graphics device
pdf("plot.pdf", width = 5, height = 6)
plot(mse[1])
dev.off()

# New xcmsVis - save ggplot object
p <- gplot(mse[1])
ggsave("plot.pdf", p, width = 5, height = 6)
```

#### Further Customization

``` r
# Old XCMS - limited customization
plot(mse[1], col = "blue")

# New xcmsVis - full ggplot2 ecosystem
gplot(mse[1], col = "blue") &
  theme_minimal() &
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold")
  )
```

### When to Use Each

**Use XCMS [`plot()`](https://rdrr.io/r/graphics/plot.default.html)**
when: - You need exact reproduction of legacy figures - Working with
base R graphics pipelines - No customization needed

**Use xcmsVis
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)**
when: - Creating publication figures with custom styling - Building
interactive visualizations - Composing complex multi-panel figures -
Integrating with modern R visualization workflows - Teaching or
presentations (plotly interactivity)

## Session Info

``` r
sessionInfo()
#> R version 4.5.2 (2025-10-31)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.3 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] viridisLite_0.4.2   patchwork_1.3.2     plotly_4.11.0      
#> [4] ggplot2_4.0.0       xcmsVis_0.99.14     xcms_4.8.0         
#> [7] BiocParallel_1.44.0
#> 
#> loaded via a namespace (and not attached):
#>   [1] DBI_1.2.3                   rlang_1.1.6                
#>   [3] magrittr_2.0.4              clue_0.3-66                
#>   [5] MassSpecWavelet_1.76.0      matrixStats_1.5.0          
#>   [7] compiler_4.5.2              vctrs_0.6.5                
#>   [9] reshape2_1.4.4              stringr_1.6.0              
#>  [11] ProtGenerics_1.42.0         pkgconfig_2.0.3            
#>  [13] MetaboCoreUtils_1.18.0      crayon_1.5.3               
#>  [15] fastmap_1.2.0               XVector_0.50.0             
#>  [17] labeling_0.4.3              rmarkdown_2.30             
#>  [19] preprocessCore_1.72.0       purrr_1.2.0                
#>  [21] xfun_0.54                   MultiAssayExperiment_1.36.0
#>  [23] jsonlite_2.0.0              progress_1.2.3             
#>  [25] DelayedArray_0.36.0         parallel_4.5.2             
#>  [27] prettyunits_1.2.0           cluster_2.1.8.1            
#>  [29] R6_2.6.1                    stringi_1.8.7              
#>  [31] RColorBrewer_1.1-3          limma_3.66.0               
#>  [33] GenomicRanges_1.62.0        Rcpp_1.1.0                 
#>  [35] Seqinfo_1.0.0               SummarizedExperiment_1.40.0
#>  [37] iterators_1.0.14            knitr_1.50                 
#>  [39] IRanges_2.44.0              BiocBaseUtils_1.12.0       
#>  [41] Matrix_1.7-4                igraph_2.2.1               
#>  [43] tidyselect_1.2.1            abind_1.4-8                
#>  [45] yaml_2.3.10                 doParallel_1.0.17          
#>  [47] codetools_0.2-20            affy_1.88.0                
#>  [49] lattice_0.22-7              tibble_3.3.0               
#>  [51] plyr_1.8.9                  Biobase_2.70.0             
#>  [53] withr_3.0.2                 S7_0.2.0                   
#>  [55] evaluate_1.0.5              Spectra_1.20.0             
#>  [57] pillar_1.11.1               affyio_1.80.0              
#>  [59] BiocManager_1.30.26         MatrixGenerics_1.22.0      
#>  [61] foreach_1.5.2               stats4_4.5.2               
#>  [63] MSnbase_2.36.0              MALDIquant_1.22.3          
#>  [65] ncdf4_1.24                  generics_0.1.4             
#>  [67] S4Vectors_0.48.0            hms_1.1.4                  
#>  [69] scales_1.4.0                MsExperiment_1.12.0        
#>  [71] glue_1.8.0                  MsFeatures_1.18.0          
#>  [73] lazyeval_0.2.2              tools_4.5.2                
#>  [75] mzID_1.48.0                 data.table_1.17.8          
#>  [77] QFeatures_1.20.0            vsn_3.78.0                 
#>  [79] mzR_2.44.0                  fs_1.6.6                   
#>  [81] XML_3.99-0.19               grid_4.5.2                 
#>  [83] impute_1.84.0               tidyr_1.3.1                
#>  [85] crosstalk_1.2.2             MsCoreUtils_1.21.0         
#>  [87] PSMatch_1.14.0              cli_3.6.5                  
#>  [89] S4Arrays_1.10.0             dplyr_1.1.4                
#>  [91] AnnotationFilter_1.34.0     pcaMethods_2.2.0           
#>  [93] gtable_0.3.6                digest_0.6.37              
#>  [95] BiocGenerics_0.56.0         SparseArray_1.10.1         
#>  [97] htmlwidgets_1.6.4           farver_2.1.2               
#>  [99] htmltools_0.5.8.1           lifecycle_1.0.4            
#> [101] httr_1.4.7                  statmod_1.5.1              
#> [103] MASS_7.3-65
```
