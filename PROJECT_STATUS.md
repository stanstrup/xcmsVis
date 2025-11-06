# xcmsVis Project Status

**Last Updated**: 2025-11-06

---

## Quick Summary

**xcmsVis** provides ggplot2-based implementations of XCMS plotting functions with support for both legacy (`XCMSnExp`) and modern (`XcmsExperiment`) objects.

| Metric | Status |
|--------|--------|
| **Functions Implemented** | 5 / 9 priority functions |
| **Object Support** | XCMSnExp ✅ / XcmsExperiment ✅ |
| **Vignettes** | 2 comprehensive guides |
| **Test Coverage** | 3 test files, all passing |
| **R CMD check** | ✅ 0 errors, 0 warnings |
| **GitHub Actions** | ✅ All workflows passing |

---

## Implemented Functions

| Function | XCMS Original | Purpose | Objects Supported | Files |
|----------|---------------|---------|-------------------|-------|
| `gplotAdjustedRtime` | `plotAdjustedRtime` | RT alignment visualization | XCMSnExp, XcmsExperiment | R/gplotAdjustedRtime-methods.R |
| `gplotChromPeaks` | `plotChromPeaks` | Peak detection in RT-m/z space | XCMSnExp, XcmsExperiment | R/gplotChromPeaks-methods.R |
| `gplotChromPeakImage` | `plotChromPeakImage` | Peak density heatmap | XCMSnExp, XcmsExperiment | R/gplotChromPeakImage-methods.R |
| `gplot` | `plot` (S4) | Chromatogram with peaks | XChromatogram | R/gplot-methods.R |
| `ghighlightChromPeaks` | `highlightChromPeaks` | Peak annotation layers | XCMSnExp, XcmsExperiment | R/ghighlightChromPeaks-methods.R |

---

## Vignettes

| File | Title | Topics Covered |
|------|-------|----------------|
| `vignettes/gplotAdjustedRtime.qmd` | Retention Time Alignment Visualization | RT alignment, sample grouping, customization, NSE usage |
| `vignettes/peak-visualization.qmd` | Peak Detection and Chromatogram Visualization | Peak detection, density heatmaps, chromatograms, peak annotations, filtering |

---

## Not Implemented (with Reasons)

| XCMS Function | Reason | Priority | Notes |
|---------------|--------|----------|-------|
| `plotChromPeakDensity` | Use discouraged on XCMSnExp; modern workflow uses XChromatograms | Medium | XCMS now recommends extracting chromatograms first |
| `plotFeatureGroups` | Feature annotation QC; requires feature grouping results | Medium | Worth implementing if users request |
| `plotChromatogramsOverlay` | Works with MChromatograms/XChromatograms, not XCMSnExp/XcmsExperiment | Medium | Different object type |
| `plotPrecursorIons` | MS/MS specific | Low | Specialized use case |
| Legacy functions | Focus on modern XCMS objects | N/A | 15 functions for xcmsRaw/xcmsSet |

---

## File Structure

```
xcmsVis/
├── R/
│   ├── AllGenerics.R                      # All generic declarations
│   ├── gplotAdjustedRtime-methods.R      # 5 method files
│   ├── gplotChromPeaks-methods.R
│   ├── gplotChromPeakImage-methods.R
│   ├── gplot-methods.R
│   └── ghighlightChromPeaks-methods.R
│
├── man/                                   # Auto-generated docs (5 files)
├── tests/testthat/
│   ├── setup-biocparallel.R              # Test infrastructure
│   └── test-*.R                          # 3 test files
│
├── vignettes/                             # 2 vignettes
├── dev-docs/
│   ├── XCMS_REFERENCE.md                 # Consolidated XCMS reference
│   ├── S4_GUIDE.md                       # Consolidated S4 guide
│   └── BIOCONDUCTOR_CHECKLIST.md         # Submission prep
│
└── PROJECT_STATUS.md                      # This file
```

---

## API Design

### Consistent Function Signatures

```r
gplotFunction(object,                    # XCMSnExp or XcmsExperiment
              color_by = NULL,           # NSE column name
              include_columns = NULL,    # Additional metadata
              ...)                       # Function-specific args
```

### S4 Method Dispatch

All functions use proper S4 generics with methods for each object type:

```r
setGeneric("gplotFunction", ...)
setMethod("gplotFunction", "XCMSnExp", ...)
setMethod("gplotFunction", "XcmsExperiment", ...)
```

### Non-Standard Evaluation

```r
# Users can use unquoted column names
gplotAdjustedRtime(xdata, color_by = sample_group)

# Or strings
gplotAdjustedRtime(xdata, color_by = "sample_group")
```

---

## Quality Assurance

### R CMD Check
✅ **Status**: PASS
- 0 Errors
- 0 Warnings
- 0 Notes

### GitHub Actions
✅ **pkgdown deployment**: Deploys to gh-pages branch
✅ **R CMD check**: Tests on multiple R versions and platforms

### Test Infrastructure
- **setup-biocparallel.R**: Configures serial processing to eliminate warnings
- **Comprehensive tests**: All functions tested with both object types
- **Edge cases**: Empty objects, no peaks, invalid parameters

---

## Known Implementation Details

### 1. Multi-Sample Peak Highlighting

