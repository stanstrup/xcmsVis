test_that("gplotChromatogramsOverlay works with single row", {
    library(xcms)
    library(ggplot2)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram for one m/z range (single row)
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Create overlay plot
    p <- gplotChromatogramsOverlay(chr)

    # Verify output
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
})

test_that("gplotChromatogramsOverlay works with multiple rows", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatograms for multiple m/z ranges
    chr <- chromatogram(xdata, mz = rbind(c(305.05, 305.15), c(344.0, 344.2)))

    # Create overlay plot
    p <- gplotChromatogramsOverlay(chr)

    # Should return patchwork object for multiple rows
    expect_s3_class(p, "patchwork")
    expect_true(inherits(p, "gg"))
})

test_that("gplotChromatogramsOverlay works with stacked parameter", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

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

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

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

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

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

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

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

    # Extract chromatograms for multiple rows
    chr <- chromatogram(xdata, mz = rbind(c(305.05, 305.15), c(344.0, 344.2)))

    # Test with single title (replicated)
    p1 <- gplotChromatogramsOverlay(chr, main = "Test Title")
    expect_s3_class(p1, "patchwork")

    # Test with vector of titles
    p2 <- gplotChromatogramsOverlay(chr, main = c("Title 1", "Title 2"))
    expect_s3_class(p2, "patchwork")
})

test_that("gplotChromatogramsOverlay errors with mismatched main length", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatograms for 2 rows
    chr <- chromatogram(xdata, mz = rbind(c(305.05, 305.15), c(344.0, 344.2)))

    # Should error with wrong number of titles
    expect_error(
        gplotChromatogramsOverlay(chr, main = c("Title 1", "Title 2", "Title 3")),
        "Length of 'main' must be 1 or equal to number of rows"
    )
})

test_that("gplotChromatogramsOverlay works with MChromatograms", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram (returns XChromatograms which inherits from MChromatograms)
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

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

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Create plot with custom colors
    p <- gplotChromatogramsOverlay(chr, col = "blue", peakCol = "red", peakBg = "pink")

    # Verify output
    expect_s3_class(p, "gg")
    expect_true(inherits(p, "ggplot"))
})
