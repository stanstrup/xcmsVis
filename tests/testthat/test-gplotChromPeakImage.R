test_that("gplotChromPeakImage requires valid XCMS object", {
    expect_error(
        gplotChromPeakImage("not an XCMS object"),
        "unable to find an inherited method"
    )
})

test_that("gplotChromPeakImage works with XcmsExperiment", {
    p <- gplotChromPeakImage(xdata_exp)
    expect_s3_class(p, "ggplot")

    ## With custom binSize
    p2 <- gplotChromPeakImage(xdata_exp, binSize = 60)
    expect_s3_class(p2, "ggplot")

    ## With log transform
    p3 <- gplotChromPeakImage(xdata_exp, log_transform = TRUE)
    expect_s3_class(p3, "ggplot")
})

test_that("gplotChromPeakImage works with XCMSnExp", {
    ## Default parameters
    p <- gplotChromPeakImage(xdata_snexp)
    expect_s3_class(p, "ggplot")

    ## With custom parameters
    p2 <- gplotChromPeakImage(xdata_snexp, binSize = 45, xlim = c(2500, 4000))
    expect_s3_class(p2, "ggplot")
})

test_that("gplotChromPeakImage handles xlim", {
    ## With xlim
    p <- gplotChromPeakImage(xdata_exp, xlim = c(2500, 3500))
    expect_s3_class(p, "ggplot")
})

test_that("gplotChromPeakImage creates heatmap structure", {
    p <- gplotChromPeakImage(xdata_exp)

    ## Check that it has tile geom (for heatmap)
    expect_true(length(p$layers) >= 1)
    expect_true("GeomTile" %in% class(p$layers[[1]]$geom))
})

test_that("gplotChromPeakImage errors", {
    tmp <- dropChromPeaks(xdata_exp)
    expect_error(gplotChromPeakImage(tmp), "No chromatographic peaks")
})
