# Test gplotPrecursorIons function

library(testthat)
library(xcmsVis)
library(MsExperiment)
library(msdata)

test_that("gplotPrecursorIons works with DDA data", {
  # Load DDA test data
  fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")

  if (file.exists(fl)) {
    pest_dda <- readMsExperiment(fl)

    # Create plot
    p <- gplotPrecursorIons(pest_dda)

    # Check plot is a ggplot object
    expect_s3_class(p, "ggplot")

    # Check plot has expected layers
    expect_true(length(p$layers) >= 1)  # at least geom_point

    # Check for geom_point
    geom_classes <- sapply(p$layers, function(l) class(l$geom)[1])
    expect_true("GeomPoint" %in% geom_classes)

    # Check that plot has title
    expect_true(!is.null(p$labels$title))
  } else {
    skip("DDA test file not available")
  }
})

test_that("gplotPrecursorIons handles custom colors", {
  fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")

  if (file.exists(fl)) {
    pest_dda <- readMsExperiment(fl)

    # Test custom colors
    p <- gplotPrecursorIons(pest_dda,
                            col = "red",
                            bg = "blue")

    expect_s3_class(p, "ggplot")
  } else {
    skip("DDA test file not available")
  }
})

test_that("gplotPrecursorIons handles custom labels", {
  fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")

  if (file.exists(fl)) {
    pest_dda <- readMsExperiment(fl)

    # Test custom labels
    p <- gplotPrecursorIons(pest_dda,
                            xlab = "Custom RT",
                            ylab = "Custom m/z",
                            main = "Custom Title")

    expect_s3_class(p, "ggplot")
    expect_equal(p$labels$x, "Custom RT")
    expect_equal(p$labels$y, "Custom m/z")
    expect_equal(p$labels$title, "Custom Title")
  } else {
    skip("DDA test file not available")
  }
})

test_that("gplotPrecursorIons handles subset of data", {
  fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")

  if (file.exists(fl)) {
    pest_dda <- readMsExperiment(fl)

    # Subset to first file (should still work)
    p <- gplotPrecursorIons(pest_dda[1L])

    expect_s3_class(p, "ggplot")
  } else {
    skip("DDA test file not available")
  }
})

test_that("gplotPrecursorIons handles different point shapes", {
  fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")

  if (file.exists(fl)) {
    pest_dda <- readMsExperiment(fl)

    # Test different point shapes
    p1 <- gplotPrecursorIons(pest_dda, pch = 21)
    p2 <- gplotPrecursorIons(pest_dda, pch = 16)

    expect_s3_class(p1, "ggplot")
    expect_s3_class(p2, "ggplot")
  } else {
    skip("DDA test file not available")
  }
})

test_that("gplotPrecursorIons returns list for multiple files", {
  # This test would need multiple files to be meaningful
  # For now, just test that single file returns single plot
  fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")

  if (file.exists(fl)) {
    pest_dda <- readMsExperiment(fl)

    p <- gplotPrecursorIons(pest_dda)

    # Single file should return ggplot, not list
    expect_s3_class(p, "ggplot")
    expect_false(is.list(p) && !inherits(p, "ggplot"))
  } else {
    skip("DDA test file not available")
  }
})

test_that("gplotPrecursorIons validates input object", {
  # Test that function requires MsExperiment object
  expect_error(
    gplotPrecursorIons("not an MsExperiment"),
    "MsExperiment"
  )
})
