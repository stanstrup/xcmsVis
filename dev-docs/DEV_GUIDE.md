# xcmsVis Development Guide

Complete reference for developing ggplot2 visualizations for XCMS data.

**Last Updated**: 2025-11-06

---

## Table of Contents

1. [XCMS Functions Reference](#xcms-functions-reference)
2. [S4 Implementation Guide](#s4-implementation-guide)
3. [Common Patterns](#common-patterns)
4. [Testing](#testing)
5. [Quick Reference Tables](#quick-reference-tables)

---

## XCMS Functions Reference

### Modern XCMS Plotting Functions

Functions that work with modern XCMS objects (XCMSnExp, XcmsExperiment):

| XCMS Function | Purpose | Input | xcmsVis Status | Files |
|---------------|---------|-------|----------------|-------|
| `plotAdjustedRtime` | RT alignment visualization | XCMSnExp, XcmsExperiment | ✅ `gplotAdjustedRtime` | R/gplotAdjustedRtime-methods.R |
| `plotChromPeaks` | Detected peaks in RT-m/z space | XCMSnExp, XcmsExperiment | ✅ `gplotChromPeaks` | R/gplotChromPeaks-methods.R |
| `plotChromPeakImage` | Peak density heatmap | XCMSnExp, XcmsExperiment | ✅ `gplotChromPeakImage` | R/gplotChromPeakImage-methods.R |
| `plot` (S4) | Chromatogram with peaks | XChromatogram | ✅ `gplot` | R/gplot-methods.R |
| `highlightChromPeaks` | Peak annotation layers | XCMSnExp | ✅ `ghighlightChromPeaks` | R/ghighlightChromPeaks-methods.R |
| `plotChromPeakDensity` | Peak density for parameter tuning | XCMSnExp | ⚠️ Use discouraged on XCMSnExp | - |
| `plotFeatureGroups` | Feature relationships | XCMSnExp, XcmsExperiment | ❌ Not implemented | - |
| `plotChromatogramsOverlay` | Overlay multiple EICs | MChromatograms | ❌ Different object type | - |
| `plotPrecursorIons` | MS/MS precursors | MsExperiment | ❌ MS/MS specific | - |

### Legacy Functions (Not Implemented)

15 functions for xcmsRaw/xcmsSet objects: plotQC, plotrt, plotTIC, plotRaw, plotEIC, plotChrom, plotScan, plotSpec, plotPeaks, plotSurf, image, levelplot, plot.xcmsEIC, plotTree, plotMsData

---

## S4 Implementation Guide

### 6-Step Implementation Process

```
1. Declare generic in R/AllGenerics.R with full roxygen2 docs
2. Implement methods in R/gplot*-methods.R (one per object type)
3. Run devtools::document() to update NAMESPACE and man/
4. Write tests in tests/testthat/test-*.R
5. Add examples to vignettes
6. Verify with methods("functionName") and devtools::check()
```

### S4 Syntax

#### 1. Declare Generic (in R/AllGenerics.R)

```r
#' @title Function Title
#' @description Brief description
#' @param object An `XCMSnExp` or `XcmsExperiment` object
#' @param color_by Optional column name for coloring (NSE supported)
#' @param ... Additional parameters
#' @return A ggplot object
#' @details
#' Detailed explanation of how the function works.
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#'
#' # Load and process data
#' cdf_files <- system.file("cdf/KO/ko15.CDF", package = "faahKO")
#' xdata <- readMsExperiment(spectraFiles = cdf_files)
#' xdata <- findChromPeaks(xdata, param = CentWaveParam())
#'
#' # Create plot
#' gplotFunction(xdata)
#' }
#' @seealso \code{\link[xcms]{originalFunction}}
#' @export
setGeneric("functionName", function(object, ...)
    standardGeneric("functionName"))
```

#### 2. Implement Methods (in R/gplot*-methods.R)

```r
#' @rdname functionName
setMethod("functionName", "XCMSnExp",
    function(object, color_by = NULL, param1, param2 = default, ...) {
        # 1. Validate
        if (!hasChromPeaks(object))
            stop("No chromatographic peaks found")

        # 2. Extract data
        peaks <- chromPeaks(object)
        sample_data <- as.data.frame(sampleData(object))

        # 3. Process and create data.frame
        plot_data <- data.frame(
            x = peaks[, "rt"],
            y = peaks[, "mz"],
            sample = peaks[, "sample"]
        )
        plot_data <- merge(plot_data, sample_data, by = "sample")

        # 4. Handle NSE for color_by
        color_col <- rlang::enquo(color_by)
        if (!rlang::quo_is_null(color_col)) {
            color_name <- rlang::as_name(color_col)
            if (!color_name %in% colnames(plot_data))
                stop("Column '", color_name, "' not found")
        }

        # 5. Create ggplot
        p <- ggplot(plot_data, aes(x = x, y = y))

        if (!rlang::quo_is_null(color_col)) {
            p <- p + aes(color = !!color_col)
        }

        p <- p +
            geom_point() +
            labs(x = "Retention Time", y = "m/z") +
            theme_bw()

        return(p)
    })

#' @rdname functionName
setMethod("functionName", "XcmsExperiment",
    function(object, color_by = NULL, param1, param2 = default, ...) {
        # Same implementation but handle DataFrame from sampleData()
        sample_data <- as.data.frame(sampleData(object))
        # ... rest is same
    })
```

---

## Common Patterns

### Pattern 1: Data Extraction by Object Type

| Task | XCMSnExp | XcmsExperiment |
|------|----------|----------------|
| Get peaks | `chromPeaks(object)` | `chromPeaks(object)` |
| Get sample data | `sampleData(object)` → data.frame | `as.data.frame(sampleData(object))` → data.frame |
| Get file names | `fileNames(object)` | `spectra(object)$dataOrigin` |
| Check for peaks | `hasChromPeaks(object)` | `hasChromPeaks(object)` |
| Check RT adjusted | `hasAdjustedRtime(object)` | `hasAdjustedRtime(object)` |
| Get RT (raw) | `rtime(object, adjusted = FALSE)` | `rtime(spectra(object), adjusted = FALSE)` |
| Get RT (adjusted) | `rtime(object, adjusted = TRUE)` | `rtime(spectra(object), adjusted = TRUE)` |

### Pattern 2: Validation

```r
# Check for required data
if (!hasChromPeaks(object))
    stop("No chromatographic peaks found. Run findChromPeaks first.")

if (!hasAdjustedRtime(object))
    stop("No adjusted retention times. Run adjustRtime first.")

# Validate parameters
if (length(mz) != 2 || any(is.na(mz)))
    stop("'mz' must be a numeric vector of length 2.")

if (binSize <= 0)
    stop("'binSize' must be > 0.")
```

### Pattern 3: Peak Filtering

```r
# Get all peaks
pks <- chromPeaks(object)

# Filter by m/z range
pks <- pks[pks[, "mz"] >= mz[1] & pks[, "mz"] <= mz[2], , drop = FALSE]

# Filter by RT range
pks <- pks[pks[, "rtmin"] <= rt[2] & pks[, "rtmax"] >= rt[1], , drop = FALSE]

# Filter by sample (handle both "sample" and "fileIdx" column names)
sample_col <- if ("sample" %in% colnames(pks)) "sample" else "fileIdx"
pks <- pks[pks[, sample_col] == sample_idx, , drop = FALSE]
```

### Pattern 4: Chromatogram Extraction

```r
# Extract chromatograms for specific m/z and RT range
chrs <- chromatogram(object, mz = c(mz_min, mz_max), rt = c(rt_min, rt_max))

# Access individual chromatogram [row, col]
# row = m/z slice, col = sample
chr <- chrs[1, 1]

# Get data from chromatogram
rt_vals <- rtime(chr)
int_vals <- intensity(chr)

# Check for and get peaks
if (hasChromPeaks(chr)) {
    chr_pks <- chromPeaks(chr)
}
```

### Pattern 5: NSE (Non-Standard Evaluation) for color_by

```r
gplotFunction <- function(object, color_by = NULL, ...) {
    # 1. Capture the uneval expression
    color_col <- rlang::enquo(color_by)

    # 2. Check if provided
    if (!rlang::quo_is_null(color_col)) {
        # 3. Convert to string
        color_name <- rlang::as_name(color_col)

        # 4. Validate column exists in data
        if (!color_name %in% colnames(plot_data))
            stop("Column '", color_name, "' not found")

        # 5. Use in ggplot with !!
        p <- p + aes(color = !!color_col)
    }

    return(p)
}

# Usage:
# gplotFunction(xdata, color_by = sample_group)  # Unquoted
# gplotFunction(xdata, color_by = "sample_group") # Or quoted
```

### Pattern 6: Complete ggplot2 Implementation

```r
setMethod("gplotFunction", "XCMSnExp",
    function(object, color_by = NULL, xlim = NULL, ylim = NULL, ...) {
        # 1. Validate
        if (!hasChromPeaks(object))
            stop("No chromatographic peaks found")

        # 2. Extract data to data.frame
        peaks <- chromPeaks(object)
        sample_df <- as.data.frame(sampleData(object))

        plot_data <- data.frame(
            rt = peaks[, "rt"],
            mz = peaks[, "mz"],
            into = peaks[, "into"],
            sample = peaks[, "sample"],
            stringsAsFactors = FALSE
        )

        # 3. Merge with sample metadata
        plot_data <- merge(plot_data, sample_df, by.x = "sample", by.y = "row.names")

        # 4. Handle NSE
        color_col <- rlang::enquo(color_by)

        # 5. Create base plot
        p <- ggplot(plot_data, aes(x = rt, y = mz))

        # 6. Add color mapping if requested
        if (!rlang::quo_is_null(color_col)) {
            color_name <- rlang::as_name(color_col)
            if (!color_name %in% colnames(plot_data))
                stop("Column '", color_name, "' not found")
            p <- p + aes(color = !!color_col)
        }

        # 7. Add geoms and styling
        p <- p +
            geom_point(alpha = 0.6) +
            labs(
                x = "Retention Time (s)",
                y = "m/z",
                title = "Detected Chromatographic Peaks"
            ) +
            theme_bw() +
            theme(
                legend.position = "right",
                panel.grid.minor = element_blank()
            )

        # 8. Apply limits if provided
        if (!is.null(xlim))
            p <- p + xlim(xlim)
        if (!is.null(ylim))
            p <- p + ylim(ylim)

        return(p)
    })
```

---

## Testing

### Test Template

```r
test_that("functionName works with XCMSnExp", {
    # Setup
    data(faahko_sub, package = "xcms")
    xdata <- faahko_sub

    # Test basic functionality
    result <- functionName(xdata)
    expect_s3_class(result, "gg")
    expect_s3_class(result, "ggplot")

    # Test with parameters
    result2 <- functionName(xdata, param = value)
    expect_s3_class(result2, "ggplot")

    # Test NSE color_by
    sampleData(xdata)$group <- rep(c("A", "B"), length = nrow(sampleData(xdata)))
    result3 <- functionName(xdata, color_by = group)
    expect_s3_class(result3, "ggplot")

    # Test validation
    empty_xdata <- xdata
    empty_xdata@.processHistory <- list()
    expect_error(
        functionName(empty_xdata),
        "No chromatographic peaks"
    )
})

test_that("functionName works with XcmsExperiment", {
    # Similar tests for modern object
    skip_if_not_installed("MsExperiment")

    library(MsExperiment)
    cdf_file <- system.file("cdf/KO/ko15.CDF", package = "faahKO")
    xdata <- readMsExperiment(spectraFiles = cdf_file)
    xdata <- findChromPeaks(xdata, param = CentWaveParam())

    result <- functionName(xdata)
    expect_s3_class(result, "ggplot")
})
```

### Verification Commands

```bash
# Check methods were created
methods("functionName")

# Load and test
devtools::load_all()
devtools::test()
devtools::test_file("tests/testthat/test-functionName.R")

# Full package check
devtools::check()

# Generate documentation
devtools::document()
```

---

## Quick Reference Tables

### Key Accessor Functions

| Function | XCMSnExp | XcmsExperiment | XChromatogram |
|----------|----------|----------------|---------------|
| `chromPeaks()` | ✅ matrix | ✅ matrix | ✅ matrix |
| `sampleData()` | ✅ data.frame | ✅ DataFrame | ❌ |
| `fileNames()` | ✅ character | ❌ | ❌ |
| `hasChromPeaks()` | ✅ logical | ✅ logical | ✅ logical |
| `hasAdjustedRtime()` | ✅ logical | ✅ logical | ❌ |
| `hasFeatures()` | ✅ logical | ✅ logical | ❌ |
| `rtime()` | ✅ numeric | ✅ numeric | ✅ numeric |
| `intensity()` | ❌ | ❌ | ✅ numeric |
| `chromatogram()` | ✅ MChromatograms | ✅ MChromatograms | ❌ |
| `filterFile()` | ✅ XCMSnExp | ✅ XcmsExperiment | ❌ |

### chromPeaks Matrix Columns

| Column | Type | Description |
|--------|------|-------------|
| `mz` | numeric | Peak m/z (apex) |
| `mzmin` | numeric | Minimum m/z |
| `mzmax` | numeric | Maximum m/z |
| `rt` | numeric | Peak retention time (apex) |
| `rtmin` | numeric | Minimum RT |
| `rtmax` | numeric | Maximum RT |
| `into` | numeric | Integrated peak intensity |
| `maxo` | numeric | Maximum intensity (apex) |
| `sn` | numeric | Signal-to-noise ratio |
| `sample` | integer | Sample index (or `fileIdx`) |

### XCMS Parameter Classes

| Class | Purpose | Used With |
|-------|---------|-----------|
| `CentWaveParam` | Centroid peak detection | `findChromPeaks()` |
| `MatchedFilterParam` | Matched filter detection | `findChromPeaks()` |
| `ObiwarpParam` | Obiwarp RT alignment | `adjustRtime()` |
| `PeakGroupsParam` | Peak groups RT alignment | `adjustRtime()` |
| `PeakDensityParam` | Peak density correspondence | `groupChromPeaks()` |
| `NearestPeaksParam` | Nearest peaks correspondence | `groupChromPeaks()` |

---

## XCMS Source Files

### Key GitHub URLs

**Repository**: https://github.com/sneumann/xcms

| File | Purpose |
|------|---------|
| `R/AllGenerics.R` | All generic function declarations |
| `R/methods-XCMSnExp.R` | XCMSnExp processing methods |
| `R/XcmsExperiment.R` | XcmsExperiment processing methods |
| `R/functions-XCMSnExp.R` | Visualization functions |
| `R/methods-Chromatogram.R` | Chromatogram methods including `plot` |
| `R/methods-MChromatograms.R` | Multi-chromatogram methods |
| `R/DataClasses.R` | S4 class definitions |
| `NAMESPACE` | Export configuration |

---

## Common Mistakes & Solutions

| Mistake | Solution |
|---------|----------|
| Forgot `@export` on generic | Add `#' @export` before `setGeneric()` in AllGenerics.R |
| Method not found after defining | Run `devtools::document()` to update NAMESPACE |
| "no slot of name" error | Check object class, use correct accessor function |
| NSE not working | Use `rlang::enquo()` to capture and `!!` to unquote |
| Tests failing with "No peaks" | Check test data has peaks: `hasChromPeaks(test_object)` |
| NAMESPACE conflict | Check for duplicate exports, run `devtools::document()` |
| DataFrame vs data.frame | Convert XcmsExperiment sampleData: `as.data.frame(sampleData(object))` |

---

## File Organization

```
xcmsVis/
├── R/
│   ├── AllGenerics.R              # All setGeneric() with full docs
│   ├── gplot*-methods.R           # setMethod() implementations
│   └── helpers.R                  # Internal helper functions (optional)
│
├── man/                            # Auto-generated by roxygen2
│   └── *.Rd                       # DON'T EDIT THESE
│
├── tests/testthat/
│   ├── setup-*.R                  # Test setup (runs first)
│   └── test-*.R                   # Test files
│
├── vignettes/
│   └── *.qmd                      # Quarto vignettes
│
├── dev-docs/
│   ├── DEV_GUIDE.md              # This file
│   └── BIOCONDUCTOR_CHECKLIST.md # Submission checklist
│
├── NAMESPACE                       # Auto-generated, DON'T EDIT
├── DESCRIPTION                     # Package metadata
└── PROJECT_STATUS.md              # Current project status
```

---

## Object Class Hierarchy

### XCMSnExp (Legacy)

```
XCMSnExp
  └─ extends: MSnExp (from MSnbase)
      └─ contains: OnDiskMSnExp
          └─ slots:
              - processingQueue (list)
              - spectraProcessingQueue (SimpleList)
```

**Key characteristics**:
- Stores spectra on disk
- Processing history in `processingQueue`
- Sample data as `data.frame`
- Used in XCMS < 4.0

### XcmsExperiment (Modern)

```
XcmsExperiment
  └─ extends: MsExperiment (from MsExperiment package)
      └─ uses: Spectra (from Spectra package)
          └─ slots:
              - sampleData (DataFrame - capital D!)
              - spectra (Spectra)
              - chromPeaks (matrix)
              - chromPeakData (DataFrame)
```

**Key characteristics**:
- Modern design using Spectra package
- More efficient memory usage
- Sample data as `DataFrame` (S4, not data.frame)
- Used in XCMS >= 4.0

### XChromatogram

```
XChromatogram
  └─ extends: Chromatogram (from MSnbase)
      └─ slots:
          - rtime (numeric)
          - intensity (numeric)
          - chromPeaks (matrix)
          - chromPeakData (DataFrame)
```

---

## Development Workflow

### Adding New Function Checklist

- [ ] Create `R/gplot*-methods.R` with S4 methods
- [ ] Add roxygen2 documentation in `R/AllGenerics.R`
- [ ] Run `devtools::document()` to update man/ and NAMESPACE
- [ ] Create `tests/testthat/test-*.R` with comprehensive tests
- [ ] Add examples to appropriate vignette
- [ ] Run `devtools::check()` - must pass with 0 errors/warnings
- [ ] Update `NEWS.md` with changes
- [ ] Update `PROJECT_STATUS.md` if adding major functionality
- [ ] Commit with descriptive message following format below

### Commit Message Format

```
type: brief description (max 50 chars)

Detailed explanation of changes, why they were needed,
and what problem they solve. Wrap at 72 characters.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types**: feat, fix, docs, test, refactor, chore, style

---

## Resources

### Documentation
- **XCMS GitHub**: https://github.com/sneumann/xcms
- **XCMS Bioconductor**: https://bioconductor.org/packages/xcms
- **XCMS Website**: https://sneumann.github.io/xcms/
- **Spectra Package**: https://rformassspectrometry.github.io/Spectra/
- **MsExperiment Package**: https://rformassspectrometry.github.io/MsExperiment/

### R Documentation
- **Advanced R S4**: https://adv-r.hadley.nz/s4.html
- **R Methods Package**: https://stat.ethz.ch/R-manual/R-devel/library/methods/html/Methods.html
- **ggplot2**: https://ggplot2.tidyverse.org/
- **rlang NSE**: https://rlang.r-lib.org/reference/topic-quosure.html

---

**Last Updated**: 2025-11-06
**Purpose**: Complete development reference for xcmsVis package
