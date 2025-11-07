test_that("gplotChromatogramsOverlay works with single row single sample", {
    library(xcms)
    library(ggplot2)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram for one m/z range (single row) from one sample
    chr <- chromatogram(xdata[1,], mz = c(305.05, 305.15))

    # Create overlay plot
    p <- gplotChromatogramsOverlay(chr)

    # Verify output - single plot
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
})

test_that("gplotChromatogramsOverlay overlays multiple rows in same plot", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatograms for multiple m/z ranges (multiple rows) from one sample
    chr <- chromatogram(xdata[1,], mz = rbind(c(305.05, 305.15), c(344.0, 344.2)))

    # Create overlay plot
    p <- gplotChromatogramsOverlay(chr)

    # Should return single ggplot with multiple EICs overlaid
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
    # Not a patchwork - just a single plot with overlaid lines
    expect_false(inherits(p, "patchwork"))
})

test_that("gplotChromatogramsOverlay facets multiple samples", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatograms - one row, multiple samples (columns)
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Create overlay plot
    p <- gplotChromatogramsOverlay(chr)

    # Should use faceting for multiple samples
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
    # Check that faceting was applied
    expect_true(!is.null(p$facet))
})

test_that("gplotChromatogramsOverlay works with stacked parameter", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract multiple EICs from one sample
    chr <- chromatogram(xdata[1,], mz = rbind(c(305.05, 305.15), c(344.0, 344.2)))

    # Create stacked overlay plot
    p <- gplotChromatogramsOverlay(chr, stacked = 1e6)

    # Verify output
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
})

test_that("gplotChromatogramsOverlay works with transform parameter", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram from one sample
    chr <- chromatogram(xdata[1,], mz = c(305.05, 305.15))

    # Create plot with log transformation
    p <- gplotChromatogramsOverlay(chr, transform = log1p)

    # Verify output
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
})

test_that("gplotChromatogramsOverlay works with different peak types", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram from one sample
    chr <- chromatogram(xdata[1,], mz = c(305.05, 305.15))

    # Test different peak types
    for (pt in c("polygon", "point", "rectangle", "none")) {
        p <- gplotChromatogramsOverlay(chr, peakType = pt)
        expect_s3_class(p, "gg")
    }
})

test_that("gplotChromatogramsOverlay works with custom xlim and ylim", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram from one sample
    chr <- chromatogram(xdata[1,], mz = c(305.05, 305.15))

    # Create plot with custom limits
    p <- gplotChromatogramsOverlay(chr, xlim = c(2500, 4000), ylim = c(0, 1e7))

    # Verify output
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
})

test_that("gplotChromatogramsOverlay works with main title", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatograms for one EIC across multiple samples (columns)
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Test with single title (replicated for each sample)
    p1 <- gplotChromatogramsOverlay(chr, main = "Test Title")
    expect_s3_class(p1, "gg")

    # Test with vector of titles (one per sample/column)
    nsam <- ncol(chr)
    titles <- paste("Sample", seq_len(nsam))
    p2 <- gplotChromatogramsOverlay(chr, main = titles)
    expect_s3_class(p2, "gg")
})

test_that("gplotChromatogramsOverlay errors with mismatched main length", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatograms (has 3 samples/columns)
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Should error with wrong number of titles (main should match number of columns, not rows)
    expect_error(
        gplotChromatogramsOverlay(chr, main = c("Title 1", "Title 2")),
        "Length of 'main' must be 1 or equal to number of columns"
    )
})

test_that("gplotChromatogramsOverlay works with MChromatograms", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram from one sample (returns XChromatograms which inherits from MChromatograms)
    chr <- chromatogram(xdata[1,], mz = c(305.05, 305.15))

    # Should work with MChromatograms class
    p <- gplotChromatogramsOverlay(chr)

    # Verify output
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
})

test_that("gplotChromatogramsOverlay works with custom colors", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram from one sample
    chr <- chromatogram(xdata[1,], mz = c(305.05, 305.15))

    # Create plot with custom colors
    p <- gplotChromatogramsOverlay(chr, col = "blue", peakCol = "red", peakBg = "pink")

    # Verify output
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
})
