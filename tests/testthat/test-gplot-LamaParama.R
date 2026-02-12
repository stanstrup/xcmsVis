## Test gplot method for LamaParama objects

## Prepare data; required objects created in testthat.R
pdp <- PeakDensityParam(sampleGroups = pd$sample_group,
                        minFraction = 0.4, bw = 30)
xdata_grouped <- groupChromPeaks(xdata_exp, param = pdp)
xdata_filtered <- filterFeatures(
    xdata_grouped, PercentMissingFilter(threshold = 20, f = pd$sample_group))
fdef_filtered <- featureDefinitions(xdata_filtered)
lamas <- cbind(mz = fdef_filtered$mzmed,
               rt = fdef_filtered$rtmed)
lama_param <- LamaParama(lamas = lamas, method = "loess", span = 0.4)
xdata_algn <- adjustRtime(xdata_grouped, param = lama_param)

test_that("gplot,LamaParama works", {
    prm <- xdata_algn@processHistory[[length(xdata_algn@processHistory)]]@param
    p <- gplot(prm, index = 1)
    expect_s3_class(p, "ggplot")
    expect_true(length(p$layers) >= 2)  # points + line
    geom_classes <- sapply(p$layers, function(l) class(l$geom)[1])
    expect_true("GeomPoint" %in% geom_classes)
    expect_true("GeomLine" %in% geom_classes)
})

test_that("gplot,LamaParama handles custom colors", {
    prm <- xdata_algn@processHistory[[length(xdata_algn@processHistory)]]@param
    p <- gplot(prm, index = 1, colPoints = "red", colFit = "blue")
    expect_s3_class(p, "ggplot")
})

test_that("gplot,LamaParama handles custom labels", {
    prm <- xdata_algn@processHistory[[length(xdata_algn@processHistory)]]@param
    p <- gplot(prm, index = 1) +
         ggplot2::labs(x = "Custom X",
                       y = "Custom Y")
    expect_s3_class(p, "ggplot")
    expect_equal(p$labels$x, "Custom X")
    expect_equal(p$labels$y, "Custom Y")
})

test_that("gplot,LamaParama works with different index values", {
    prm <- xdata_algn@processHistory[[length(xdata_algn@processHistory)]]@param
    p1 <- gplot(prm, index = 1)
    p2 <- gplot(prm, index = 2)
    expect_s3_class(p1, "ggplot")
    expect_s3_class(p2, "ggplot")
    expect_false(identical(p1@layers$geom_point$data, p2@layers$geom_point$data))
    expect_error(p <- gplot(prm, index = 10), "out of bounds")
})
