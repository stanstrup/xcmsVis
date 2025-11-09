---
editor_options: 
  markdown: 
    wrap: 72
---

# xcmsVis Project Status

**Last Updated**: 2025-11-09

------------------------------------------------------------------------

## Quick Summary

**xcmsVis** provides ggplot2-based implementations of XCMS plotting
functions with support for both legacy (`XCMSnExp`) and modern
(`XcmsExperiment`) objects.

| Metric                   | Status                               |
|--------------------------|--------------------------------------|
| **Core Functions**       | 11 / 11 modern XCMS functions complete |
| **Object Support**       | XCMSnExp ✅ / XcmsExperiment ✅ / LamaParama ✅      |
| **Vignettes**            | 7 comprehensive guides               |
| **Test Coverage**        | 11 test files, all tests passing      |
| **R CMD check**          | ✅ 0 errors, 0 warnings              |
| **GitHub Actions**       | ✅ All workflows passing             |
| **Remaining XCMS plots** | 0 - All modern functions implemented |

------------------------------------------------------------------------

## Implemented Functions

| Function | XCMS Original | Purpose | Objects Supported | Files |
|---------------|---------------|---------------|---------------|---------------|
| `gplotAdjustedRtime` | `plotAdjustedRtime` | RT alignment visualization | XCMSnExp, XcmsExperiment | R/gplotAdjustedRtime-methods.R |
| `gplotChromPeaks` | `plotChromPeaks` | Peak detection in RT-m/z space | XCMSnExp, XcmsExperiment | R/gplotChromPeaks-methods.R |
| `gplotChromPeakImage` | `plotChromPeakImage` | Peak density heatmap | XCMSnExp, XcmsExperiment | R/gplotChromPeakImage-methods.R |
| `gplotChromPeakDensity` | `plotChromPeakDensity` | Peak density for parameter tuning | XChromatograms, MChromatograms | R/gplotChromPeakDensity-methods.R |
| `gplotChromatogramsOverlay` | `plotChromatogramsOverlay` | Overlay multiple EICs | XChromatograms, MChromatograms | R/gplotChromatogramsOverlay-methods.R |
| `gplot` | `plot` (S4) | Chromatogram with peaks | XChromatogram, XChromatograms, MChromatograms | R/gplot-methods.R |
| `gplot` | `plot` (S4) | BPI and MS map visualization | XcmsExperiment | R/gplot-XcmsExperiment-methods.R |
| `gplot` | `plot` (S4) | RT alignment parameter visualization | LamaParama | R/gplot-LamaParama-methods.R |
| `gplotFeatureGroups` | `plotFeatureGroups` | Feature group visualization | XCMSnExp, XcmsExperiment | R/gplotFeatureGroups-methods.R |
| `gplotPrecursorIons` | `plotPrecursorIons` | Precursor ion visualization | MsExperiment | R/gplotPrecursorIons-methods.R |
| `ghighlightChromPeaks` | `highlightChromPeaks` | Peak annotation layers | XCMSnExp, XcmsExperiment | R/ghighlightChromPeaks-methods.R |

------------------------------------------------------------------------

## Vignettes

| File | Title | Topics Covered |
|------------------------|------------------------|------------------------|
| `vignettes/gplotAdjustedRtime.qmd` | Retention Time Alignment Visualization | RT alignment, sample grouping, customization, NSE usage |
| `vignettes/peak-visualization.qmd` | Peak Detection and Chromatogram Visualization | Peak detection, density heatmaps, chromatograms, peak annotations, filtering |
| `vignettes/chromatogram-visualization.qmd` | Chromatogram and Peak Density Visualization | Chromatogram plotting, peak density, overlay plots, parameter tuning |
| `vignettes/xcmsexperiment-visualization.qmd` | XcmsExperiment Visualization | BPI and MS map visualization, multi-level MS data, interactive plots |
| `vignettes/feature-groups-visualization.qmd` | Feature Groups Visualization | Feature grouping, related features, isotopes/adducts, customization, interactive plots |
| `vignettes/alignment-parameters.qmd` | RT Alignment Parameter Visualization | LamaParama objects, parameter assessment, alignment quality |
| `vignettes/precursor-ions.qmd` | Precursor Ion Visualization | MS/MS precursor ions, fragment relationships, MS2 data exploration |

