# XCMS S4 Plot Methods - Detailed Reference

Complete documentation of all S4 `plot()` methods defined in XCMS (version 4.8.0+).

## Overview

XCMS defines **5 S4 plot methods** using `setMethod("plot", ...)` for different object types. Each method provides specialized visualization for that object class.

---

## 1. plot,XCMSnExp,missing-method

### Signature
```r
setMethod("plot", signature(x = "XCMSnExp", y = "missing"))
```

### Purpose
Plots spectrum data or extracted ion chromatograms (XIC) for an XCMSnExp object containing xcms preprocessing results.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | XCMSnExp | required | An XCMSnExp object with xcms results |
| `y` | missing | - | Not used (signature requirement) |
| `type` | character(1) | `"spectra"` | Either `"spectra"` or `"XIC"` |
| `peakCol` | character(1) | `"#ff000060"` | Color for highlighting identified chromatographic peaks |
| `...` | - | - | Additional parameters passed to underlying plot |

### Behavior

**If `type = "spectra"` OR no chromatographic peaks:**
- Calls parent method from MSnExp class
- Displays spectrum data

**If `type = "XIC"` AND chromatographic peaks present:**
- Calls internal `.plot_XIC()` function
- Visualizes chromatograms with peaks indicated as rectangles
- Peak rectangles span the detected RT and m/z range

### Example Usage
```r
library(xcms)
data(faahko_sub)

# Plot spectra
plot(faahko_sub, type = "spectra")

# Plot XICs with peaks highlighted
plot(faahko_sub, type = "XIC", peakCol = "#ff0000aa")
```

### Source Code
```r
function (x, y, ...) {
    .local <- function (x, y, type = c("spectra", "XIC"),
                        peakCol = "#ff000060", ...) {
        type <- match.arg(type)
        if (type == "spectra" || !hasChromPeaks(x))
            callNextMethod(x = x, type = type, ...)
        else .plot_XIC(x, peakCol = peakCol, ...)
    }
    .local(x, y = y, ...)
}
```

---

## 2. plot,XChromatogram,ANY-method

### Signature
```r
setMethod("plot", signature(x = "XChromatogram", y = "ANY"))
```

### Purpose
Plots a single chromatogram with optional visualization of identified chromatographic peaks.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | XChromatogram | required | Chromatogram with peak detection data |
| `y` | ANY | - | Ignored (signature flexibility) |
| `col` | character(1) | `"#00000060"` | Color for chromatogram line |
| `lty` | integer(1) | `1` | Line type for chromatogram |
| `type` | character(1) | `"l"` | Plot type ("l" = lines, "p" = points, etc.) |
| `xlab` | character(1) | `"retention time"` | X-axis label |
| `ylab` | character(1) | `"intensity"` | Y-axis label |
| `main` | character(1) | `NULL` | Plot title |
| `peakType` | character(1) | `"polygon"` | Peak display type (see below) |
| `peakCol` | character/vector | `"#00000060"` | Peak border/foreground color |
| `peakBg` | character/vector | `"#00000020"` | Peak fill/background color |
| `peakPch` | integer/vector | `1` | Point character (for `peakType = "point"`) |
| `...` | - | - | Additional plot parameters |

### Peak Display Types (`peakType`)

| Type | Visualization | Use Case |
|------|---------------|----------|
| `"polygon"` | Draw peak borders and fill the area | Default; shows full peak shape |
| `"point"` | Show only peak apex position | Minimal display for many peaks |
| `"rectangle"` | Draw rectangle around peak | Shows RT and intensity bounds |
| `"none"` | Don't display peaks | Just show chromatogram |

### Color Vectorization
- `peakCol`, `peakBg`, and `peakPch` can be vectors of length `nrow(chromPeaks(x))`
- Allows different colors for each peak (e.g., by sample, by quality score)

### Behavior
1. Calls parent method (Chromatogram class) to plot base chromatogram
2. If peaks present AND `peakType != "none"`:
   - Extracts peaks with `chromPeaks(x)`
   - Highlights each peak according to `peakType`
   - Supports vectorized colors for individual peak coloring

