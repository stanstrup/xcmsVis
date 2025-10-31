# Future Development Tasks

This file contains planned enhancements and future work for the xcmsVis package.

## Add More Plotting Functions

Implement ggplot2 versions of additional XCMS plotting functions:

### Priority 1: Quality Control

- **`gplotQC()`** - Quality control diagnostics
  - `mzdevhist`: Histogram of m/z deviations
  - `rtdevhist`: Histogram of RT deviations
  - `mzdevmass`: m/z deviation vs. mass correlation (with LOESS smoothing)
  - `mzdevtime`: m/z deviation vs. RT
  - `mzdevsample`: Bar plot of median m/z deviation per sample
  - `rtdevsample`: Bar plot of median RT deviation per sample

### Priority 2: Peak Visualization

- **`gplotChromPeaks()`** - Chromatographic peak visualization
  - Display detected peaks as rectangles in m/z-RT space
  - Show peak width in both dimensions

- **`gplotChromPeakImage()`** - Peak intensity heatmap
  - Color intensity plot of peak counts across RT
  - Support binning and log transformation

- **`gplotChromPeakDensity()`** - Peak density visualization
  - Visualize how peaks would be grouped
  - Show which peaks will be combined into features

### Priority 3: Chromatograms

- **`gplotEIC()`** - Extracted ion chromatograms
- **`gplotTIC()`** - Total ion chromatogram
- **`gplotBPC()`** - Base peak chromatogram
- **`gplotChrom()`** - General chromatogram plotting
- **`gplotChromatogramsOverlay()`** - Compare multiple chromatograms

### Priority 4: Additional Visualizations

- **`gplotMsData()`** - Mass spec data display
- **`gplotFeatureGroups()`** - Feature grouping visualization
- **`gplotPeaks()`** - Peak display
- **`gplotSpec()`** - Spectrum plotting
- **`gplotScan()`** - Individual scan plots

## Expand Vignettes

- Add examples for each new plotting function to the comparison vignette
- Create dedicated vignettes for:
  - **Interactive plotting with plotly**: Advanced plotly features and customization
  - **Quality control workflows**: Complete QC pipeline using xcmsVis
  - **Complete LC-MS data analysis visualization**: End-to-end workflow
  - **Customizing plots**: Themes, colors, and advanced ggplot2 techniques

## Add Real Data Examples

- Download example data from Metabonaut tutorials
- Include small example datasets in the package (inst/extdata/)
- Create reproducible examples that don't require external data
- Add data documentation with `?dataset_name`

## Improve Testing

- Create mock XCMSnExp and XcmsExperiment objects for unit tests
- Test all function parameters thoroughly
- Add visual regression tests using vdiffr
- Test plotly interactivity and tooltip content
- Add integration tests with real XCMS workflows
- Increase code coverage to >80%

## Documentation Enhancements

- Add more `@examples` to all functions
- Create a "Getting Started" vignette
- Add comparison tables for all plotting functions
- Document best practices for interactive visualization
- Add troubleshooting section to README

## Performance Optimization

- Profile functions with large datasets
- Optimize data transformation pipelines
- Consider data.table for large data operations
- Add progress bars for long-running operations
- Implement caching for expensive computations

## Interactivity Features

- Create Shiny apps for interactive exploration
  - Real-time parameter adjustment
  - Interactive peak picking
  - Dynamic filtering and selection
- Add crosstalk support for linked plots
- Implement plot animations for time-series data

## Package Infrastructure

- Set up continuous integration testing
- Add code coverage reporting (codecov)
- Create pkgdown articles for advanced topics
- Add hex sticker logo
- Submit to CRAN (after Bioconductor?)
- Consider Bioconductor submission

## Integration with Other Packages

- Better integration with MsFeatures package
- Support for MetaboAnnotation workflows
- Integration with xcms3 new features
- Support for ion mobility data (when available in XcmsExperiment)

## Advanced Features

- Support for faceting by sample groups
- Automatic plot layout for multi-panel figures
- Export functions for publication-ready figures
- Support for different color palettes (viridis, ColorBrewer, etc.)
- Add plot comparison functions (before/after processing)
- Implement plot templates for common use cases

## Community and Outreach

- Write blog posts about package features
- Present at R/Bioconductor conferences
- Create tutorial videos
- Engage with users on GitHub issues
- Contribute improvements back to XCMS if applicable

## Notes

- When adding new functions, follow the established pattern:
  1. Create function in `R/gplot*.R`
  2. Add comprehensive roxygen2 documentation
  3. Update NAMESPACE
  4. Add tests in `tests/testthat/test-*.R`
  5. Add examples to comparison vignette
  6. Update NEWS.md
  7. Run `devtools::check()`
  8. Move task from this file to `completed_tasks.md` when done

- Always maintain compatibility with both XCMSnExp and XcmsExperiment objects
- Include tooltip text for plotly compatibility in all plotting functions
- Write clear, concise commit messages
- Update version number appropriately (MAJOR.MINOR.PATCH)
