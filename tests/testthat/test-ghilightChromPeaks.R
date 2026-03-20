test_that("ghighlightChromPeaks requires valid XCMS object", {
    expect_error(
        ghighlightChromPeaks("not an XCMS object", c(2500, 3500), c(200, 600)),
        "unable to find an inherited method"
    )
})

test_that("ghighlightChromPeaks works with XcmsExperiment", {
    layers <- ghighlightChromPeaks(xdata_exp, rt = c(2500, 3500),
                                   mz = c(200, 210))
    expect_type(layers, "list")
    expect_true(inherits(layers[[1L]], "Layer"))
})

test_that("ghighlightChromPeaks works with XCMSnExp", {
    layers <- ghighlightChromPeaks(xdata_snexp, rt = c(2500, 3500),
                                   mz = c(200, 210))
    expect_type(layers, "list")
    expect_true(inherits(layers[[1L]], "Layer"))
})

test_that("ghighlightChromPeaks handles different types", {
    ## Test rect type
    layers_rect <- ghighlightChromPeaks(xdata_exp, rt = c(2500, 3500),
                                        mz = c(200, 210), type = "rect")
    expect_type(layers_rect, "list")

    ## Test point type
    layers_point <- ghighlightChromPeaks(xdata_exp, rt = c(2500, 3500),
                                         mz = c(200, 210), type = "point")
    expect_type(layers_point, "list")
})

test_that("ghighlightChromPeaks handles whichPeaks parameter", {
    layers_any <- ghighlightChromPeaks(xdata_exp, rt = c(2500, 3500),
                                       mz = c(200, 210), whichPeaks = "any")
    expect_type(layers_any, "list")

    layers_within <- ghighlightChromPeaks(xdata_exp, rt = c(2500, 3500),
                                          mz = c(200, 210),
                                          whichPeaks = "within")
    expect_type(layers_within, "list")

    layers_apex <- ghighlightChromPeaks(xdata_exp, rt = c(2500, 3500),
                                        mz = c(200, 210),
                                        whichPeaks = "apex_within")
    expect_type(layers_apex, "list")
})

test_that("ghighlightChromPeaks errors", {
    tmp <- dropChromPeaks(xdata_exp)
    expect_error(
        ghighlightChromPeaks(tmp, rt = c(2500, 3500), mz = c(200, 210)),
        "No chromatographic peaks found"
    )

    expect_error(
        ghighlightChromPeaks(xdata_exp, peakIds = c("a", "b")),
                             "do not match rownames"
    )

    xdata2 <- xdata_exp
    xdata2@chromPeaks <- xdata2@chromPeaks[, colnames(xdata2@chromPeaks) !=
                                             "sample"]
    expect_error(
        ghighlightChromPeaks(xdata2, rt = c(2500, 3500), mz = c(200, 210),
                             whichPeaks = "any", type = "polygon"),
        "Cannot determine sample column")

    expect_error(
        ghighlightChromPeaks(xdata_exp, rt = c(2500, 3500), mz = c(200, 210),
                             whichPeaks = "other", type = "polygon"),
        "should be one of"
    )
    expect_error(
        ghighlightChromPeaks(xdata_exp, rt = c(2500, 3500), mz = c(200, 210),
                             whichPeaks = "any", type = "other"),
        "should be one of"
    )
})