### Example Usage
```r
library(xcms)

# Create XChromatogram with peak detection
chr <- chromatogram(xdata, mz = c(200, 210))[1, 1]

# Plot with polygon peaks (default)
plot(chr)

# Plot with point peaks
plot(chr, peakType = "point", peakCol = "red", peakPch = 19)

# Plot with rectangles
plot(chr, peakType = "rectangle", peakCol = "blue")

# Color each peak differently
n_peaks <- nrow(chromPeaks(chr))
plot(chr, peakCol = rainbow(n_peaks))
```

### Source Code
```r
function (x, col = "#00000060", lty = 1, type = "l",
    xlab = "retention time", ylab = "intensity", main = NULL,
    peakType = c("polygon", "point", "rectangle", "none"),
    peakCol = "#00000060", peakBg = "#00000020", peakPch = 1, ...) {
    peakType <- match.arg(peakType)
    callNextMethod(x = x, col = col, lty = lty, type = type,
        xlab = xlab, ylab = ylab, main = main, ...)
    pks <- chromPeaks(x)
    nr <- nrow(pks)
    if (nr && peakType != "none") {
        if (length(peakCol) != nr)
            peakCol <- rep(peakCol[1], nr)
        if (length(peakBg) != nr)
            peakBg <- rep(peakBg[1], nr)
        if (length(peakPch) != nr)
            peakPch <- rep(peakPch[1], nr)
        suppressWarnings(.add_chromatogram_peaks(x, pks,
            col = peakCol, bg = peakBg, type = peakType,
            pch = peakPch, ...))
    }
}
```

---

## 3. plot,XChromatograms,ANY-method

### Signature
```r
setMethod("plot", signature(x = "XChromatograms", y = "ANY"))
```

### Purpose
Plots multiple chromatograms arranged in a grid layout (multiple samples/conditions), each with their identified peaks.

### Parameters
Same as `plot,XChromatogram,ANY-method` plus:

**Special behavior:**
- Automatically arranges multiple subplots using `par(mfrow)`
- Layout: `sqrt(n_rows)` by `ceiling(sqrt(n_rows))` grid
- Peak colors are maintained across subplots using global peak index

### Layout Logic

| # Rows | Grid Layout | Example |
|--------|-------------|---------|
| 1 | 1×1 | Single plot |
| 2-4 | 2×2 | Four panels |
| 5-9 | 3×3 | Nine panels |
| 10-16 | 4×4 | Sixteen panels |

### Behavior
1. Determines number of rows in XChromatograms object
2. If more than 1 row: sets up multi-panel plot
3. For each row:
   - Converts to MChromatograms or Chromatogram
   - Plots base chromatogram
   - Adds chromatographic peaks if present
4. Peak colors use global indexing across all subplots

### Example Usage
```r
library(xcms)

# Extract chromatograms for multiple m/z ranges
chrs <- chromatogram(xdata, mz = rbind(c(200, 210),
                                        c(300, 310),
                                        c(400, 410)))

# Plot all chromatograms in grid
plot(chrs)

# Customize appearance
plot(chrs, col = "blue", peakType = "rectangle", peakCol = "red")

# Color peaks by row/feature
all_peaks <- chromPeaks(chrs)
peak_colors <- rainbow(nrow(chrs))[all_peaks[, "row"]]
plot(chrs, peakCol = peak_colors)
```

### Source Code
```r
function (x, col = "#00000060", lty = 1, type = "l",
    xlab = "retention time", ylab = "intensity", main = NULL,
    peakType = c("polygon", "point", "rectangle", "none"),
    peakCol = "#00000060", peakBg = "#00000020", peakPch = 1, ...) {
    peakType <- match.arg(peakType)
    nr <- nrow(x)
    if (nr > 1)
        par(mfrow = c(round(sqrt(nr)), ceiling(sqrt(nr))))
    pks_all <- chromPeaks(x)
    pks_nr <- nrow(pks_all)
    if (length(peakCol) != pks_nr)
        peakCol <- rep(peakCol[1], pks_nr)
    if (length(peakBg) != pks_nr)
        peakBg <- rep(peakBg[1], pks_nr)
    if (length(peakPch) != pks_nr)
        peakPch <- rep(peakPch[1], pks_nr)
    for (i in seq_len(nr)) {
        x_sub <- x[i, , drop = FALSE]
        plot(as(x_sub, ifelse(is(x_sub, "XChromatograms"),
            "MChromatograms", "Chromatogram")), col = col,
            lty = lty, type = type, xlab = xlab, ylab = ylab,
            main = main, ...)
        idx <- which(pks_all[, "row"] == i)
        if (length(idx) && peakType != "none") {
            pks <- chromPeaks(x_sub)
            .add_chromatogram_peaks(x_sub, pks, col = peakCol[idx],
              bg = peakBg[idx], type = peakType, pch = peakPch[idx], ...)
        }
    }
}
```