------------------------------------------------------------------------

## Additional XCMS Plotting Functions

**Complete analysis based on comprehensive search of XCMS source code
(66 R files reviewed)**

### ✅ All Modern Functions Implemented

All modern XCMS plotting functions for XCMSnExp, XcmsExperiment, MsExperiment, and LamaParama objects have been implemented.

### Deprecated/Internal Functions - Not Implementing

| XCMS Function | Status | Reason |
|------------------------|------------------------|------------------------|
| `plotMsData` | Deprecated | XCMS deprecated in favor of `plot(x, type = "XIC")` |
| `plotSpecWindow` | Internal | xcmsSet helper function, not exported |

### Not Implementing - Legacy xcmsRaw/xcmsSet/xcmsFragments Objects

The following 11 functions are for legacy objects and are not planned
for implementation as the focus is on modern XCMSnExp and XcmsExperiment
workflows:

`plotChrom`, `plotEIC`, `plotPeaks`, `plotRaw`, `plotScan`, `plotSpec`,
`plotSurf`, `plotTIC` (xcmsRaw); `plotrt`, `plotQC` (xcmsSet);
`plotTree` (xcmsFragments)

------------------------------------------------------------------------

## File Structure

```         
xcmsVis/
├── R/
│   ├── AllGenerics.R                      # All generic declarations
│   ├── gplotAdjustedRtime-methods.R      # 9 method files
│   ├── gplotChromPeaks-methods.R
│   ├── gplotChromPeakImage-methods.R
│   ├── gplotChromPeakDensity-methods.R
│   ├── gplotChromatogramsOverlay-methods.R
│   ├── gplotFeatureGroups-methods.R
│   ├── gplot-methods.R
│   ├── gplot-XcmsExperiment-methods.R
│   └── ghighlightChromPeaks-methods.R
│
├── man/                                   # Auto-generated docs (9 files)
├── tests/testthat/
│   ├── setup-biocparallel.R              # Test infrastructure
│   └── test-*.R                          # 9 test files
│
├── vignettes/                             # 5 vignettes
├── dev-docs/
│   ├── XCMS_REFERENCE.md                 # Consolidated XCMS reference
│   ├── S4_GUIDE.md                       # Consolidated S4 guide
│   └── BIOCONDUCTOR_CHECKLIST.md         # Submission prep
│
└── PROJECT_STATUS.md                      # This file
```

------------------------------------------------------------------------

## API Design

### Consistent Function Signatures

``` r
gplotFunction(object,                    # XCMSnExp or XcmsExperiment
              color_by = NULL,           # NSE column name
              include_columns = NULL,    # Additional metadata
              ...)                       # Function-specific args
```

### S4 Method Dispatch

All functions use proper S4 generics with methods for each object type:

``` r
setGeneric("gplotFunction", ...)
setMethod("gplotFunction", "XCMSnExp", ...)
setMethod("gplotFunction", "XcmsExperiment", ...)
```

### Non-Standard Evaluation

``` r
# Users can use unquoted column names
gplotAdjustedRtime(xdata, color_by = sample_group)

# Or strings
gplotAdjustedRtime(xdata, color_by = "sample_group")
```

------------------------------------------------------------------------

## Quality Assurance

### R CMD Check

✅ **Status**: PASS - 0 Errors - 0 Warnings - 0 Notes

### GitHub Actions

✅ **pkgdown deployment**: Deploys to gh-pages branch ✅ **R CMD
check**: Tests on multiple R versions and platforms

