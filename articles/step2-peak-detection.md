# Step 2: Peak Detection Visualization

## Introduction

This vignette covers the **second step** in the XCMS metabolomics
workflow: **visualizing detected chromatographic peaks**. After running
[`findChromPeaks()`](https://rdrr.io/pkg/xcms/man/findChromPeaks.html),
these functions help you:

- Assess peak detection quality
- Visualize peak distribution across samples
- Examine individual peak shapes
- Annotate chromatograms with detected peaks

### XCMS Workflow Context

    ┌───────────────────────────────┐
    │ 1. Raw Data Visualization     │
    ├───────────────────────────────┤
    │ 2. PEAK DETECTION             │ ← YOU ARE HERE
    ├───────────────────────────────┤
    │ 3. Peak Correspondence        │
    │ 4. Retention Time Alignment   │
    │ 5. Feature Grouping           │
    └───────────────────────────────┘

### Functions Covered

| Function                                                                                          | Purpose                    | Input            |
|---------------------------------------------------------------------------------------------------|----------------------------|------------------|
| [`gplotChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeaks.md)           | Show peaks in RT/m/z space | XcmsExperiment   |
| [`gplotChromPeakImage()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeakImage.md)   | Peak density heatmap       | XcmsExperiment   |
| `gplot(XChromatogram)`                                                                            | Chromatogram with peaks    | XChromatogram    |
| [`ghighlightChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/ghighlightChromPeaks.md) | Add peak annotations       | Layer for ggplot |

## Setup

``` r
library(xcms)
library(ggplot2)
library(plotly)
library(faahKO)
library(MsExperiment)
library(BiocParallel)
library(patchwork)
library(xcmsVis)
```

## Data Preparation

We’ll use pre-processed example data with peaks already detected:

``` r
# Load pre-processed data with detected peaks
# This dataset contains 248 detected peaks from 3 samples
xdata <- loadXcmsData("faahko_sub2")

# Add sample metadata for visualization
sampleData(xdata)$sample_name <- c("KO01", "KO02", "WT01")
sampleData(xdata)$sample_group <- c("KO", "KO", "WT")

# Check number of peaks detected
cat("Total peaks detected:", nrow(chromPeaks(xdata)), "\n")
#> Total peaks detected: 248
```

## Part 1: Peak Distribution Visualization

### gplotChromPeaks(): Peak Rectangles in RT/m/z Space

The
[`gplotChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeaks.md)
function creates a scatter plot showing detected peaks as rectangles in
retention time vs m/z space.

#### Basic Usage

``` r
gplotChromPeaks(xdata, file = 1)
```

![ggplot2 version showing detected peaks as semi-transparent rectangles
in RT vs m/z
space.](step2-peak-detection_files/figure-html/gplot_chrompeaks-1.png)

#### Focusing on a Region

``` r
# Focus on a specific RT and m/z region
gplotChromPeaks(
                xdata,
                file = 1,
                xlim = c(2600, 2750),
                ylim = c(325,460)
              )
```

![Zoomed view of chromatographic peaks in a specific
region.](step2-peak-detection_files/figure-html/zoom_chrompeaks-1.png)

#### Customizing the Plot

``` r
gplotChromPeaks(xdata, file = 1, 
                xlim = c(2600, 2750),
                ylim = c(325,460),
                border = "darkblue",
                fill = "lightblue"
                ) +
  labs(
    title = "Detected Peaks - Sample 1",
    x = "Retention Time (s)",
    y = "m/z"
  ) +
  theme_minimal()
```

![Customized chromatographic peaks plot with custom
styling.](step2-peak-detection_files/figure-html/custom_chrompeaks-1.png)

#### Comparing Multiple Samples

``` r
p_s1 <- gplotChromPeaks(xdata, file = 1) + labs(title = "Sample 1 (KO)")
p_s2 <- gplotChromPeaks(xdata, file = 2) + labs(title = "Sample 2 (KO)")
p_s3 <- gplotChromPeaks(xdata, file = 3) + labs(title = "Sample 3 (WT)")

p_s1 + p_s2 + p_s3
```

![Side-by-side comparison of peak distributions across three
samples.](step2-peak-detection_files/figure-html/compare_samples-1.png)

### gplotChromPeakImage(): Peak Density Heatmap

The
[`gplotChromPeakImage()`](https://stanstrup.github.io/xcmsVis/reference/gplotChromPeakImage.md)
function creates a heatmap showing the number of detected peaks per
sample across retention time bins.

#### Basic Usage

``` r
gplotChromPeakImage(xdata, binSize = 30)
```

![ggplot2 heatmap of peak density using viridis color
scale.](step2-peak-detection_files/figure-html/gplot_peakimage-1.png)

#### With Different Bin Sizes

``` r
p_b15 <- gplotChromPeakImage(xdata, binSize = 15) +
  labs(title = "Bin Size: 15s")
p_b30 <- gplotChromPeakImage(xdata, binSize = 30) +
  labs(title = "Bin Size: 30s")
p_b60 <- gplotChromPeakImage(xdata, binSize = 60) +
  labs(title = "Bin Size: 60s")

p_b15 + p_b30 + p_b60
```

![Comparison of peak density heatmaps using different bin
sizes.](step2-peak-detection_files/figure-html/different_bins-1.png)

#### Log-Transformed View

``` r
p_linear <- gplotChromPeakImage(xdata, log_transform = FALSE) +
  labs(title = "Linear Scale")
p_log <- gplotChromPeakImage(xdata, log_transform = TRUE) +
  labs(title = "Log2 Scale")

p_linear + p_log
```

![Comparison of linear and log2-transformed peak density
heatmaps.](step2-peak-detection_files/figure-html/log_transform-1.png)

#### Interactive Version

``` r
p3 <- gplotChromPeakImage(xdata, binSize = 30)
ggplotly(p3)
```

## Part 2: Chromatogram Visualization

### gplot(XChromatogram): Automatic Peak Plotting

First, let’s extract a chromatogram for a specific m/z range:

``` r
# Extract chromatogram for m/z 200-210
mz_range <- c(343-0.2,343+0.2)
rt_range <- c(2600, 2750)

# Get chromatogram data
chr <- chromatogram(xdata, mz = mz_range, rt = rt_range)
```

``` r
gplot(chr[1, 1]) +
  labs(title = "Chromatogram with Detected Peaks")
```

![ggplot2 version of chromatogram plot with detected peaks automatically
marked.](step2-peak-detection_files/figure-html/gplot_chromatogram-1.png)

#### Multiple Peak Types

``` r
p1 <- gplot(chr[1, 1], peakType = "polygon") + ggtitle("Polygon")
p2 <- gplot(chr[1, 1], peakType = "point") + ggtitle("Point")
p3 <- gplot(chr[1, 1], peakType = "rectangle") + ggtitle("Rectangle")
p4 <- gplot(chr[1, 1], peakType = "none") + ggtitle("None")

(p1 | p2) / (p3 | p4)
```

![Four panel plot showing different peak annotation
styles.](step2-peak-detection_files/figure-html/peak_types-1.png)

#### Interactive Chromatogram

``` r
ggplotly(gplot(chr[1, 1]))
```

## Part 3: Composable Peak Highlighting

### ghighlightChromPeaks(): Adding Peak Layers

For more control,
[`ghighlightChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/ghighlightChromPeaks.md)
returns ggplot2 layers that can be added to any chromatogram plot:

``` r
# Start with gplot() which creates the chromatogram
p_chrom <- gplot(chr[1, 1], peakType = "none") +
  labs(
    title = "Chromatogram with Highlighted Peaks (Rectangle)",
    x = "Retention Time (s)",
    y = "Intensity"
  )

# Add peak highlights as rectangles
peak_layers <- ghighlightChromPeaks(
  xdata,
  rt = rt_range,
  mz = mz_range,
  type = "rect",
  border = "red",
  fill = alpha("red", 0.2)
)

# Combine base plot with peak annotations
p_chrom + peak_layers
```

![Chromatogram with detected peaks highlighted as semi-transparent
rectangles.](step2-peak-detection_files/figure-html/highlight_rect-1.png)

### Understanding Peak Highlighting Behavior

The
[`ghighlightChromPeaks()`](https://stanstrup.github.io/xcmsVis/reference/ghighlightChromPeaks.md)
function searches **all peaks across all samples**. For cleaner
visualization, filter to a single sample:

``` r
# Without filtering: shows peaks from ALL samples
p_all <- gplot(chr[1, 1], peakType = "none") +
  ghighlightChromPeaks(xdata,
                       rt = rt_range,
                       mz = mz_range,
                       type = "rect",
                       border = "red",
                       fill = alpha("red", 0.2)) +
  labs(title = "All Samples (may show extra peaks)",
       x = "RT (s)", y = "Intensity")

# With filtering: shows only peaks from sample 1
xdata_filtered <- filterFile(xdata, 1)
p_filtered <- gplot(chr[1, 1], peakType = "none") +
  ghighlightChromPeaks(xdata_filtered,
                       rt = rt_range,
                       mz = mz_range,
                       type = "rect",
                       border = "blue",
                       fill = alpha("blue", 0.2)) +
  labs(title = "Single Sample (sample 1 only)",
       x = "RT (s)", y = "Intensity")

p_all + p_filtered
```

![Comparison showing peak highlighting with and without sample
filtering.](step2-peak-detection_files/figure-html/highlight_filtered-1.png)

### Different Visualization Types

``` r
xdata_filtered <- filterFile(xdata, 1)

# Type: Rectangle
p_rect <- gplot(chr[1, 1], peakType = "none") +
  labs(title = "Peak Annotations: Rectangles", x = "RT (s)", y = "Intensity")
peak_rects <- ghighlightChromPeaks(
  xdata_filtered,
  rt = rt_range,
  mz = mz_range,
  type = "rect",
  border = "red",
  fill = alpha("red", 0.2)
)

# Type: Point
p_point <- gplot(chr[1, 1], peakType = "none") +
  labs(title = "Peak Annotations: Points", x = "RT (s)", y = "Intensity")
peak_points <- ghighlightChromPeaks(
  xdata_filtered,
  rt = rt_range,
  mz = mz_range,
  type = "point",
  border = "red"
)

# Type: Polygon
p_poly <- gplot(chr[1, 1], peakType = "none") +
  labs(title = "Peak Annotations: Polygons", x = "RT (s)", y = "Intensity")
peak_polygons <- ghighlightChromPeaks(
  xdata_filtered,
  rt = rt_range,
  mz = mz_range,
  type = "polygon",
  border = "blue",
  fill = alpha("blue", 0.3)
)

# Display all three types
(p_rect + peak_rects) /
(p_point + peak_points) /
(p_poly + peak_polygons)
```

![Three-panel comparison showing different peak annotation
styles.](step2-peak-detection_files/figure-html/highlight_types-1.png)

### Peak Selection Criteria

``` r
# whichPeaks: "any" - peaks that overlap the range
p_any <- gplot(chr[1, 1], peakType = "none") +
  labs(title = "whichPeaks = 'any'", x = "RT (s)", y = "Intensity")

peaks_any <- ghighlightChromPeaks(
  xdata_filtered, rt = rt_range, mz = mz_range,
  whichPeaks = "any", border = "red", fill = alpha("red", 0.2)
)

# whichPeaks: "within" - peaks fully within the range
p_within <- gplot(chr[1, 1], peakType = "none") +
  labs(title = "whichPeaks = 'within'", x = "RT (s)", y = "Intensity")

peaks_within <- ghighlightChromPeaks(
  xdata_filtered, rt = rt_range, mz = mz_range,
  whichPeaks = "within", border = "blue", fill = alpha("blue", 0.2)
)

# whichPeaks: "apex_within" - peaks with apex in range
p_apex <- gplot(chr[1, 1], peakType = "none") +
  labs(title = "whichPeaks = 'apex_within'", x = "RT (s)", y = "Intensity")

peaks_apex <- ghighlightChromPeaks(
  xdata_filtered, rt = rt_range, mz = mz_range,
  whichPeaks = "apex_within", border = "green", fill = alpha("green", 0.2)
)

# Display comparison
(p_any + peaks_any) / (p_within + peaks_within) / (p_apex + peaks_apex)
```

![Comparison of three peak selection
methods.](step2-peak-detection_files/figure-html/peak_selection-1.png)

## Combining Visualizations

Create comprehensive peak detection summaries:

``` r
# Peak distribution for one sample
p_dist <- gplotChromPeaks(xdata, file = 1) +
  labs(title = "Peak Distribution - Sample 1")

# Peak density across all samples
p_density <- gplotChromPeakImage(xdata, binSize = 30) +
  labs(title = "Peak Density Across Samples")

# Combine
p_dist / p_density
```

![Combined peak detection
summary.](step2-peak-detection_files/figure-html/combined_view-1.png)

## Summary

### Use Cases

- **Quality control**: Verify peak detection quality
- **Method development**: Optimize CentWave parameters
- **Sample comparison**: Compare peak detection across samples
- **Peak inspection**: Examine individual peak shapes

### Next Steps

After visualizing detected peaks, proceed to:

→ **[Step 3: Peak
Correspondence](https://stanstrup.github.io/xcmsVis/articles/step3-peak-correspondence.md)** -
Group peaks across samples

## Comparison with Original XCMS

### Original XCMS

``` r
plotChromPeaks(xdata, file = 1, xlim = c(2600, 2750), ylim = c(325,460))
```

![XCMS plotChromPeaks using base R
graphics.](step2-peak-detection_files/figure-html/original_chrompeaks-1.png)

### xcmsVis ggplot2

``` r
gplotChromPeaks(xdata, file = 1, xlim = c(2600, 2750), ylim = c(325,460))
```

![ggplot2 version with modern
aesthetics.](step2-peak-detection_files/figure-html/ggplot_chrompeaks_supp-1.png)

### gplotChromPeakImage() vs plotChromPeakImage()

#### Original XCMS

``` r
plotChromPeakImage(xdata, binSize = 30)
```

![XCMS plotChromPeakImage using base R
graphics.](step2-peak-detection_files/figure-html/original_peakimage-1.png)

#### xcmsVis ggplot2

``` r
gplotChromPeakImage(xdata, binSize = 30)
```

![ggplot2 version with viridis color
scale.](step2-peak-detection_files/figure-html/xcmsvis_peakimage-1.png)

### gplot(XChromatogram) vs plot(Chromatogram)

#### Original XCMS

``` r
plot(chr[1, 1])
```

![XCMS plot for Chromatogram using base R
graphics.](step2-peak-detection_files/figure-html/original_chromatogram-1.png)

#### xcmsVis ggplot2

``` r
gplot(chr[1, 1])
```

![ggplot2 version with detected
peaks.](step2-peak-detection_files/figure-html/xcmsvis_chromatogram-1.png)

### ghighlightChromPeaks() vs highlightChromPeaks()

#### Original XCMS

``` r
xdata_filtered <- filterFile(xdata, 1)
# Convert to XCMSnExp for original XCMS function
xdata_xcmsnexp <- as(xdata_filtered, "XCMSnExp")
plot(chr[1, 1])
highlightChromPeaks(xdata_xcmsnexp, rt = rt_range, mz = mz_range,
                    type = "rect", border = "red")
```

![XCMS highlightChromPeaks using base R
graphics.](step2-peak-detection_files/figure-html/original_highlight-1.png)

#### xcmsVis ggplot2

``` r
gplot(chr[1, 1]) +
  ghighlightChromPeaks(xdata_filtered, rt = rt_range, mz = mz_range,
                       type = "rect", border = "red", fill = NA)
```

![ggplot2 version as composable
layers.](step2-peak-detection_files/figure-html/xcmsvis_highlight-1.png)

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
#> [1] xcmsVis_0.99.9      patchwork_1.3.2     MsExperiment_1.12.0
#> [4] ProtGenerics_1.42.0 faahKO_1.50.0       plotly_4.12.0      
#> [7] ggplot2_4.0.2       xcms_4.8.0          BiocParallel_1.44.0
#> 
#> loaded via a namespace (and not attached):
#>   [1] DBI_1.3.0                   rlang_1.1.7                
#>   [3] magrittr_2.0.4              clue_0.3-67                
#>   [5] MassSpecWavelet_1.76.0      otel_0.2.0                 
#>   [7] matrixStats_1.5.0           compiler_4.5.2             
#>   [9] vctrs_0.7.1                 reshape2_1.4.5             
#>  [11] stringr_1.6.0               pkgconfig_2.0.3            
#>  [13] MetaboCoreUtils_1.18.1      crayon_1.5.3               
#>  [15] fastmap_1.2.0               XVector_0.50.0             
#>  [17] labeling_0.4.3              rmarkdown_2.30             
#>  [19] preprocessCore_1.72.0       purrr_1.2.1                
#>  [21] xfun_0.56                   MultiAssayExperiment_1.36.1
#>  [23] jsonlite_2.0.0              progress_1.2.3             
#>  [25] DelayedArray_0.36.0         parallel_4.5.2             
#>  [27] prettyunits_1.2.0           cluster_2.1.8.1            
#>  [29] R6_2.6.1                    stringi_1.8.7              
#>  [31] RColorBrewer_1.1-3          limma_3.66.0               
#>  [33] GenomicRanges_1.62.1        Rcpp_1.1.1                 
#>  [35] Seqinfo_1.0.0               SummarizedExperiment_1.40.0
#>  [37] iterators_1.0.14            knitr_1.51                 
#>  [39] IRanges_2.44.0              BiocBaseUtils_1.12.0       
#>  [41] Matrix_1.7-4                igraph_2.2.2               
#>  [43] tidyselect_1.2.1            abind_1.4-8                
#>  [45] yaml_2.3.12                 doParallel_1.0.17          
#>  [47] codetools_0.2-20            affy_1.88.0                
#>  [49] lattice_0.22-7              tibble_3.3.1               
#>  [51] plyr_1.8.9                  Biobase_2.70.0             
#>  [53] withr_3.0.2                 S7_0.2.1                   
#>  [55] evaluate_1.0.5              Spectra_1.20.1             
#>  [57] pillar_1.11.1               affyio_1.80.0              
#>  [59] BiocManager_1.30.27         MatrixGenerics_1.22.0      
#>  [61] foreach_1.5.2               stats4_4.5.2               
#>  [63] MSnbase_2.36.0              MALDIquant_1.22.3          
#>  [65] ncdf4_1.24                  generics_0.1.4             
#>  [67] S4Vectors_0.48.0            hms_1.1.4                  
#>  [69] scales_1.4.0                glue_1.8.0                 
#>  [71] MsFeatures_1.18.0           lazyeval_0.2.2             
#>  [73] tools_4.5.2                 mzID_1.48.0                
#>  [75] data.table_1.18.2.1         QFeatures_1.20.0           
#>  [77] vsn_3.78.1                  mzR_2.44.0                 
#>  [79] fs_1.6.7                    XML_3.99-0.22              
#>  [81] grid_4.5.2                  impute_1.84.0              
#>  [83] tidyr_1.3.2                 crosstalk_1.2.2            
#>  [85] MsCoreUtils_1.22.1          PSMatch_1.14.0             
#>  [87] cli_3.6.5                   viridisLite_0.4.3          
#>  [89] S4Arrays_1.10.1             dplyr_1.2.0                
#>  [91] AnnotationFilter_1.34.0     pcaMethods_2.2.0           
#>  [93] gtable_0.3.6                digest_0.6.39              
#>  [95] BiocGenerics_0.56.0         SparseArray_1.10.9         
#>  [97] htmlwidgets_1.6.4           farver_2.1.2               
#>  [99] htmltools_0.5.9             lifecycle_1.0.5            
#> [101] httr_1.4.8                  statmod_1.5.1              
#> [103] MASS_7.3-65
```