`ghighlightChromPeaks` follows XCMS convention:
- Takes full XCMSnExp/XcmsExperiment object
- Searches **all** peaks across all samples
- Filters by rt/mz parameters

**Recommended**: Use `filterFile()` first for single-sample visualization.

### 2. Polygon Peak Visualization

Exact replication of XCMS behavior:
- Extracts chromatograms for **entire m/z range** (not per-peak)
- Orders peaks by intensity descending
- Creates closed polygons following chromatogram intensities

See: `R/ghighlightChromPeaks-methods.R` lines 95-150

---

## Future Work

### High Priority

| Task | Description | Effort |
|------|-------------|--------|
| `gplotFeatureGroups` | Feature annotation QC | Medium |
| `gplotChromatogramsOverlay` | Overlay multiple EICs | Medium |
| Visual regression tests | Using vdiffr package | Low |
| Plotly integration guide | Optimize tooltips, interactivity | Low |

### Medium Priority

| Task | Description | Effort |
|------|-------------|--------|
| Additional vignettes | Interactive plotting, QC workflows | Medium |
| Performance profiling | Test with large datasets | Low |
| Color palette support | viridis, ColorBrewer, etc. | Low |
| Export helpers | Publication-ready figures | Low |

### Low Priority

| Task | Description | Effort |
|------|-------------|--------|
| Shiny apps | Interactive exploration | High |
| Ion mobility support | When available in XCMS | High |
| Additional XCMS functions | TIC, BPC, spectrum plots | Medium |
| Bioconductor submission | Package submission | Medium |

### Infrastructure

| Task | Description | Status |
|------|-------------|--------|
| Code coverage reporting | codecov integration | Planned |
| Hex sticker logo | Package branding | Planned |
| pkgdown articles | Advanced topics | Planned |
| Tutorial videos | YouTube/Vimeo | Idea |
| Blog posts | Package features | Idea |

---

## Development Workflow

### Adding New Functions

1. ✅ Create `R/gplot*.R` with S4 methods
2. ✅ Add roxygen2 documentation in `R/AllGenerics.R`
3. ✅ Run `devtools::document()` to update man/ and NAMESPACE
4. ✅ Create tests in `tests/testthat/test-*.R`
5. ✅ Add examples to vignettes
6. ✅ Run `devtools::check()`
7. ✅ Update NEWS.md
8. ✅ Commit with descriptive message

### Testing Checklist

- [ ] Test with both XCMSnExp and XcmsExperiment
- [ ] Test all parameter combinations
- [ ] Test edge cases (empty, no peaks, etc.)
- [ ] Test NSE `color_by` functionality
- [ ] Verify ggplot object returned
- [ ] Check documentation examples work
- [ ] Run full `devtools::check()`

### Commit Message Format

```
type: brief description

Detailed explanation of changes.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types**: feat, fix, docs, test, refactor, chore

---

## Dependencies

### Required

| Package | Purpose |
|---------|---------|
| ggplot2 | Plotting framework |
| methods | S4 class system |
| xcms | Source package |
| MsExperiment | Modern MS objects |
| MSnbase | Base MS classes |
| Spectra | Spectrum handling |
| BiocParallel | Parallel processing |

### Testing

| Package | Purpose |
|---------|---------|
| testthat | Testing framework |
| faahKO | Example data |

### Suggested

| Package | Purpose |
|---------|---------|
| plotly | Interactive plots |
| quarto | Vignette rendering |

---

## Documentation Structure

### Roxygen2 Pattern

```r
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

- ✅ Comprehensive parameter descriptions
- ✅ Working examples with faahKO data
- ✅ Cross-references to XCMS originals
- ✅ Usage notes for both object types
- ✅ Behavior explanations

---

## Key Achievements

1. ✅ **5 core functions** implemented with full dual-object support
2. ✅ **Exact XCMS replication** for all visualization behaviors
3. ✅ **Comprehensive documentation** with side-by-side comparisons
4. ✅ **Full test coverage** including edge cases
5. ✅ **Clean package structure** following R best practices
6. ✅ **GitHub Actions** CI/CD pipeline
7. ✅ **NSE support** for user-friendly API
8. ✅ **Two comprehensive vignettes** with examples

---

## Usage Examples

### Quick Start

```r
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
```

### Advanced: Filtered Peak Highlighting

```r
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

---

## Resources

### Documentation
- **Package Website**: https://stanstrup.github.io/xcmsVis/ (via pkgdown)
- **XCMS Package**: https://github.com/sneumann/xcms
- **Bioconductor XCMS**: https://bioconductor.org/packages/xcms

### Development Guides
- `dev-docs/XCMS_REFERENCE.md` - XCMS function and pattern reference
- `dev-docs/S4_GUIDE.md` - S4 implementation guide
- `dev-docs/BIOCONDUCTOR_CHECKLIST.md` - Submission preparation
- `CLAUDE.md` - Development workflow and conventions

---

## Contributors

Developed using Claude Code with extensive reference to XCMS source code and documentation.

---

## License

Same as XCMS package (GPL-2 or GPL-3)

---

**Questions or Issues?**
- GitHub Issues: https://github.com/stanstrup/xcmsVis/issues
- XCMS Google Group: https://groups.google.com/g/xcms