### Test Infrastructure

-   **setup-biocparallel.R**: Configures serial processing to eliminate
    warnings
-   **Comprehensive tests**: All functions tested with both object types
-   **Edge cases**: Empty objects, no peaks, invalid parameters

------------------------------------------------------------------------

## Known Implementation Details

### 1. Multi-Sample Peak Highlighting

`ghighlightChromPeaks` follows XCMS convention:

-   Takes full XCMSnExp/XcmsExperiment object
-   Searches **all** peaks across all samples
-   Filters by rt/mz parameters

**Recommended**: Use `filterFile()` first for single-sample
visualization.

### 2. Polygon Peak Visualization

Exact replication of XCMS behavior: - Extracts chromatograms for
**entire m/z range** (not per-peak) - Orders peaks by intensity
descending - Creates closed polygons following chromatogram intensities

See: `R/ghighlightChromPeaks-methods.R` lines 95-150

------------------------------------------------------------------------

## Future Work

### Potential Enhancements

| Category | Task | Description | Priority | Effort |
|---------------|---------------|---------------|---------------|---------------|
| **Functions** | Additional XCMS plots | `plotPrecursorIons`, `plotMsData` | Low | Medium |
| **Testing** | Visual regression tests | Using vdiffr package for plot comparison | Medium | Low |
| **Documentation** | Interactive plotting guide | Best practices for plotly integration | Medium | Low |
| **Performance** | Large dataset profiling | Test and optimize for 100+ samples | Medium | Low |
| **Customization** | Color palette support | viridis, ColorBrewer integration | Low | Low |
| **Export** | Publication helpers | Functions for high-res figures | Low | Low |
| **Infrastructure** | Code coverage reporting | codecov integration | Low | Low |
| **Community** | Bioconductor submission | Package submission to Bioconductor | Future | High |

### Not Planned

| Task | Reason |
|------------------------------------|------------------------------------|
| Shiny apps | Out of scope; users can build with existing functions |
| Ion mobility support | Waiting for XCMS implementation |
| Legacy function ports | Focus is on modern XCMSnExp/XcmsExperiment workflow |

------------------------------------------------------------------------

## Development Workflow

### Adding New Functions

1.  ✅ Create `R/gplot*.R` with S4 methods
2.  ✅ Add roxygen2 documentation in `R/AllGenerics.R`
3.  ✅ Run `devtools::document()` to update man/ and NAMESPACE
4.  ✅ Create tests in `tests/testthat/test-*.R`
5.  ✅ Add examples to vignettes
6.  ✅ Run `devtools::check()`
7.  ✅ Update NEWS.md
8.  ✅ Commit with descriptive message

### Testing Checklist

-   [ ] Test with both XCMSnExp and XcmsExperiment
-   [ ] Test all parameter combinations
-   [ ] Test edge cases (empty, no peaks, etc.)
-   [ ] Test NSE `color_by` functionality
-   [ ] Verify ggplot object returned
-   [ ] Check documentation examples work
-   [ ] Run full `devtools::check()`

### Commit Message Format

