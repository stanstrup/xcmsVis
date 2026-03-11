test_that("gplot works with XChromatogram from XcmsExperiment", {
    ## Extract a chromatogram
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3500))

    ## Should create a plot
    p <- gplot(chr[1, 1])
    expect_s3_class(p, "ggplot")

    ## Test with different peakType options
    p_point <- gplot(chr[1, 1], peakType = "point")
    expect_s3_class(p_point, "ggplot")

    p_rect <- gplot(chr[1, 1], peakType = "rectangle")
    expect_s3_class(p_rect, "ggplot")

    p_none <- gplot(chr[1, 1], peakType = "none")
    expect_s3_class(p_none, "ggplot")
})

test_that("gplot works with XChromatogram from XCMSnExp", {
    ## Extract a chromatogram
    chr <- xcms::chromatogram(xdata_snexp, mz = c(200, 210), rt = c(2500, 3500))

    p <- gplot(chr[1, 1])
    expect_s3_class(p, "ggplot")

    ## Test with different parameters
    p2 <- gplot(chr[1, 1], col = "red", peakType = "point")
    expect_s3_class(p2, "ggplot")
})

test_that("gplot handles peakType none", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3500))

    p <- gplot(chr[1, 1], peakType = "none")
    expect_s3_class(p, "ggplot")
})

test_that("gplot handles custom labels and title", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3000))

    p <- gplot(chr[1, 1]) +
        ggplot2::labs(x = "RT (seconds)",
                      y = "Signal",
                      title = "Test Chromatogram")
    expect_s3_class(p, "ggplot")

    ## Check labels are set
    expect_equal(p$labels$x, "RT (seconds)")
    expect_equal(p$labels$y, "Signal")
    expect_equal(p$labels$title, "Test Chromatogram")
})

test_that("gplot handles peak styling parameters", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3000))

    ## Test peak color parameters
    p1 <- gplot(chr[1, 1], peakCol = "red", peakBg = "blue")
    expect_s3_class(p1, "ggplot")

    ## Test point character for point type
    p2 <- gplot(chr[1, 1], peakType = "point", peakPch = 19)
    expect_s3_class(p2, "ggplot")
})

test_that("gplot default peakType is polygon", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3000))

    p <- gplot(chr[1, 1])
    expect_s3_class(p, "ggplot")

    p_poly <- gplot(chr[1, 1], peakType = "polygon")
    expect_s3_class(p_poly, "ggplot")
    expect_equal(p, p_poly)
})

test_that("gplot plot structure is correct", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3000))

    ## Create plot with polygon peaks
    p <- gplot(chr[1, 1], peakType = "polygon")

    ## Check that it has layers (chromatogram line + peaks)
    expect_true(length(p$layers) >= 1)

    ## First layer should be the chromatogram line
    expect_true("GeomLine" %in% class(p$layers[[1]]$geom))
})

test_that("gplot,XChromatograms works", {
    chr <- chromatogram(xdata_exp,
                        mz = rbind(c(200, 210), c(210, 220)),
                        rt = rbind(c(2500, 3000), c(2500, 3000)))
    p <- gplot(chr[1, ])
    expect_s3_class(p, "ggplot")
    expect_warning(p2 <- gplot(chr), "first row")
    expect_equal(p, p2)
})

test_that("gplot,MChromatograms works", {
    chr <- chromatogram(xdata_exp,
                        mz = rbind(c(200, 210), c(210, 220)),
                        rt = rbind(c(2500, 3000), c(2500, 3000)))
    chr <- as(chr, "MChromatograms")
    p <- gplot(chr[1, ])
    expect_s3_class(p, "ggplot")
    expect_warning(p2 <- gplot(chr), "first row")
    expect_equal(p, p2)
})

## --- Color mapping tests ---

test_that("gplot,XChromatograms col mapping by pData column", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3500))

    ## Static color (default behavior unchanged)
    p_static <- gplot(chr, col = "red")
    expect_s3_class(p_static, "ggplot")
    expect_false("colour" %in% names(p_static$mapping))

    ## Column mapping via quoted string
    p_mapped <- gplot(chr, col = "sample_group")
    expect_s3_class(p_mapped, "ggplot")
    expect_true("colour" %in% names(p_mapped$mapping))

    ## Verify pData was joined (sample_group should be in the plot data)
    plot_data <- ggplot2::ggplot_build(p_mapped)$data[[1]]
    expect_true(length(unique(plot_data$colour)) > 1)
})

test_that("gplot,XChromatograms peakCol/peakBg mapping", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3500))

    ## peakCol mapping with point type
    p_point <- gplot(chr, col = "sample_group",
                     peakCol = "sample_group", peakType = "point")
    expect_s3_class(p_point, "ggplot")
    expect_true(length(p_point$layers) >= 2)

    ## peakBg mapping with polygon type
    p_poly <- gplot(chr, col = "sample_group",
                    peakBg = "sample_group", peakType = "polygon")
    expect_s3_class(p_poly, "ggplot")

    ## peakBg mapping with rectangle type
    p_rect <- gplot(chr, col = "sample_group",
                    peakBg = "sample_group", peakType = "rectangle")
    expect_s3_class(p_rect, "ggplot")
})

test_that("gplot,MChromatograms col mapping by pData column", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3500))
    chr_m <- as(chr, "MChromatograms")

    ## Static color (unchanged)
    p_static <- gplot(chr_m, col = "red")
    expect_s3_class(p_static, "ggplot")
    expect_false("colour" %in% names(p_static$mapping))

    ## Column mapping
    p_mapped <- gplot(chr_m, col = "sample_group")
    expect_s3_class(p_mapped, "ggplot")
    expect_true("colour" %in% names(p_mapped$mapping))
})

test_that("gplot color mapping with variable passthrough", {
    chr <- chromatogram(xdata_exp, mz = c(200, 210), rt = c(2500, 3500))

    ## A variable holding a static color should still work
    my_color <- "blue"
    p <- gplot(chr, col = my_color)
    expect_s3_class(p, "ggplot")
    expect_false("colour" %in% names(p$mapping))
})
