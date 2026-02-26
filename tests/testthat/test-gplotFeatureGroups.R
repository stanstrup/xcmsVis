xdata <- loadXcmsData()
library(MsFeatures)
xdata <- groupFeatures(xdata, SimilarRtimeParam())

test_that("gplotFeatureGroups requires valid XCMS object", {
    ## With S4 methods, invalid objects fail at method dispatch
    expect_error(
        gplotFeatureGroups("not an XCMS object"),
        "unable to find an inherited method"
    )
})

test_that("gplotFeatureGroups errors when no feature groups present", {
    ## xdata should not have feature groups (only peaks, no features yet)
    ## The error will come from featureGroups() saying no feature definitions
    expect_error(
        gplotFeatureGroups(xdata_exp),
        "No feature"
    )
    expect_error(gplotFeatureGroups(loadXcmsData()),
                 "No feature groups present")
})

test_that("gplotFeatureGroups works with XcmsExperiment", {
    p <- gplotFeatureGroups(xdata)
    expect_s3_class(p, "ggplot")
})

test_that("gplotFeatureGroups works with XCMSnExp", {
    tmp <- as(xdata, "XCMSnExp")
    
    p <- gplotFeatureGroups(tmp)
    expect_s3_class(p, "ggplot")
})

test_that("gplotFeatureGroups handles xlim and ylim", {
    ## With xlim
    p1 <- gplotFeatureGroups(xdata, xlim = c(2500, 3500))
    expect_s3_class(p1, "ggplot")

    ## With ylim
    p2 <- gplotFeatureGroups(xdata, ylim = c(200, 400))
    expect_s3_class(p2, "ggplot")

    ## With both
    p3 <- gplotFeatureGroups(xdata, xlim = c(2500, 3500), ylim = c(200, 400))
    expect_s3_class(p3, "ggplot")
})

test_that("gplotFeatureGroups handles custom parameters", {
    ## Test custom colors and plotting parameters
    p1 <- gplotFeatureGroups(xdata, col = "red")
    expect_s3_class(p1, "ggplot")

    ## Test custom axis labels - use ggplot2 labs() after plot creation
    p2 <- gplotFeatureGroups(xdata) + ggplot2::labs(x = "RT (sec)",
                                                    y = "Mass/Charge")
    expect_s3_class(p2, "ggplot")

    ## Test custom title - use ggplot2 labs() after plot creation
    p3 <- gplotFeatureGroups(xdata) + ggplot2::labs(title = "Custom Title")
    expect_s3_class(p3, "ggplot")
})

test_that("gplotFeatureGroups handles type parameter", {
    ## Test type = "o" (overplot - both lines and points)
    p1 <- gplotFeatureGroups(xdata, type = "o")
    expect_s3_class(p1, "ggplot")
    expect_true(length(p1$layers) >= 2) # Should have both line and point layers

    ## Test type = "l" (lines only)
    p2 <- gplotFeatureGroups(xdata, type = "l")
    expect_s3_class(p2, "ggplot")

    ## Test type = "p" (points only)
    p3 <- gplotFeatureGroups(xdata, type = "p")
    expect_s3_class(p3, "ggplot")
})

test_that("gplotFeatureGroups handles pch parameter", {
    ## Test different point characters
    p1 <- gplotFeatureGroups(xdata, pch = 16)
    expect_s3_class(p1, "ggplot")

    p2 <- gplotFeatureGroups(xdata, pch = 1)
    expect_s3_class(p2, "ggplot")
})

test_that("gplotFeatureGroups filters to specific feature groups", {
    ## Get all feature group names
    all_fgs <- table(featureGroups(xdata))

    ## Test with subset of feature groups
    p <- gplotFeatureGroups(xdata, featureGroups = names(all_fgs)[1:2])
    expect_s3_class(p, "ggplot")    
})

test_that("gplotFeatureGroups errors on invalid feature groups", {
    ## Test with non-existent feature groups
    expect_error(
        p <- gplotFeatureGroups(xdata, featureGroups = c("A.001", "A.002")),
        "None of the specified feature groups found"
    )
})

test_that("gplotFeatureGroups creates proper plot structure", {
    p <- gplotFeatureGroups(xdata)

    ## Should have both path and point layers (type = "o")
    expect_true(length(p$layers) >= 2)

    ## Check for expected geoms (using GeomPath instead of GeomLine to
    ## preserve data order)
    geom_classes <- sapply(p$layers, function(l) class(l$geom)[1])
    expect_true("GeomPath" %in% geom_classes)
    expect_true("GeomPoint" %in% geom_classes)
})

test_that("gplotFeatureGroups handles empty feature groups parameter", {
    ## Empty featureGroups should plot all groups
    p1 <- gplotFeatureGroups(xdata, featureGroups = character())
    expect_s3_class(p1, "ggplot")

    ## Should be same as not specifying the parameter
    p2 <- gplotFeatureGroups(xdata)
    expect_s3_class(p2, "ggplot")
})
