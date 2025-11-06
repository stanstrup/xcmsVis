# Load the package
library(xcmsVis)

# Helper function to get shared test data
# Returns the data loaded once in setup-shared-data.R
get_shared_data <- function() {
    # Check if shared data exists (loaded in setup-shared-data.R)
    if (!exists(".shared_test_data") || is.null(.shared_test_data)) {
        skip("Shared test data not available")
    }
    .shared_test_data
}

# ---- Tests for gplotChromPeaks ----

test_that("gplotChromPeaks requires valid XCMS object", {
    # With S4 methods, invalid objects fail at method dispatch
    expect_error(
        gplotChromPeaks("not an XCMS object"),
        "unable to find an inherited method"
    )
})

test_that("gplotChromPeaks works with XcmsExperiment", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # Should create a plot
    p <- gplotChromPeaks(xdata, file = 1)
    expect_s3_class(p, "ggplot")

    # Test with different parameters
    p2 <- gplotChromPeaks(xdata, file = 1, border = "red", fill = "blue")
    expect_s3_class(p2, "ggplot")
})

test_that("gplotChromPeaks works with XCMSnExp", {
    data <- get_shared_data()
    xdata <- data$xdata_snexp

    # Should create a plot
    p <- gplotChromPeaks(xdata, file = 1)
    expect_s3_class(p, "ggplot")

    # Test with different parameters
    p2 <- gplotChromPeaks(xdata, file = 1, xlim = c(2500, 3500))
    expect_s3_class(p2, "ggplot")
})

test_that("gplotChromPeaks handles xlim and ylim", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # With xlim
    p1 <- gplotChromPeaks(xdata, file = 1, xlim = c(2500, 3500))
    expect_s3_class(p1, "ggplot")

    # With ylim
    p2 <- gplotChromPeaks(xdata, file = 1, ylim = c(200, 600))
    expect_s3_class(p2, "ggplot")

    # With both
    p3 <- gplotChromPeaks(xdata, file = 1, xlim = c(2500, 3500), ylim = c(200, 600))
    expect_s3_class(p3, "ggplot")
})

test_that("gplotChromPeaks errors on invalid file index", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    expect_error(
        gplotChromPeaks(xdata, file = 999),
        "out of range"
    )
})

test_that("gplotChromPeaks handles different files", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # Test multiple files
    p1 <- gplotChromPeaks(xdata, file = 1)
    p2 <- gplotChromPeaks(xdata, file = 2)
    p3 <- gplotChromPeaks(xdata, file = 3)

    expect_s3_class(p1, "ggplot")
    expect_s3_class(p2, "ggplot")
    expect_s3_class(p3, "ggplot")
})

# ---- Tests for gplotChromPeakImage ----

test_that("gplotChromPeakImage requires valid XCMS object", {
    expect_error(
        gplotChromPeakImage("not an XCMS object"),
        "unable to find an inherited method"
    )
})

test_that("gplotChromPeakImage works with XcmsExperiment", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # Default parameters
    p <- gplotChromPeakImage(xdata)
    expect_s3_class(p, "ggplot")

    # With custom binSize
    p2 <- gplotChromPeakImage(xdata, binSize = 60)
    expect_s3_class(p2, "ggplot")

    # With log transform
    p3 <- gplotChromPeakImage(xdata, log_transform = TRUE)
    expect_s3_class(p3, "ggplot")
})

test_that("gplotChromPeakImage works with XCMSnExp", {
    data <- get_shared_data()
    xdata <- data$xdata_snexp

    # Default parameters
    p <- gplotChromPeakImage(xdata)
    expect_s3_class(p, "ggplot")

    # With custom parameters
    p2 <- gplotChromPeakImage(xdata, binSize = 45, xlim = c(2500, 4000))
    expect_s3_class(p2, "ggplot")
})

test_that("gplotChromPeakImage handles xlim", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # With xlim
    p <- gplotChromPeakImage(xdata, xlim = c(2500, 3500))
    expect_s3_class(p, "ggplot")
})

test_that("gplotChromPeakImage creates heatmap structure", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    p <- gplotChromPeakImage(xdata)

    # Check that it has tile geom (for heatmap)
    expect_true(length(p$layers) >= 1)
    expect_true("GeomTile" %in% class(p$layers[[1]]$geom))
})

# ---- Tests for ghighlightChromPeaks ----

test_that("ghighlightChromPeaks requires valid XChromatogram object", {
    expect_error(
        ghighlightChromPeaks("not an XChromatogram", c(2500, 3500), c(200, 600)),
        "unable to find an inherited method"
    )
})

test_that("ghighlightChromPeaks works with XChromatogram from XcmsExperiment", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # Extract chromatogram
    chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

    # Test with rt and mz ranges
    layers <- ghighlightChromPeaks(chr[1, 1], rt = c(2500, 3500), mz = c(200, 210))
    expect_type(layers, "list")
})

test_that("ghighlightChromPeaks works with XChromatogram from XCMSnExp", {
    data <- get_shared_data()
    xdata <- data$xdata_snexp

    # Extract chromatogram
    chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

    # Test with rt and mz ranges
    layers <- ghighlightChromPeaks(chr[1, 1], rt = c(2500, 3500), mz = c(200, 210))
    expect_type(layers, "list")
})

test_that("ghighlightChromPeaks handles different types", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # Extract chromatogram
    chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

    # Test rect type
    layers_rect <- ghighlightChromPeaks(chr[1, 1],
                                        rt = c(2500, 3500), mz = c(200, 210),
                                        type = "rect")
    expect_type(layers_rect, "list")

    # Test point type
    layers_point <- ghighlightChromPeaks(chr[1, 1],
                                         rt = c(2500, 3500), mz = c(200, 210),
                                         type = "point")
    expect_type(layers_point, "list")
})

test_that("ghighlightChromPeaks handles whichPeaks parameter", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # Extract chromatogram
    chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

    # Test different whichPeaks options
    layers_any <- ghighlightChromPeaks(chr[1, 1],
                                       rt = c(2500, 3500), mz = c(200, 210),
                                       whichPeaks = "any")
    expect_type(layers_any, "list")

    layers_within <- ghighlightChromPeaks(chr[1, 1],
                                          rt = c(2500, 3500), mz = c(200, 210),
                                          whichPeaks = "within")
    expect_type(layers_within, "list")

    layers_apex <- ghighlightChromPeaks(chr[1, 1],
                                        rt = c(2500, 3500), mz = c(200, 210),
                                        whichPeaks = "apex_within")
    expect_type(layers_apex, "list")
})

test_that("ghighlightChromPeaks returns empty list when no peaks found", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # Extract chromatogram with range that has no peaks
    chr <- xcms::chromatogram(xdata, mz = c(1, 2), rt = c(1, 2))

    # Use range with no peaks
    layers <- ghighlightChromPeaks(chr[1, 1], rt = c(1, 2), mz = c(1, 2))
    expect_type(layers, "list")
    expect_equal(length(layers), 0)
})
