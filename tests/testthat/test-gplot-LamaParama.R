# Test gplot method for LamaParama objects

library(testthat)
library(xcmsVis)
library(xcms)
library(faahKO)
library(MsExperiment)
library(BiocParallel)
library(MsFeatures)

# Helper function to get shared test data
get_shared_data <- function() {
  if (!exists(".shared_test_data") || is.null(.shared_test_data)) {
    skip("Shared test data not available")
  }
  .shared_test_data
}

# Helper to perform peak grouping (required before LamaParama alignment)
perform_grouping <- function(xdata, sample_groups) {
  pdp <- xcms::PeakDensityParam(
    sampleGroups = sample_groups,
    minFraction = 0.4,
    bw = 30
  )
  xcms::groupChromPeaks(xdata, param = pdp)
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
# Following the pipeline from step4-retention-time-alignment.qmd vignette
prepare_lama_alignment <- function(xdata) {
  # Load MsFeatures for filtering
  if (!requireNamespace("MsFeatures", quietly = TRUE)) {
    skip("MsFeatures package required for LamaParama tests")
  }

  # Filter to high-quality features present in most samples
  # Using PercentMissingFilter to keep only features found in at least 80% of samples
  # Note: filterFeatures is a generic S4 method made available by MsFeatures
  xdata_filtered <- filterFeatures(
    xdata,
    MsFeatures::PercentMissingFilter(
      threshold = 20,  # Allow max 20% missing
      f = if (is(xdata, "XcmsExperiment")) {
        MsExperiment::sampleData(xdata)$sample_group
      } else {
        Biobase::pData(xdata)$sample_group
      }
    )
  )

  # Extract filtered feature definitions to use as landmarks
  fdef_filtered <- xcms::featureDefinitions(xdata_filtered)

  # Check if we have enough features to create landmarks
  if (nrow(fdef_filtered) < 3) {
    skip("Not enough features for LamaParama alignment (need at least 3)")
  }

  # Create landmark matrix (mz and rt columns) from the subset
  lamas <- cbind(
    mz = fdef_filtered$mzmed,
    rt = fdef_filtered$rtmed
  )

  # Create LamaParama object
  lama_param <- xcms::LamaParama(
    lamas = lamas,
    method = "loess",
    span = 0.4
  )

  # Perform alignment on the original (unfiltered) data using the landmark subset
  xdata_aligned <- xcms::adjustRtime(xdata, param = lama_param)

  return(list(
    xdata = xdata_aligned,
    lama_param = lama_param,
    n_landmarks = nrow(lamas),
    n_total_features = nrow(xcms::featureDefinitions(xdata))
  ))
}

test_that("gplot works for LamaParama objects with XcmsExperiment", {
  shared <- get_shared_data()

  # Group peaks first (required for LamaParama)
  xdata_grouped <- perform_grouping(shared$xdata_exp, shared$sample_groups)

  # Prepare alignment with LamaParama
  result <- prepare_lama_alignment(xdata_grouped)

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

test_that("gplot works for LamaParama objects with XCMSnExp", {
  shared <- get_shared_data()

  # Group peaks first (required for LamaParama)
  xdata_grouped <- perform_grouping(shared$xdata_snexp, shared$sample_groups)

  # Prepare alignment with LamaParama
  result <- prepare_lama_alignment(xdata_grouped)

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

  # Group peaks first (required for LamaParama)
  xdata_grouped <- perform_grouping(shared$xdata_exp, shared$sample_groups)

  result <- prepare_lama_alignment(xdata_grouped)
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

  # Group peaks first (required for LamaParama)
  xdata_grouped <- perform_grouping(shared$xdata_exp, shared$sample_groups)

  result <- prepare_lama_alignment(xdata_grouped)
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

  # Group peaks first (required for LamaParama)
  xdata_grouped <- perform_grouping(shared$xdata_exp, shared$sample_groups)

  result <- prepare_lama_alignment(xdata_grouped)
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
