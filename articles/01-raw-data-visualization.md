# Step 1: Raw Data Visualization

## Introduction

This vignette covers the **first step** in the XCMS metabolomics
workflow: **visualizing raw MS data** before any processing. These
visualizations help you:

- Assess data quality before analysis
- Understand the structure of your LC-MS acquisition
- Identify potential issues early
- Visualize MS/MS (DDA) experiment coverage

### XCMS Workflow Context

    ┌───────────────────────────────┐
    │ 1. RAW DATA VISUALIZATION     | ← YOU ARE HERE
    ├────────────────────────────-──┤
    │ 2. Peak Detection             │
    │ 3. Peak Correspondence        │
    │ 4. Retention Time Alignment   │
    │ 5. Feature Grouping           │
    └──────────────────────────----─┘

### Functions Covered

- **`gplot(XcmsExperiment)`**: Visualize full MS acquisitions with BPI
  chromatogram and m/z scatter
- **[`gplotPrecursorIons()`](https://stanstrup.github.io/xcmsVis/reference/gplotPrecursorIons.md)**:
  Visualize MS/MS precursor ion selection in DDA experiments

## Setup

``` r
library(xcms)
library(xcmsVis)
library(MsExperiment)
library(ggplot2)
library(plotly)
library(patchwork)
library(msdata)
```

## Part 1: Full MS Data Visualization

### Overview

The [`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
method for XcmsExperiment and XCMSnExp objects creates a two-panel
visualization:

- **Upper panel**: Base Peak Intensity (BPI) chromatogram vs retention
  time
- **Lower panel**: m/z vs retention time scatter plot

Both panels use intensity-based coloring, and detected peaks (if any)
are automatically overlaid as rectangles.

### Data Preparation

We’ll use pre-processed test data from XCMS:

``` r
# Load pre-processed data
xdata <- loadXcmsData("faahko_sub2")

# Check data
cat("Samples:", length(xdata), "\n")
#> Samples: 3
cat("Total peaks detected:", nrow(chromPeaks(xdata)), "\n")
#> Total peaks detected: 248
```

For visualization, we’ll filter to a specific retention time and m/z
region:

``` r
# Filter to focused region
mse <- filterRt(xdata, rt = c(2785-100, 2785+100))
mse <- filterMzRange(mse, mz = c(278, 283))

library(glue)
rt_range <- range(rtime(spectra(mse[1])))
n_spectra <- length(spectra(mse[1]))
cat(glue("Filtered data:
  RT range: {rt_range[1]} - {rt_range[2]}
  Number of spectra in sample 1: {n_spectra}
"))
#> Filtered data:
#> RT range: 2686.043 - 2884.792
#> Number of spectra in sample 1: 128
```

### Basic Usage

#### Single Sample Visualization

``` r
gplot(mse[1])
```

![Two-panel plot showing BPI chromatogram (upper panel) and m/z vs
retention time scatter plot (lower panel) with intensity-based
coloring.](01-raw-data-visualization_files/figure-html/gplot_basic-1.png)

#### Understanding the Two Panels

##### Upper Panel: BPI Chromatogram

The **Base Peak Intensity (BPI)** shows the maximum intensity at each
retention time across all m/z values in the filtered range.

- Each point represents one retention time
- Y-axis shows the maximum intensity observed at that time
- Color indicates intensity magnitude
- Useful for identifying retention time regions with strong signals

##### Lower Panel: m/z vs RT Scatter

The **m/z vs retention time scatter** shows the complete mass spectral
data:

- X-axis: retention time
- Y-axis: m/z values
- Each point represents one data point from the raw spectra
- Color indicates intensity of that specific m/z at that retention time
- Shows the full two-dimensional structure of the LC-MS data

##### Peak Overlays

If chromatographic peaks have been detected (via
[`findChromPeaks()`](https://rdrr.io/pkg/xcms/man/findChromPeaks.html)),
they are automatically overlaid as rectangles showing:

- Peak retention time boundaries (left/right edges)
- Peak m/z boundaries (top/bottom edges)
- Semi-transparent red color by default

### Multiple Samples

When visualizing multiple samples,
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
creates a vertically stacked layout:

``` r
# Plot all three samples
gplot(mse)
```

![Three sets of two-panel plots stacked vertically, one for each sample,
showing BPI and m/z scatter
plots.](01-raw-data-visualization_files/figure-html/multiple_samples-1.png)

### Customization

#### Custom Colors

``` r
gplot(mse[1],
      col = "blue",           # Point border color
      peakCol = "red")        # Peak rectangle color
```

![Two-panel plot with blue point borders and red peak rectangles,
demonstrating color
customization.](01-raw-data-visualization_files/figure-html/custom_colors-1.png)

#### Custom Color Ramps

The intensity coloring uses a color ramp function. The viridis scales
are reversed to follow MS convention (low=dark, high=bright):

``` r
library(viridisLite)

# Create reversed versions for MS convention (low=dark, high=bright)
viridis_rev <- function(n) rev(viridis(n))
magma_rev <- function(n) rev(magma(n))
plasma_rev <- function(n) rev(plasma(n))

p1 <- gplot(mse[1], colramp = viridis_rev) + ggtitle("Viridis")
p2 <- gplot(mse[1], colramp = magma_rev) + ggtitle("Magma")
p3 <- gplot(mse[1], colramp = plasma_rev) + ggtitle("Plasma")

(p1 | p2 | p3)
```

![Three plots showing different color ramps: viridis, magma, and
plasma.](01-raw-data-visualization_files/figure-html/color_ramps-1.png)

#### Custom Titles

``` r
# Plot shows sample names from data automatically
gplot(mse)
```

![Three stacked two-panel plots showing multiple
samples.](01-raw-data-visualization_files/figure-html/custom_titles-1.png)

### Interactive Visualization

Convert to interactive plotly for data exploration:

``` r
p <- gplot(mse[1])
ggplotly(p)
```

**Accessing Individual Panels:**

Since
[`gplot()`](https://stanstrup.github.io/xcmsVis/reference/gplot.md)
returns a patchwork object combining two panels, you can access and make
each panel interactive separately:

``` r
# Upper panel (BPI chromatogram)
ggplotly(p[[1]])

# Lower panel (m/z vs RT scatter)
ggplotly(p[[2]])
```

This is useful when you want to customize each panel independently or
embed them separately in reports.

## Part 2: MS/MS Precursor Ion Visualization

### Overview

The
[`gplotPrecursorIons()`](https://stanstrup.github.io/xcmsVis/reference/gplotPrecursorIons.md)
function visualizes precursor ions selected for fragmentation in MS/MS
(tandem mass spectrometry) experiments. This is particularly useful for:

- Assessing DDA (Data-Dependent Acquisition) performance
- Visualizing MS/MS coverage across the chromatographic run
- Quality control of MS/MS experiments
- Understanding which compounds were fragmented

### What are Precursor Ions?

In MS/MS experiments, the mass spectrometer:

1.  Performs MS1 scans to detect all ions
2.  Selects specific ions (precursors) based on criteria (intensity,
    exclusion lists, etc.)
3.  Fragments these precursors and records MS2 spectra

The
[`gplotPrecursorIons()`](https://stanstrup.github.io/xcmsVis/reference/gplotPrecursorIons.md)
function plots where and which precursor ions were selected across the
LC-MS run.

### Loading DDA Data

We’ll use example DDA data from the msdata package:

``` r
# Load DDA MS/MS data
fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML",
                  package = "msdata")

pest_dda <- readMsExperiment(fl)

# Check data structure
pest_dda
#> Object of class MsExperiment 
#>  Spectra: MS1 (4627) MS2 (2975) 
#>  Experiment data: 1 sample(s)
#>  Sample data links:
#>   - spectra: 1 sample(s) to 7602 element(s).
```

### Basic Precursor Ion Visualization

#### Default Plot

``` r
p <- gplotPrecursorIons(pest_dda)
p
```

![](01-raw-data-visualization_files/figure-html/basic_precursor_plot-1.png)

The plot shows:

- **X-axis**: Retention time when MS2 spectrum was acquired
- **Y-axis**: m/z of the precursor ion selected for fragmentation
- **Points**: Each precursor ion

#### Interpretation

From this plot, you can see:

- **Distribution of MS/MS events** across the chromatographic run
- **m/z range** of fragmented ions
- **Density patterns** - where fragmentation was most active
- **Coverage gaps** - RT or m/z regions without MS/MS data

### Customization

#### Custom Colors and Symbols

``` r
p_custom <- gplotPrecursorIons(
  pest_dda,
  pch = 16,                    # filled circle
  col = "#E41A1C"              # point color
) +
  labs(
    x = "Retention Time (s)",
    y = "Precursor m/z"
  )

p_custom
```

![](01-raw-data-visualization_files/figure-html/custom_precursor_colors-1.png)

#### Adding ggplot2 Layers

``` r
gplotPrecursorIons(pest_dda) +
  ggtitle("DDA Precursor Ion Map") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.title = element_text(size = 12),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  )
```

![](01-raw-data-visualization_files/figure-html/ggplot_enhancements-1.png)

### Interactive Precursor Visualization

``` r
p_interactive <- gplotPrecursorIons(pest_dda)
ggplotly(p_interactive)
```

## Summary

### Functions Covered

| Function                                                                                      | Purpose                    | Input Type               |
|-----------------------------------------------------------------------------------------------|----------------------------|--------------------------|
| `gplot(XcmsExperiment)`                                                                       | Visualize full MS data     | XcmsExperiment, XCMSnExp |
| [`gplotPrecursorIons()`](https://stanstrup.github.io/xcmsVis/reference/gplotPrecursorIons.md) | Visualize MS/MS precursors | MsExperiment with MS2    |

### When to Use

- **Before any processing**: Assess raw data quality
- **Method development**: Evaluate acquisition parameters
- **Quality control**: Ensure expected coverage and signals
- **DDA experiments**: Verify MS/MS performance

### Next Steps

After visualizing and assessing your raw data, proceed to:

→ **[Step 2: Peak
Detection](https://stanstrup.github.io/xcmsVis/articles/02-peak-detection.md)** -
Detect chromatographic peaks in your data

## Comparison with Original XCMS

### gplot(XcmsExperiment) vs plot()

#### Original XCMS

``` r
plot(mse[1])
```

![XCMS base R plot showing two panels with traditional
graphics.](01-raw-data-visualization_files/figure-html/original_plot-1.png)

#### xcmsVis ggplot2

``` r
gplot(mse[1])
```

![ggplot2 version with modern aesthetics and customization
options.](01-raw-data-visualization_files/figure-html/xcmsvis_plot-1.png)

### gplotPrecursorIons() vs plotPrecursorIons()

#### Original XCMS

``` r
xcms::plotPrecursorIons(pest_dda)
```

![XCMS plotPrecursorIons using base R
graphics.](01-raw-data-visualization_files/figure-html/original_precursor-1.png)

#### xcmsVis ggplot2

``` r
gplotPrecursorIons(pest_dda)
```

![ggplot2 version with clean styling and consistent
API.](01-raw-data-visualization_files/figure-html/xcmsvis_precursor-1.png)

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
#>  [1] viridisLite_0.4.2   glue_1.8.0          msdata_0.50.0      
#>  [4] patchwork_1.3.2     plotly_4.11.0       ggplot2_4.0.0      
#>  [7] MsExperiment_1.12.0 ProtGenerics_1.42.0 xcmsVis_0.99.3     
#> [10] xcms_4.8.0          BiocParallel_1.44.0
#> 
#> loaded via a namespace (and not attached):
#>   [1] DBI_1.2.3                   rlang_1.1.6                
#>   [3] magrittr_2.0.4              clue_0.3-66                
#>   [5] MassSpecWavelet_1.76.0      matrixStats_1.5.0          
#>   [7] compiler_4.5.2              vctrs_0.6.5                
#>   [9] reshape2_1.4.5              stringr_1.6.0              
#>  [11] pkgconfig_2.0.3             MetaboCoreUtils_1.18.0     
#>  [13] crayon_1.5.3                fastmap_1.2.0              
#>  [15] XVector_0.50.0              labeling_0.4.3             
#>  [17] rmarkdown_2.30              preprocessCore_1.72.0      
#>  [19] purrr_1.2.0                 xfun_0.54                  
#>  [21] MultiAssayExperiment_1.36.0 jsonlite_2.0.0             
#>  [23] progress_1.2.3              DelayedArray_0.36.0        
#>  [25] parallel_4.5.2              prettyunits_1.2.0          
#>  [27] cluster_2.1.8.1             R6_2.6.1                   
#>  [29] stringi_1.8.7               RColorBrewer_1.1-3         
#>  [31] limma_3.66.0                GenomicRanges_1.62.0       
#>  [33] Rcpp_1.1.0                  Seqinfo_1.0.0              
#>  [35] SummarizedExperiment_1.40.0 iterators_1.0.14           
#>  [37] knitr_1.50                  IRanges_2.44.0             
#>  [39] BiocBaseUtils_1.12.0        Matrix_1.7-4               
#>  [41] igraph_2.2.1                tidyselect_1.2.1           
#>  [43] abind_1.4-8                 yaml_2.3.10                
#>  [45] doParallel_1.0.17           codetools_0.2-20           
#>  [47] affy_1.88.0                 lattice_0.22-7             
#>  [49] tibble_3.3.0                plyr_1.8.9                 
#>  [51] Biobase_2.70.0              withr_3.0.2                
#>  [53] S7_0.2.0                    evaluate_1.0.5             
#>  [55] Spectra_1.20.0              pillar_1.11.1              
#>  [57] affyio_1.80.0               BiocManager_1.30.26        
#>  [59] MatrixGenerics_1.22.0       foreach_1.5.2              
#>  [61] stats4_4.5.2                MSnbase_2.36.0             
#>  [63] MALDIquant_1.22.3           ncdf4_1.24                 
#>  [65] generics_0.1.4              S4Vectors_0.48.0           
#>  [67] hms_1.1.4                   scales_1.4.0               
#>  [69] MsFeatures_1.18.0           lazyeval_0.2.2             
#>  [71] tools_4.5.2                 mzID_1.48.0                
#>  [73] data.table_1.17.8           QFeatures_1.20.0           
#>  [75] vsn_3.78.0                  mzR_2.44.0                 
#>  [77] fs_1.6.6                    XML_3.99-0.20              
#>  [79] grid_4.5.2                  impute_1.84.0              
#>  [81] tidyr_1.3.1                 crosstalk_1.2.2            
#>  [83] MsCoreUtils_1.21.0          PSMatch_1.14.0             
#>  [85] cli_3.6.5                   S4Arrays_1.10.0            
#>  [87] dplyr_1.1.4                 AnnotationFilter_1.34.0    
#>  [89] pcaMethods_2.2.0            gtable_0.3.6               
#>  [91] digest_0.6.38               BiocGenerics_0.56.0        
#>  [93] SparseArray_1.10.1          htmlwidgets_1.6.4          
#>  [95] farver_2.1.2                htmltools_0.5.8.1          
#>  [97] lifecycle_1.0.4             httr_1.4.7                 
#>  [99] statmod_1.5.1               MASS_7.3-65
```
