test_that("gplotChromPeaks requires valid XCMS object", {
    expect_error(
        gplotChromPeaks("not an XCMS object"),
        "unable to find an inherited method"
    )
})

test_that("gplotChromPeaks works with XcmsExperiment", {
    p <- gplotChromPeaks(xdata_exp, file = 1)
    expect_s3_class(p, "ggplot")

    p2 <- gplotChromPeaks(xdata_exp, file = 1, border = "red", fill = "blue")
    expect_s3_class(p2, "ggplot")
})

test_that("gplotChromPeaks works with XCMSnExp", {
    p <- gplotChromPeaks(xdata_snexp, file = 1)
    expect_s3_class(p, "ggplot")

    p2 <- gplotChromPeaks(xdata_snexp, file = 1, xlim = c(2500, 3500))
    expect_s3_class(p2, "ggplot")
})

test_that("gplotChromPeaks handles xlim and ylim", {
    p1 <- gplotChromPeaks(xdata_exp, file = 1, xlim = c(2500, 3500))
    expect_s3_class(p1, "ggplot")

    p2 <- gplotChromPeaks(xdata_exp, file = 1, ylim = c(200, 600))
    expect_s3_class(p2, "ggplot")

    p3 <- gplotChromPeaks(xdata_exp, file = 1, xlim = c(2500, 3500),
                          ylim = c(200, 600))
    expect_s3_class(p3, "ggplot")
})

test_that("gplotChromPeaks errors on invalid file index", {
    expect_error(
        gplotChromPeaks(xdata_exp, file = 999),
        "out of range"
    )
})

test_that("gplotChromPeaks errors without chrom peaks", {
    tmp <- dropChromPeaks(xdata_exp)
    expect_error(gplotChromPeaks(tmp), "No chromatographic")
})

test_that("gplotChromPeaks handles different files", {
    p1 <- gplotChromPeaks(xdata_exp, file = 1)
    p2 <- gplotChromPeaks(xdata_exp, file = 2)
    p3 <- gplotChromPeaks(xdata_exp, file = 3)

    expect_s3_class(p1, "ggplot")
    expect_s3_class(p2, "ggplot")
    expect_s3_class(p3, "ggplot")
})