```         
type: brief description

Detailed explanation of changes.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types**: feat, fix, docs, test, refactor, chore

------------------------------------------------------------------------

## Dependencies

### Required

| Package      | Purpose             |
|--------------|---------------------|
| ggplot2      | Plotting framework  |
| methods      | S4 class system     |
| xcms         | Source package      |
| MsExperiment | Modern MS objects   |
| MSnbase      | Base MS classes     |
| Spectra      | Spectrum handling   |
| BiocParallel | Parallel processing |

### Testing

| Package  | Purpose           |
|----------|-------------------|
| testthat | Testing framework |
| faahKO   | Example data      |

### Suggested

| Package | Purpose            |
|---------|--------------------|
| plotly  | Interactive plots  |
| quarto  | Vignette rendering |

------------------------------------------------------------------------

## Documentation Structure

### Roxygen2 Pattern

``` r
#' @title Function Title
#' @description Brief description
#' @param object An `XCMSnExp` or `XcmsExperiment` object
#' @return A ggplot object
#' @details Detailed explanation
#' @examples
#' \donttest{
#' # Working examples using faahKO data
#' }
#' @seealso \code{\link[xcms]{originalFunction}}
#' @export
setGeneric("functionName", ...)
```

### Man Page Features

-   ✅ Comprehensive parameter descriptions
-   ✅ Working examples with faahKO data
-   ✅ Cross-references to XCMS originals
-   ✅ Usage notes for both object types
-   ✅ Behavior explanations

------------------------------------------------------------------------

## Key Achievements

1.  ✅ **9 core functions** implemented with full dual-object support
2.  ✅ **Exact XCMS replication** for all visualization behaviors
3.  ✅ **Comprehensive documentation** with side-by-side comparisons
4.  ✅ **Full test coverage** including edge cases (9 test files, 153
    tests passing)
5.  ✅ **Clean package structure** following R best practices
6.  ✅ **GitHub Actions** CI/CD pipeline
7.  ✅ **NSE support** for user-friendly API
8.  ✅ **Five comprehensive vignettes** covering all major use cases
9.  ✅ **XcmsExperiment BPI/MS map visualization** with patchwork
    integration
10. ✅ **Chromatogram overlay** and peak density visualization
11. ✅ **Feature group visualization** with connected features across
    RT-m/z space

------------------------------------------------------------------------

## Usage Examples

### Quick Start

``` r
library(xcmsVis)
library(xcms)
library(faahKO)
library(MsExperiment)

# Load data
cdf_files <- dir(system.file("cdf", package = "faahKO"),
                 recursive = TRUE, full.names = TRUE)[1:3]
xdata <- readMsExperiment(spectraFiles = cdf_files)

# Peak detection
xdata <- findChromPeaks(xdata, param = CentWaveParam())

# Visualizations
gplotChromPeaks(xdata)
gplotChromPeakImage(xdata)

# RT alignment
xdata <- adjustRtime(xdata, param = ObiwarpParam())
gplotAdjustedRtime(xdata, color_by = sample_name)

# Chromatogram plotting
chr <- chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))
gplot(chr[1, 1])

# XcmsExperiment BPI and MS map visualization
gplot(xdata)  # Creates combined BPI + MS map with patchwork
```

### Advanced: Filtered Peak Highlighting

``` r
# Extract chromatogram
chr <- chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

# Highlight only peaks from first sample
gplot(chr[1, 1], peakType = "none") +
  ghighlightChromPeaks(
    filterFile(xdata, 1),
    rt = c(2500, 3500),
    mz = c(200, 210),
    type = "polygon",
    border = "blue"
  )
```

------------------------------------------------------------------------

## Resources

### Documentation

-   **Package Website**: <https://stanstrup.github.io/xcmsVis/> (via
    pkgdown)
-   **XCMS Package**: <https://github.com/sneumann/xcms>
-   **Bioconductor XCMS**: <https://bioconductor.org/packages/xcms>

### Development Guides

-   `dev-docs/XCMS_REFERENCE.md` - XCMS function and pattern reference
-   `dev-docs/S4_GUIDE.md` - S4 implementation guide
-   `dev-docs/BIOCONDUCTOR_CHECKLIST.md` - Submission preparation
-   `CLAUDE.md` - Development workflow and conventions

------------------------------------------------------------------------

## Contributors

Developed using Claude Code with extensive reference to XCMS source code
and documentation.

------------------------------------------------------------------------

## License

Same as XCMS package (GPL-2 or GPL-3)

------------------------------------------------------------------------

**Questions or Issues?** - GitHub Issues:
<https://github.com/stanstrup/xcmsVis/issues> - XCMS Google Group:
<https://groups.google.com/g/xcms>
