# xcmsVis Development Instructions

## Project Overview

Your purpose is to make an R package, xcmsVis, that should be a parallel package to the XCMS package.
The goal is to implement all the plots in xcms as ggplot2 plots so they can be made interactive.

**Motivation**: https://github.com/sneumann/xcms/issues/551

**Note**: For completed tasks, see `completed_tasks.md`

## Current Tasks

**All initial setup tasks are complete!** See `completed_tasks.md` for the full list of 13 completed tasks.

**Future development tasks** are documented in `future_tasks.md`.

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