---

## 4. plot,MsExperiment,missing-method

### Signature
```r
setMethod("plot", signature(x = "MsExperiment", y = "missing"))
```

### Purpose
Plots extracted ion chromatograms (XICs) from a modern MsExperiment object (next-generation xcms container).

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | MsExperiment | required | MsExperiment object with xcms results |
| `y` | missing | - | Not used |
| `msLevel` | integer(1) | `1L` | MS level to plot (MS1, MS2, etc.) |
| `peakCol` | character(1) | `"#ff000060"` | Color for highlighting peaks |
| `...` | - | - | Additional parameters to `.xmse_plot_xic()` |

### Important Notes
- **Only supports single MS level**: If multiple provided, uses first with warning
- Designed for modern xcms workflows using MsExperiment
- Automatically handles chromatographic peak visualization

### Behavior
1. Validates that only one MS level specified
2. Calls internal `.xmse_plot_xic()` function
3. Creates XIC plot for specified MS level
4. Highlights chromatographic peaks if present

### Example Usage
```r
library(xcms)
library(MsExperiment)

# Load data into MsExperiment
mse <- readMsExperiment(files)

# After peak detection and grouping
mse <- findChromPeaks(mse, param = CentWaveParam())

# Plot MS1 XICs
plot(mse, msLevel = 1)

# Plot with custom peak color
plot(mse, msLevel = 1, peakCol = "#ff0000aa")

# Attempting multiple MS levels triggers warning
plot(mse, msLevel = c(1, 2))  # Warning: uses only msLevel[1]
```

### Source Code
```r
function (x, y, msLevel = 1L, peakCol = "#ff000060", ...) {
    if (length(msLevel) > 1)
        warning("'plot' does support only a single MS level. ",
            "Will use msLevel[1].")
    msLevel <- msLevel[1L]
    .xmse_plot_xic(x, msLevel = msLevel, peakCol = peakCol, ...)
}
```

---

## 5. plot,LamaParama,ANY-method

### Signature
```r
setMethod("plot", signature(x = "LamaParama", y = "ANY"))
```

### Purpose
Diagnostic plot for Lama (Landmark-based alignment) retention time correction. Shows relationship between matched peaks and reference landmarks plus fitted alignment model.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | LamaParama | required | Landmark-based alignment parameter object |
| `y` | ANY | - | Ignored |
| `index` | integer(1) | `1L` | Which file/sample to plot |
| `colPoints` | character(1) | `"#00000060"` | Color for data points (matched peaks) |
| `colFit` | character(1) | `"#00000080"` | Color for fitted alignment curve |
| `xlab` | character(1) | `"Matched Chromatographic peaks"` | X-axis label |
| `ylab` | character(1) | `"Lamas"` | Y-axis label |
| `...` | - | - | Additional plot parameters |

### What is Lama?
**Lama** = **La**ndmark **ma**tching alignment method
- Uses "landmark" peaks (high-quality, abundant peaks present across samples)
- Matches sample peaks to reference landmarks
- Fits smooth curve (loess or gam) to correct retention times

### Behavior
1. Extracts RT mapping for specified file index
2. Retrieves fitted model (loess or GAM) from LamaParama
3. Plots matched peaks vs landmarks as points
4. Overlays fitted alignment curve
5. Useful for QC before/after `adjustRtime()`

### Interpreting the Plot
- **X-axis**: Retention times of matched chromatographic peaks in sample
- **Y-axis**: Retention times of corresponding landmarks (reference)
- **Points**: Individual peak matches
- **Curve**: Smooth fitted alignment model
- **Good alignment**: Points cluster tightly around curve
- **Poor alignment**: Large scatter, outliers far from curve

