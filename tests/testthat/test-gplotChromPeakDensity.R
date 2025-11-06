test_that("gplotChromPeakDensity works with XChromatograms", {
    library(xcms)
    library(ggplot2)

    # Load pre-processed data (much faster than reading files)
    xdata <- loadXcmsData("faahko_sub2")  # XcmsExperiment with peaks

    # Extract chromatogram for a specific m/z range
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Test with PeakDensityParam
    prm <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 30)
    p <- gplotChromPeakDensity(chr, param = prm)

    # Verify output
    expect_s3_class(p, "patchwork")
    expect_true(inherits(p, "gg"))
})

test_that("gplotChromPeakDensity errors without peaks", {
    library(xcms)

    # Create empty XChromatograms without peaks
    chr <- XChromatograms(nrow = 1, ncol = 3)

    prm <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 30)

    expect_error(
        gplotChromPeakDensity(chr, param = prm),
        "No chromatographic peaks present"
    )
})

test_that("gplotChromPeakDensity errors with multiple rows", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatograms for MULTIPLE m/z ranges (multiple rows)
    chr <- chromatogram(xdata, mz = rbind(c(305.05, 305.15), c(344.0, 344.2)))

    prm <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 30)

    expect_error(
        gplotChromPeakDensity(chr, param = prm),
        "only plotting of a single chromatogram"
    )
})

test_that("gplotChromPeakDensity works with simulate = FALSE", {
    library(xcms)

    # Load pre-processed data with full preprocessing
    xdata <- loadXcmsData("xmse")  # Has peaks + alignment + correspondence

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Get param from process history
    ph <- processHistory(xdata, type = "Peak grouping")
    prm <- processParam(ph[[length(ph)]])

    # Plot with simulate = FALSE to show actual grouping
    p <- gplotChromPeakDensity(chr, param = prm, simulate = FALSE)

    # Verify output
    expect_s3_class(p, "patchwork")
    expect_true(inherits(p, "gg"))
})

test_that("gplotChromPeakDensity works with different peak types", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    prm <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 30)

    # Test different peak types
    for (pt in c("polygon", "point", "rectangle", "none")) {
        p <- gplotChromPeakDensity(chr, param = prm, peakType = pt)
        expect_s3_class(p, "patchwork")
    }
})

test_that("gplotChromPeakDensity works with MChromatograms", {
    library(xcms)

    # Load pre-processed data
    xdata <- loadXcmsData("faahko_sub2")

    # Extract chromatogram (returns XChromatograms which inherits from MChromatograms)
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    prm <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 30)
    p <- gplotChromPeakDensity(chr, param = prm)

    # Verify output
    expect_s3_class(p, "patchwork")
    expect_true(inherits(p, "gg"))
})

test_that("gplotChromPeakDensity extracting param from process history works", {
    library(xcms)

    # Load data with correspondence already done
    xdata <- loadXcmsData("xmse")

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Plot without providing param - should extract from process history
    p <- gplotChromPeakDensity(chr)

    # Verify output
    expect_s3_class(p, "patchwork")
    expect_true(inherits(p, "gg"))
})
