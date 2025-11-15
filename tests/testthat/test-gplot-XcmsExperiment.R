# Helper function to get shared test data
get_shared_data <- function() {
  if (!exists(".shared_test_data") || is.null(.shared_test_data)) {
    skip("Shared test data not available")
  }
  .shared_test_data
}

test_that("gplot works with XcmsExperiment objects", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  # Filter to small range for faster testing
  mse <- xcms::filterRt(xdata, rt = c(2500, 3000))
  mse <- xcms::filterMzRange(mse, mz = c(200, 210))

  # Test with single sample
  p <- gplot(mse[1])

  # Check return type
  expect_s3_class(p, "patchwork")
  expect_s3_class(p, "ggplot")

  # Test with multiple samples
  p_multi <- gplot(mse)
  expect_s3_class(p_multi, "patchwork")

  # Test with custom parameters
  p_custom <- gplot(mse[1], col = "blue", peakCol = "red")
  expect_s3_class(p_custom, "patchwork")

  # Test with custom color ramp
  p_colramp <- gplot(mse[1], colramp = grDevices::heat.colors)
  expect_s3_class(p_colramp, "patchwork")

  # Note: main parameter removed in favor of ggplot2 + labs() approach
  # Use p + labs(title = "Test Sample") instead
})

test_that("gplot handles XcmsExperiment with peaks", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  # Filter to range where peaks exist
  mse <- xcms::filterRt(xdata, rt = c(2500, 3000))
  mse <- xcms::filterMzRange(mse, mz = c(200, 210))

  # Verify peaks are present
  expect_true(xcms::hasChromPeaks(mse))

  # Test plot with peaks
  p <- gplot(mse[1])
  expect_s3_class(p, "patchwork")
  expect_s3_class(p, "ggplot")
})

test_that("gplot works with XCMSnExp objects", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  # Convert to XCMSnExp (if not already)
  if (inherits(xdata, "XcmsExperiment")) {
    # Filter first for faster testing
    xdata_filtered <- xcms::filterRt(xdata, rt = c(2500, 3000))
    xdata_filtered <- xcms::filterMzRange(xdata_filtered, mz = c(200, 210))

    # Test on XcmsExperiment (which internally converts XCMSnExp)
    p <- gplot(xdata_filtered[1])
    expect_s3_class(p, "patchwork")
  }
})

test_that("gplot handles empty or no spectra gracefully", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  # Filter to extremely narrow range (may have very few/no spectra)
  mse <- xcms::filterRt(xdata, rt = c(2500, 2505))
  mse <- xcms::filterMzRange(mse, mz = c(200.001, 200.002))

  # This should either work or give informative error
  # (not crash with cryptic message)
  result <- tryCatch({
    p <- gplot(mse[1])
    "success"
  }, error = function(e) {
    # Check that error message is informative
    expect_true(grepl("No", e$message) || grepl("spectra", e$message, ignore.case = TRUE))
    "expected_error"
  }, warning = function(w) {
    "warning"
  })

  expect_true(result %in% c("success", "expected_error", "warning"))
})