### Example Usage
```r
library(xcms)

# Perform landmark-based alignment
param <- LamaParama(span = 0.5, outlierTolerance = 3)
xdata_aligned <- adjustRtime(xdata, param = param)

# Diagnostic plot for first sample
plot(param, index = 1)

# Customize colors
plot(param, index = 2,
     colPoints = "steelblue",
     colFit = "darkred",
     main = "Sample 2 Alignment")

# Check all samples
for (i in seq_len(length(fileNames(xdata)))) {
    plot(param, index = i, main = paste("Sample", i))
}
```

### Source Code
```r
function (x, index = 1L, colPoints = "#00000060",
    colFit = "#00000080", xlab = "Matched Chromatographic peaks",
    ylab = "Lamas", ...) {
    model <- .rt_model(method = x@method, rt_map = x@rtMap[[index]],
        span = x@span, resid_ratio = x@outlierTolerance,
        zero_weight = x@zeroWeight, bs = x@bs)
    datap <- x@rtMap[[index]]
    plot(datap[, 2L], datap[, 1L], type = "p", xlab = xlab,
        ylab = ylab, col = colPoints, ...)
    points(model, type = "l", col = colFit)
}
```

---

## Summary Table

| Method Signature | Object Type | Primary Use Case | Peak Display |
|-----------------|-------------|------------------|--------------|
| `plot,XCMSnExp,missing` | XCMSnExp | Spectra or XIC visualization | Rectangle highlights |
| `plot,XChromatogram,ANY` | Single chromatogram | EIC with peak annotation | Polygon/point/rectangle/none |
| `plot,XChromatograms,ANY` | Multiple chromatograms | Multi-panel EIC grid | Polygon/point/rectangle/none |
| `plot,MsExperiment,missing` | MsExperiment | Modern XIC visualization | Rectangle highlights |
| `plot,LamaParama,ANY` | Alignment params | RT alignment diagnostics | N/A (shows fit curve) |

---

## Implementation Priority for xcmsVis

### High Priority ⭐⭐⭐
1. ✅ **plot,XChromatogram,ANY** - **DONE** (`gplot()`)
   - Implemented as `gplot()` method for XChromatogram
   - ggplot2 equivalent with plotly support
   - Multiple `peakType` options: polygon, point, rectangle, none
   - Default: polygon (matches original XCMS)

2. **plot,XChromatograms,ANY** - Multi-panel chromatogram grid
   - Create: `gplot.XChromatograms()` or `gplotChromatograms()`
   - Use faceting instead of `par(mfrow)`
   - Maintain color consistency across panels

### Medium Priority ⭐⭐
3. **plot,XCMSnExp,missing** - General XIC plotting
   - Already partially covered by chromatogram methods
   - May be redundant with other implementations

4. **plot,MsExperiment,missing** - Modern object support
   - Important for future compatibility
   - Similar to XCMSnExp method

### Lower Priority ⭐
5. **plot,LamaParama,ANY** - Diagnostic only
   - Specialized use case
   - Standard plot may be sufficient

---

## Design Recommendations for xcmsVis

### 1. Chromatogram Plotting
```r
gplotChromatogram <- function(object,
                              color_by = NULL,
                              peakType = c("polygon", "point", "rectangle", "none"),
                              peakColor = NULL,
                              peakFill = NULL,
                              include_columns = NULL,
                              ...) {
    # ggplot2 implementation
    # Use geom_area() for polygon peaks
    # Use geom_point() for point peaks
    # Use geom_rect() for rectangle peaks
    # Add hover tooltips with peak info
}
```

### 2. Multi-Chromatogram Grid
```r
gplotChromatograms <- function(object,
                               color_by = NULL,
                               facet_by = "row",  # or custom
                               peakType = c("polygon", "point", "rectangle", "none"),
                               ncol = NULL,       # auto-calculate if NULL
                               ...) {
    # Use facet_wrap() or facet_grid()
    # Maintain consistent scales option
    # Support free scales if needed
}
```

### 3. Interactive Features
- **Hover tooltips** should show:
  - RT, intensity at cursor position
  - For peaks: RT range, m/z, intensity, peak area, sample info
- **Click interactions**: Identify peaks
- **Zoom/pan**: Built-in with plotly
- **Legend**: Toggle sample visibility

---

## References

- XCMS documentation: https://bioconductor.org/packages/xcms
- MsExperiment: https://bioconductor.org/packages/MsExperiment
- Chromatogram classes: Part of MSnbase/Spectra infrastructure
