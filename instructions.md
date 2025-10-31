# xcmsVis Development Instructions

## Project Overview

Your purpose is to make an R package, xcmsVis, that should be a parallel package to the XCMS package.
The goal is to implement all the plots in xcms as ggplot2 plots so they can be made interactive.

**Motivation**: https://github.com/sneumann/xcms/issues/551

**Note**: For completed tasks, see `completed_tasks.md`

## Current Tasks

1) run pkgdown and fix any errors
2) use markdown-style in man pages
3) Split away your future tasks section to a seperate file. this seem like token burn to read all this in every time.

## Future Tasks

### Add More Plotting Functions

Implement ggplot2 versions of additional XCMS plotting functions:

- `plotQC()` - Quality control diagnostics
  - `mzdevhist`, `rtdevhist`, `mzdevmass`, `mzdevtime`
  - `mzdevsample`, `rtdevsample`
- `plotChromPeaks()` - Chromatographic peak visualization
- `plotChromPeakImage()` - Peak intensity heatmap
- `plotChromPeakDensity()` - Peak density visualization
- `plotEIC()` - Extracted ion chromatograms
- `plotTIC()` - Total ion chromatogram
- `plotBPC()` - Base peak chromatogram
- `plotMsData()` - Mass spec data display
- `plotFeatureGroups()` - Feature grouping visualization

### Expand Vignettes

- Add examples for each new plotting function to the comparison vignette
- Create dedicated vignettes for:
  - Interactive plotting with plotly
  - Quality control workflows
  - Complete LC-MS data analysis visualization

### Add Real Data Examples

- Download example data from Metabonaut tutorials
- Include small example datasets in package
- Create reproducible examples that don't require external data

### Improve Testing

- Create mock XCMSnExp objects for unit tests
- Test all function parameters
- Add visual regression tests
- Test plotly interactivity

### Long-term Goals

- Complete XCMS plotting suite
- Add shiny apps for interactive exploration
- Performance optimization for large datasets
- Submit to Bioconductor

## Development Workflow

### Adding New Functions

1. Identify XCMS plotting function to implement
2. Locate source code in XCMS GitHub: https://github.com/sneumann/xcms
3. Study the function's purpose, parameters, and output
4. Implement ggplot2 version in `R/gplot*.R`
5. Add roxygen2 documentation
6. Update NAMESPACE if needed
7. Add tests in `tests/testthat/test-*.R`
8. Add examples to vignette
9. Update NEWS.md
10. Run `devtools::check()`
11. Move task from this file to `completed_tasks.md` when done

### Testing Commands

```r
# Load package for development
devtools::load_all()

# Run tests
devtools::test()

# Check package
devtools::check()

# Build documentation
devtools::document()

# Build pkgdown site locally
pkgdown::build_site()
```

## Key Resources

- **XCMS Repository**: https://github.com/sneumann/xcms
- **Metabonaut Tutorials**: https://github.com/rformassspectrometry/Metabonaut
- **Original Discussion**: https://github.com/sneumann/xcms/issues/551
- **Package Structure Reference**: `/mnt/c/Users/tmh331/Desktop/gits/remoteUpdater`
- **Function Reference**: `/mnt/c/Users/tmh331/Desktop/gits/_Introduction to Nutritional Metabolomics/inm-booklet/scripts/funs.R`

## Important Conventions

- Follow XCMS conventions for object types and methods
- Maintain compatibility with both XCMSnExp and xcmsExperiment objects
- Use consistent naming: `gplot*` prefix for all plotting functions
- Include tooltip text for plotly compatibility
- Write comprehensive roxygen2 documentation
- Add examples (even if marked `\dontrun`)
- When tasks are completed, move them to `completed_tasks.md`

## Git Workflow

- Default branch: `main`
- Use conventional commits
- GitHub Actions will automatically:
  - Run R CMD check on push/PR
  - Deploy pkgdown site on push to main
- Always commit with co-authorship footer when using Claude Code
