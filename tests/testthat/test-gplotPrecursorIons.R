library(MsExperiment)
mse <- readMsExperiment(MsDataHub::PestMix1_DDA.mzML())

test_that("gplotPrecursorIons works with DDA data", {
  p <- gplotPrecursorIons(mse)

  ## Check plot is a ggplot object
  expect_s3_class(p, "ggplot")

  ## Check plot has expected layers
  expect_true(length(p$layers) >= 1)  # at least geom_point

  ## Check for geom_point
  geom_classes <- sapply(p$layers, function(l) class(l$geom)[1])
  expect_true("GeomPoint" %in% geom_classes)

  ## Check that plot has title
  expect_true(!is.null(p$labels$title))
})

test_that("gplotPrecursorIons handles custom colors", {
    p <- gplotPrecursorIons(mse, col = "red", bg = "blue")
    
    expect_s3_class(p, "ggplot")
})

test_that("gplotPrecursorIons handles custom labels with ggplot2", {
  ## Test custom labels using ggplot2 labs() function
  p <- gplotPrecursorIons(mse) +
    ggplot2::labs(x = "Custom RT", y = "Custom m/z", title = "Custom Title")

  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "Custom RT")
  expect_equal(p$labels$y, "Custom m/z")
  expect_equal(p$labels$title, "Custom Title")
})

test_that("gplotPrecursorIons handles different point shapes", {
    ## Test different point shapes
    p1 <- gplotPrecursorIons(mse, pch = 21)
    p2 <- gplotPrecursorIons(mse, pch = 16)

    expect_s3_class(p1, "ggplot")
    expect_s3_class(p2, "ggplot")
})

test_that("gplotPrecursorIons returns list for multiple files", {
    fl <- MsDataHub::PestMix1_DDA.mzML()
    mse <- readMsExperiment(c(fl, fl))

    p <- gplotPrecursorIons(mse)

    expect_true(is.list(p))
    expect_s3_class(p[[1L]], "ggplot")  
    expect_s3_class(p[[2L]], "ggplot")
})

test_that("gplotPrecursorIons validates input object", {
    ## Test that function requires MsExperiment object
    ## S4 method dispatch error occurs before function body
    expect_error(
        gplotPrecursorIons("not an MsExperiment"),
        "unable to find an inherited method"
    )
})
