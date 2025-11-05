# Bioconductor Submission Checklist for xcmsVis

## Status: Not Ready for Submission

### Required Changes Before Submission

#### 1. Version Number ✅
- **Current**: `0.99.0`
- **Required**: `0.99.0` (or `0.99.x` for new submissions)
- **Status**: ✅ Changed

#### 2. Quarto SystemRequirements ✅
- **Current**: `VignetteBuilder: quarto`
- **Required**: `SystemRequirements: quarto` in DESCRIPTION
- **Status**: ✅ Added
- **Note**: Quarto vignettes are officially supported by Bioconductor (see [docs](https://contributions.bioconductor.org/docs.html))

#### 3. R CMD check Status ⚠️
- **Action**: Must pass `R CMD check` with no ERRORS, no WARNINGS
- **Current**: Need to verify with R-devel
- **Action**: Run `devtools::check()` and address all issues

#### 4. BiocCheck Requirements ⚠️
- **Action**: Install BiocCheck and run:
  ```r
  BiocManager::install("BiocCheck")
  BiocCheck::BiocCheck('.', 'new-package'=TRUE)
  ```
- **Action**: Address all ERRORS and WARNINGS from BiocCheck

#### 5. Examples Coverage ⚠️
- **Requirement**: At least 80% of exported functions must have executable examples
- **Current**: Need to verify coverage
- **Action**: Add `@examples` to all exported functions (can use `\dontrun{}` if needed)

#### 6. Build Time ✅ (likely OK)
- **Requirement**: < 10 minutes for `R CMD check --no-build-vignettes`
- **Action**: Verify build time

### Already Compliant ✅

1. **biocViews Field**: Present and appropriate (Metabolomics, MassSpectrometry, Visualization)
2. **Vignettes**: Vignettes directory exists with content
3. **Tests**: Comprehensive test suite exists
4. **Documentation**: Functions are documented with roxygen2
5. **License**: MIT license properly specified
6. **Repository**: GitHub repository exists
7. **URL/BugReports**: Properly specified
8. **Dependencies**: All dependencies available on CRAN or Bioconductor

### Optional but Recommended

1. **Add a CITATION file**: Helps users cite the package properly
2. **NEWS file**: Already have NEWS.md (✅)
3. **README**: Already have README.md (✅)
4. **Code coverage**: Consider adding coverage reports

### Submission Process

Once all requirements are met:

1. Ensure SSH public key is added to GitHub account
2. Create issue at https://github.com/Bioconductor/Contributions
3. Follow the new package workflow template
4. Wait for review from Bioconductor team
5. Address reviewer comments

### Key Bioconductor Guidelines

- Package size limit: 5 MB for software packages
- Individual files: 5 MB limit
- Avoid unnecessary files (.DS_Store, .Rproj, etc.) - add to .Rbuildignore
- All ERROR, WARNING, and NOTE items must be addressed or justified

### Resources

- [Bioconductor Package Guidelines](https://master.bioconductor.org/developers/package-guidelines/)
- [Contributions Guide](https://contributions.bioconductor.org/)
- [BiocCheck Documentation](https://www.bioconductor.org/packages/devel/bioc/vignettes/BiocCheck/inst/doc/BiocCheck.html)

## Priority Actions

1. Change version to `0.99.0` in DESCRIPTION
2. Ensure R CMD check passes with no errors/warnings
3. Run BiocCheck and address issues
4. Verify examples coverage (80%+)
5. Consider converting Quarto vignette to R Markdown for better Bioconductor compatibility
