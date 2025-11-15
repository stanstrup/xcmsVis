# Test gplot method for LamaParama objects

library(testthat)
library(xcmsVis)
library(xcms)
library(faahKO)
library(MsExperiment)
library(BiocParallel)

# Helper function to get shared test data
get_shared_data <- function() {
  if (!exists(".shared_test_data") || is.null(.shared_test_data)) {
    skip("Shared test data not available")
  }
  .shared_test_data
}

# Helper to get sample groups from xdata object
get_sample_groups <- function(xdata) {
  if (is(xdata, "XcmsExperiment")) {
    MsExperiment::sampleData(xdata)$sample_group
  } else if (is(xdata, "XCMSnExp")) {
    Biobase::pData(xdata)$sample_group
  } else {
    stop("Object must be XcmsExperiment or XCMSnExp")
  }
}

# Helper to prepare object with Lama alignment
# NOTE: LamaParama requires reference dataset with landmarks
# These tests are currently skipped - see vignette for working example
prepare_lama_alignment <- function(xdata) {
  skip("LamaParama tests require reference dataset with landmarks")
}

test_that("gplot works for LamaParama objects", {
  shared <- get_shared_data()

  # Prepare alignment with LamaParama
  result <- prepare_lama_alignment(shared$xdata_experiment)

  # Extract the LamaParama object from the result
  # Note: After adjustRtime, the param is stored in processHistory
  proc_hist <- xcms::processHistory(result$xdata,
                                     type = xcms:::.PROCSTEP.RTIME.CORRECTION)

  if (length(proc_hist) > 0) {
    param <- proc_hist[[length(proc_hist)]]@param

    # Test that param is a LamaParama object
    expect_s4_class(param, "LamaParama")

    # Test that rtMap is populated
    expect_true(length(param@rtMap) > 0)

    # Create plot
    p <- gplot(param, index = 1)

    # Check plot is a ggplot object
    expect_s3_class(p, "ggplot")

    # Check plot has expected layers
    expect_true(length(p$layers) >= 2)  # points + line

    # Check for geom_point and geom_line
    geom_classes <- sapply(p$layers, function(l) class(l$geom)[1])
    expect_true("GeomPoint" %in% geom_classes)
    expect_true("GeomLine" %in% geom_classes)
  } else {
    skip("No alignment results found in processHistory")
  }
})

test_that("gplot LamaParama handles custom colors", {
  shared <- get_shared_data()

  result <- prepare_lama_alignment(shared$xdata_experiment)
  proc_hist <- xcms::processHistory(result$xdata,
                                     type = xcms:::.PROCSTEP.RTIME.CORRECTION)

  if (length(proc_hist) > 0) {
    param <- proc_hist[[length(proc_hist)]]@param

    # Test custom colors
    p <- gplot(param, index = 1,
               colPoints = "red",
               colFit = "blue")

    expect_s3_class(p, "ggplot")
  } else {
    skip("No alignment results found in processHistory")
  }
})

test_that("gplot LamaParama handles custom labels", {
  shared <- get_shared_data()

  result <- prepare_lama_alignment(shared$xdata_experiment)
  proc_hist <- xcms::processHistory(result$xdata,
                                     type = xcms:::.PROCSTEP.RTIME.CORRECTION)

  if (length(proc_hist) > 0) {
    param <- proc_hist[[length(proc_hist)]]@param

    # Test custom labels - use ggplot2 labs() after plot creation
    p <- gplot(param, index = 1) +
         ggplot2::labs(x = "Custom X",
                       y = "Custom Y")

    expect_s3_class(p, "ggplot")
    expect_equal(p$labels$x, "Custom X")
    expect_equal(p$labels$y, "Custom Y")
  } else {
    skip("No alignment results found in processHistory")
  }
})

test_that("gplot LamaParama works with different index values", {
  shared <- get_shared_data()

  result <- prepare_lama_alignment(shared$xdata_experiment)
  proc_hist <- xcms::processHistory(result$xdata,
                                     type = xcms:::.PROCSTEP.RTIME.CORRECTION)

  if (length(proc_hist) > 0) {
    param <- proc_hist[[length(proc_hist)]]@param

    # Test different indices if multiple samples
    n_maps <- length(param@rtMap)
    if (n_maps > 1) {
      p1 <- gplot(param, index = 1)
      p2 <- gplot(param, index = 2)

      expect_s3_class(p1, "ggplot")
      expect_s3_class(p2, "ggplot")

      # Plots should be different (different data)
      expect_false(identical(p1$data, p2$data))
    }
  } else {
    skip("No alignment results found in processHistory")
  }
})
