# Helper function to get shared test data
# Returns the data loaded once in setup-shared-data.R
get_shared_data <- function() {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MsExperiment")
  skip_if_not_installed("MSnbase")
  skip_if_not_installed("faahKO")

  # Check if shared data exists (loaded in setup-shared-data.R)
  if (!exists(".shared_test_data") || is.null(.shared_test_data)) {
    skip("Shared test data not available")
  }

  .shared_test_data
}

# Helper to prepare object for alignment (group peaks)
prepare_for_alignment <- function(xdata, sample_groups) {
  pdp <- xcms::PeakDensityParam(
    sampleGroups = sample_groups,
    minFraction = 0.4,
    bw = 30
  )
  xcms::groupChromPeaks(xdata, param = pdp)
}

# Helper to perform alignment
perform_alignment <- function(xdata, subset = NULL, filter_files = NULL) {
  # Filter files if requested
  if (!is.null(filter_files)) {
    xdata <- MsExperiment::filterFile(xdata, filter_files)
  }

  # Create PeakGroupsParam with or without subset
  if (!is.null(subset)) {
    pgp <- xcms::PeakGroupsParam(minFraction = 0.4, subset = subset)
  } else {
    pgp <- xcms::PeakGroupsParam(minFraction = 0.4)
  }

  # Perform alignment
  xcms::adjustRtime(xdata, param = pgp)
}

# ---- Basic validation tests ----

test_that("gplotAdjustedRtime requires valid XCMS object", {
  expect_error(
    gplotAdjustedRtime("not an XCMS object"),
    "'object' must be an 'XCMSnExp' or 'XcmsExperiment' object"
  )
})

test_that("gplotAdjustedRtime handles missing color_by gracefully", {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MsExperiment")
  skip_if_not_installed("faahKO")

  # Load minimal data
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)[1:2]

  xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files)
  cwp <- xcms::CentWaveParam(peakwidth = c(20, 80), ppm = 25)
  xdata <- xcms::findChromPeaks(xdata, param = cwp)
  xdata <- xcms::adjustRtime(xdata, param = xcms::PeakGroupsParam(minFraction = 0.4))

  # Test without color_by (should error)
  expect_error(
    gplotAdjustedRtime(xdata),
    "argument \"color_by\" is missing"
  )
})

# ---- Comprehensive combination tests ----
# Test all combinations: (XcmsExperiment, XCMSnExp) × (subset, no subset) × (filterFile, no filterFile)

test_that("gplotAdjustedRtime: XcmsExperiment + no subset + no filterFile", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_exp, data$sample_groups)
  xdata <- perform_alignment(xdata, subset = NULL, filter_files = NULL)

  p <- gplotAdjustedRtime(xdata, color_by = sample_group)
  expect_s3_class(p, "ggplot")

  # Test with explicit column specification
  p2 <- gplotAdjustedRtime(xdata, color_by = sample_group, include_columns = "sample_group")
  expect_s3_class(p2, "ggplot")
})

test_that("gplotAdjustedRtime: XcmsExperiment + no subset + with filterFile", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_exp, data$sample_groups)
  xdata <- perform_alignment(xdata, subset = NULL, filter_files = c(2:5))

  p <- gplotAdjustedRtime(xdata, color_by = sample_group)
  expect_s3_class(p, "ggplot")
})

test_that("gplotAdjustedRtime: XcmsExperiment + with subset + no filterFile", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_exp, data$sample_groups)
  xdata <- perform_alignment(xdata, subset = c(1, 2, 3, 5), filter_files = NULL)

  p <- gplotAdjustedRtime(xdata, color_by = sample_group)
  expect_s3_class(p, "ggplot")
})

test_that("gplotAdjustedRtime: XcmsExperiment + with subset + with filterFile", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_exp, data$sample_groups)
  # Note: Filter first, then subset refers to filtered indices
  xdata_filtered <- MsExperiment::filterFile(xdata, c(1:4))
  xdata_filtered <- perform_alignment(xdata_filtered, subset = c(1, 2), filter_files = NULL)

  p <- gplotAdjustedRtime(xdata_filtered, color_by = sample_group)
  expect_s3_class(p, "ggplot")
})

test_that("gplotAdjustedRtime: XCMSnExp + no subset + no filterFile", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_snexp, data$sample_groups)
  xdata <- perform_alignment(xdata, subset = NULL, filter_files = NULL)

  p <- gplotAdjustedRtime(xdata, color_by = sample_group)
  expect_s3_class(p, "ggplot")

  # Test with explicit column specification
  p2 <- gplotAdjustedRtime(xdata, color_by = sample_group, include_columns = "sample_group")
  expect_s3_class(p2, "ggplot")
})

test_that("gplotAdjustedRtime: XCMSnExp + no subset + with filterFile", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_snexp, data$sample_groups)
  xdata <- perform_alignment(xdata, subset = NULL, filter_files = c(2:5))

  p <- gplotAdjustedRtime(xdata, color_by = sample_group)
  expect_s3_class(p, "ggplot")
})

test_that("gplotAdjustedRtime: XCMSnExp + with subset + no filterFile", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_snexp, data$sample_groups)
  xdata <- perform_alignment(xdata, subset = c(1, 2, 3, 5), filter_files = NULL)

  p <- gplotAdjustedRtime(xdata, color_by = sample_group)
  expect_s3_class(p, "ggplot")
})

test_that("gplotAdjustedRtime: XCMSnExp + with subset + with filterFile", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_snexp, data$sample_groups)
  # Note: Filter first, then subset refers to filtered indices
  xdata_filtered <- MsExperiment::filterFile(xdata, c(1:4))
  xdata_filtered <- perform_alignment(xdata_filtered, subset = c(1, 2), filter_files = NULL)

  p <- gplotAdjustedRtime(xdata_filtered, color_by = sample_group)
  expect_s3_class(p, "ggplot")
})

# ---- Additional structural tests ----

test_that("gplotAdjustedRtime plot has correct structure", {
  data <- get_shared_data()
  xdata <- prepare_for_alignment(data$xdata_exp, data$sample_groups)
  xdata <- perform_alignment(xdata, subset = NULL, filter_files = NULL)

  # Create plot
  p <- gplotAdjustedRtime(xdata, color_by = sample_group)

  # Check plot structure - verify layers exist
  expect_true(length(p$layers) >= 2)

  # Check layer types (order: line, point, line)
  expect_true("GeomLine" %in% class(p$layers[[1]]$geom))
  expect_true("GeomPoint" %in% class(p$layers[[2]]$geom))
  expect_true("GeomLine" %in% class(p$layers[[3]]$geom))
})
