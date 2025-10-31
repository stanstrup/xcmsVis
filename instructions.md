# xcmsVis Development Instructions

## Project Overview

Your purpose is to make an R package, xcmsVis, that should be a parallel package to the XCMS package.
The goal is to implement all the plots in xcms as ggplot2 plots so they can be made interactive.

**Motivation**: https://github.com/sneumann/xcms/issues/551

## Completed Tasks

All initial setup tasks have been completed. See `completed_tasks.md` for details:

1. ✅ Made the folder a git repo
2. ✅ Familiarized with XCMS codebase
3. ✅ Following XCMS package conventions
4. ✅ Created package structure with pkgdown
5. ✅ Implemented gplotAdjustedRtime
6. ✅ Created comparison vignette
7. ✅ Moved completed tasks to separate file
8. ✅ Updated instructions
9. ✅ Set main as default branch
10. ✅ Set up GitHub Actions CI

## Current/Remaining Tasks

### 12. Support xcmsExperiment objects
- **Status**: 🔄 To Do
- **Details**: Update functions to work with both XCMSnExp and xcmsExperiment objects
  - xcmsExperiment is the newer XCMS object type
  - Need to add method dispatch for both object types
  - Update documentation and examples
  - Test compatibility with xcmsExperiment

### 13. Generate pkgdown page
- **Status**: 🔄 To Do
- **Details**: Build and deploy the pkgdown documentation site
  - Run `pkgdown::build_site()` locally
  - Ensure GitHub Actions workflow builds it automatically
  - Verify deployment to GitHub Pages

## Next Steps

### Short-term Goals

1. **Complete xcmsExperiment support** - Ensure all functions work with xcmsExperiment objects
2. **Generate pkgdown site** - Build and deploy documentation
3. **Add more plotting functions** - Implement ggplot2 versions of:
   - `plotQC()` - Quality control diagnostics
   - `plotChromPeaks()` - Chromatographic peak visualization
   - `plotChromPeakImage()` - Peak intensity heatmap
   - `plotChromPeakDensity()` - Peak density visualization
   - `plotEIC()` - Extracted ion chromatograms

4. **Expand vignettes** - Add examples for each new plotting function
5. **Add real data examples** - Download and include example data from Metabonaut tutorials
6. **Improve testing** - Create mock XCMSnExp objects for unit tests

### Long-term Goals

1. **Complete XCMS plotting suite** - Implement all remaining XCMS plotting functions
2. **Add interactive features** - Create shiny apps for interactive exploration
3. **Performance optimization** - Optimize for large datasets
4. **Submit to Bioconductor** - Prepare and submit package to Bioconductor

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

## Git Workflow

- Default branch: `main`
- Use conventional commits
- GitHub Actions will automatically:
  - Run R CMD check on push/PR
  - Deploy pkgdown site on push to main
