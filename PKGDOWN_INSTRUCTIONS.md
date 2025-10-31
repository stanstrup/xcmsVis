# Building the pkgdown Documentation Site

## Prerequisites

Ensure you have all required packages installed:

```r
install.packages(c("pkgdown", "devtools", "roxygen2"))

# Install Bioconductor packages
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(c("xcms", "MsExperiment", "MSnbase", "BiocStyle"))
```

## Building Locally

### 1. Generate Documentation

First, ensure all roxygen documentation is up to date:

```r
devtools::document()
```

### 2. Build the pkgdown Site

Build the complete site locally:

```r
pkgdown::build_site()
```

This will create a `docs/` directory with the complete website.

### 3. Preview Locally

After building, you can preview the site:

```r
pkgdown::preview_site()
```

Or manually open `docs/index.html` in your browser.

## Deploying to GitHub Pages

### Option 1: Automatic Deployment (Recommended)

The GitHub Actions workflow `.github/workflows/pkgdown.yaml` is already configured to automatically build and deploy the site when you push to the `main` branch.

**Steps:**
1. Push your changes to GitHub:
   ```bash
   git push origin main
   ```

2. GitHub Actions will automatically:
   - Build the pkgdown site
   - Deploy it to the `gh-pages` branch
   - Make it available at: `https://yourusername.github.io/xcmsVis`

3. Enable GitHub Pages in repository settings:
   - Go to repository Settings → Pages
   - Under "Source", select branch: `gh-pages`
   - Select folder: `/ (root)`
   - Save

### Option 2: Manual Deployment

If you need to deploy manually:

```r
# Build and deploy to gh-pages branch
pkgdown::deploy_to_branch()
```

## Verifying the Deployment

After deployment, check:

1. **GitHub Actions**: Go to repository → Actions tab to see build status
2. **GitHub Pages**: Go to repository → Settings → Pages to see the URL
3. **Live Site**: Visit `https://yourusername.github.io/xcmsVis`

## Troubleshooting

### Build Fails

If the pkgdown build fails:

```r
# Check for errors
devtools::check()

# Rebuild documentation
devtools::document()

# Try building again
pkgdown::build_site()
```

### Missing Dependencies

If you get package not found errors:

```r
# Install missing packages
install.packages("package_name")

# For Bioconductor packages
BiocManager::install("package_name")
```

### GitHub Actions Fails

Check the Actions tab for detailed error logs. Common issues:

- Missing package dependencies (add to DESCRIPTION)
- Roxygen errors (run `devtools::document()` locally first)
- NAMESPACE issues (regenerate with roxygen2)

## Site Structure

The pkgdown site includes:

- **Home**: index.html (from index.md or README.md)
- **Reference**: Function documentation (from roxygen2)
- **Articles**: Vignettes (from vignettes/)
- **Changelog**: NEWS.md
- **Get Started**: Optional getting started guide

## Customization

Edit `_pkgdown.yml` to customize:

- Navigation structure
- Theme and colors
- Reference organization
- Article order
- External links

## Files Generated

After building, the `docs/` directory contains:

```
docs/
├── index.html              # Home page
├── reference/              # Function documentation
│   ├── index.html
│   └── gplotAdjustedRtime.html
├── articles/               # Vignettes
│   └── comparing-visualizations.html
├── news/                   # Changelog
│   └── index.html
├── pkgdown.yml            # Build metadata
└── [CSS, JS, images...]   # Site assets
```

## Next Steps After Deployment

1. Verify all pages render correctly
2. Test all links work
3. Check that vignettes display properly
4. Ensure code examples are highlighted correctly
5. Test the site on mobile devices
6. Share the URL with collaborators!
