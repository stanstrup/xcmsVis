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

# Helper function to create test data with feature groups
# Feature groups require: peak detection, grouping, RT alignment, re-grouping, then groupFeatures
create_feature_groups_data <- function(xdata) {
    # Need to run full workflow for feature grouping
    # This helper is used when shared data doesn't have feature groups

    # Run full workflow
    # 1. findChromPeaks (should already be done)
    if (!xcms::hasChromPeaks(xdata)) {
        xdata <- xcms::findChromPeaks(xdata, param = xcms::CentWaveParam())
    }

    # 2. groupChromPeaks (create features)
    xdata <- xcms::groupChromPeaks(xdata,
                                   param = xcms::PeakDensityParam(
                                       sampleGroups = rep(1, length(xcms::fileNames(xdata))),
                                       minFraction = 0.5, bw = 30))

    # 3. adjustRtime
    if (!xcms::hasAdjustedRtime(xdata)) {
        xdata <- xcms::adjustRtime(xdata, param = xcms::ObiwarpParam())
    }

    # 4. groupChromPeaks again (post-alignment)
    xdata <- xcms::groupChromPeaks(xdata,
                                   param = xcms::PeakDensityParam(
                                       sampleGroups = rep(1, length(xcms::fileNames(xdata))),
                                       minFraction = 0.5, bw = 30))

    # 5. groupFeatures (create feature groups)
    # Note: groupFeatures is from MsFeatures package, not xcms
    xdata <- MsFeatures::groupFeatures(xdata, param = MsFeatures::SimilarRtimeParam())

    return(xdata)
}

# ---- Tests for gplotFeatureGroups ----

test_that("gplotFeatureGroups requires valid XCMS object", {
    # With S4 methods, invalid objects fail at method dispatch
    expect_error(
        gplotFeatureGroups("not an XCMS object"),
        "unable to find an inherited method"
    )
})

test_that("gplotFeatureGroups errors when no feature groups present", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # xdata should not have feature groups (only peaks, no features yet)
    # The error will come from featureGroups() saying no feature definitions
    expect_error(
        gplotFeatureGroups(xdata),
        "No feature"
    )
})

test_that("gplotFeatureGroups works with XcmsExperiment", {
    data <- get_shared_data()
    xdata <- data$xdata_exp

    # Add feature groups
    xdata <- create_feature_groups_data(xdata)

    # Should create a plot
    p <- gplotFeatureGroups(xdata)
    expect_s3_class(p, "ggplot")
})

test_that("gplotFeatureGroups works with XCMSnExp", {
    data <- get_shared_data()
    xdata <- data$xdata_snexp

    # Add feature groups
    xdata <- create_feature_groups_data(xdata)

    # Should create a plot
    p <- gplotFeatureGroups(xdata)
    expect_s3_class(p, "ggplot")
})

test_that("gplotFeatureGroups handles xlim and ylim", {
    data <- get_shared_data()
    xdata <- data$xdata_exp
    xdata <- create_feature_groups_data(xdata)

    # With xlim
    p1 <- gplotFeatureGroups(xdata, xlim = c(2500, 3500))
    expect_s3_class(p1, "ggplot")

    # With ylim
    p2 <- gplotFeatureGroups(xdata, ylim = c(200, 600))
    expect_s3_class(p2, "ggplot")

    # With both
    p3 <- gplotFeatureGroups(xdata, xlim = c(2500, 3500), ylim = c(200, 600))
    expect_s3_class(p3, "ggplot")
})

test_that("gplotFeatureGroups handles custom parameters", {
    data <- get_shared_data()
    xdata <- data$xdata_exp
    xdata <- create_feature_groups_data(xdata)

    # Test custom colors and plotting parameters
    p1 <- gplotFeatureGroups(xdata, col = "red")
    expect_s3_class(p1, "ggplot")

    # Test custom axis labels - use ggplot2 labs() after plot creation
    p2 <- gplotFeatureGroups(xdata) + ggplot2::labs(x = "RT (sec)", y = "Mass/Charge")
    expect_s3_class(p2, "ggplot")

    # Test custom title - use ggplot2 labs() after plot creation
    p3 <- gplotFeatureGroups(xdata) + ggplot2::labs(title = "Custom Title")
    expect_s3_class(p3, "ggplot")
})

test_that("gplotFeatureGroups handles type parameter", {
    data <- get_shared_data()
    xdata <- data$xdata_exp
    xdata <- create_feature_groups_data(xdata)

    # Test type = "o" (overplot - both lines and points)
    p1 <- gplotFeatureGroups(xdata, type = "o")
    expect_s3_class(p1, "ggplot")
    expect_true(length(p1$layers) >= 2)  # Should have both line and point layers

    # Test type = "l" (lines only)
    p2 <- gplotFeatureGroups(xdata, type = "l")
    expect_s3_class(p2, "ggplot")

    # Test type = "p" (points only)
    p3 <- gplotFeatureGroups(xdata, type = "p")
    expect_s3_class(p3, "ggplot")
})

test_that("gplotFeatureGroups handles pch parameter", {
    data <- get_shared_data()
    xdata <- data$xdata_exp
    xdata <- create_feature_groups_data(xdata)

    # Test different point characters
    p1 <- gplotFeatureGroups(xdata, pch = 16)
    expect_s3_class(p1, "ggplot")

    p2 <- gplotFeatureGroups(xdata, pch = 1)
    expect_s3_class(p2, "ggplot")
})

test_that("gplotFeatureGroups filters to specific feature groups", {
    data <- get_shared_data()
    xdata <- data$xdata_exp
    xdata <- create_feature_groups_data(xdata)

    # Get all feature group names
    all_fgs <- levels(factor(xcms::featureGroups(xdata)))

    # Test with subset of feature groups
    if (length(all_fgs) >= 2) {
        selected_fgs <- all_fgs[1:2]
        p <- gplotFeatureGroups(xdata, featureGroups = selected_fgs)
        expect_s3_class(p, "ggplot")
    }
})

test_that("gplotFeatureGroups errors on invalid feature groups", {
    data <- get_shared_data()
    xdata <- data$xdata_exp
    xdata <- create_feature_groups_data(xdata)

    # Test with non-existent feature groups
    expect_error(
        gplotFeatureGroups(xdata, featureGroups = c("NONEXISTENT.001", "NONEXISTENT.002")),
        "None of the specified feature groups found"
    )
})

test_that("gplotFeatureGroups creates proper plot structure", {
    data <- get_shared_data()
    xdata <- data$xdata_exp
    xdata <- create_feature_groups_data(xdata)

    # Create plot with default type="o"
    p <- gplotFeatureGroups(xdata)

    # Should have both path and point layers (type = "o")
    expect_true(length(p$layers) >= 2)

    # Check for expected geoms (using GeomPath instead of GeomLine to preserve data order)
    geom_classes <- sapply(p$layers, function(l) class(l$geom)[1])
    expect_true("GeomPath" %in% geom_classes)
    expect_true("GeomPoint" %in% geom_classes)
})

test_that("gplotFeatureGroups handles empty feature groups parameter", {
    data <- get_shared_data()
    xdata <- data$xdata_exp
    xdata <- create_feature_groups_data(xdata)

    # Empty featureGroups should plot all groups
    p1 <- gplotFeatureGroups(xdata, featureGroups = character())
    expect_s3_class(p1, "ggplot")

    # Should be same as not specifying the parameter
    p2 <- gplotFeatureGroups(xdata)
    expect_s3_class(p2, "ggplot")
})
