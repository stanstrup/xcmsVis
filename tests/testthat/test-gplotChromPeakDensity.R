test_that("gplotChromPeakDensity works with XChromatograms", {
    library(xcms)
    library(faahKO)
    library(MsExperiment)
    library(ggplot2)

    # Load data
    cdf_files <- dir(system.file("cdf", package = "faahKO"),
                     recursive = TRUE, full.names = TRUE)[1:3]
    xdata <- readMsExperiment(spectraFiles = cdf_files)

    # Peak detection
    cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
    xdata <- findChromPeaks(xdata, param = cwp)

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
    library(MsExperiment)

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
    library(faahKO)
    library(MsExperiment)

    # Load data
    cdf_files <- dir(system.file("cdf", package = "faahKO"),
                     recursive = TRUE, full.names = TRUE)[1:3]
    xdata <- readMsExperiment(spectraFiles = cdf_files)

    # Peak detection
    cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
    xdata <- findChromPeaks(xdata, param = cwp)

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
    library(faahKO)
    library(MsExperiment)

    # Load data
    cdf_files <- dir(system.file("cdf", package = "faahKO"),
                     recursive = TRUE, full.names = TRUE)[1:3]
    xdata <- readMsExperiment(spectraFiles = cdf_files)

    # Peak detection
    cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
    xdata <- findChromPeaks(xdata, param = cwp)

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Perform correspondence (peak grouping)
    prm <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 30)
    chr <- groupChromPeaks(chr, param = prm)

    # Plot with simulate = FALSE to show actual grouping
    p <- gplotChromPeakDensity(chr, param = prm, simulate = FALSE)

    # Verify output
    expect_s3_class(p, "patchwork")
    expect_true(inherits(p, "gg"))
})

test_that("gplotChromPeakDensity works with different peak types", {
    library(xcms)
    library(faahKO)
    library(MsExperiment)

    # Load data
    cdf_files <- dir(system.file("cdf", package = "faahKO"),
                     recursive = TRUE, full.names = TRUE)[1:3]
    xdata <- readMsExperiment(spectraFiles = cdf_files)

    # Peak detection
    cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
    xdata <- findChromPeaks(xdata, param = cwp)

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
    library(faahKO)
    library(MsExperiment)

    # Load data
    cdf_files <- dir(system.file("cdf", package = "faahKO"),
                     recursive = TRUE, full.names = TRUE)[1:3]
    xdata <- readMsExperiment(spectraFiles = cdf_files)

    # Peak detection
    cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
    xdata <- findChromPeaks(xdata, param = cwp)

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
    library(faahKO)
    library(MsExperiment)

    # Load data
    cdf_files <- dir(system.file("cdf", package = "faahKO"),
                     recursive = TRUE, full.names = TRUE)[1:3]
    xdata <- readMsExperiment(spectraFiles = cdf_files)

    # Peak detection
    cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
    xdata <- findChromPeaks(xdata, param = cwp)

    # Extract chromatogram
    chr <- chromatogram(xdata, mz = c(305.05, 305.15))

    # Perform correspondence with PeakDensityParam
    prm <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 30)
    chr <- groupChromPeaks(chr, param = prm)

    # Plot without providing param - should extract from process history
    p <- gplotChromPeakDensity(chr)

    # Verify output
    expect_s3_class(p, "patchwork")
    expect_true(inherits(p, "gg"))
})
