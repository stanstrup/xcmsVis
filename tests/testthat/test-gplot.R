# Load the package
library(xcmsVis)

# Helper function to get shared test data
# Returns the data loaded once in setup-shared-data.R
get_shared_data <- function() {
  # Check if shared data exists (loaded in setup-shared-data.R)
  if (!exists(".shared_test_data") || is.null(.shared_test_data)) {
    skip("Shared test data not available")
  }
  .shared_test_data
}

# ---- Tests for gplot() ----

test_that("gplot requires valid XChromatogram object", {
  # With S4 methods, invalid objects fail at method dispatch
  expect_error(
    gplot("not an XChromatogram"),
    "unable to find an inherited method"
  )
})

test_that("gplot works with XChromatogram from XcmsExperiment", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  # Extract a chromatogram
  chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

  # Should create a plot
  p <- gplot(chr[1, 1])
  expect_s3_class(p, "ggplot")

  # Test with different peakType options
  p_point <- gplot(chr[1, 1], peakType = "point")
  expect_s3_class(p_point, "ggplot")

  p_rect <- gplot(chr[1, 1], peakType = "rectangle")
  expect_s3_class(p_rect, "ggplot")

  p_none <- gplot(chr[1, 1], peakType = "none")
  expect_s3_class(p_none, "ggplot")
})

test_that("gplot works with XChromatogram from XCMSnExp", {
  data <- get_shared_data()
  xdata <- data$xdata_snexp

  # Extract a chromatogram
  chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

  # Should create a plot
  p <- gplot(chr[1, 1])
  expect_s3_class(p, "ggplot")

  # Test with different parameters
  p2 <- gplot(chr[1, 1], col = "red", peakType = "point")
  expect_s3_class(p2, "ggplot")
})

test_that("gplot handles chromatograms without peaks", {
  data <- get_shared_data()

  # Get data without peak detection by loading raw
  xdata_no_peaks <- MsExperiment::readMsExperiment(
    spectraFiles = system.file("cdf/KO/ko15.CDF", package = "faahKO")
  )

  # Extract chromatogram (no peaks detected)
  chr <- xcms::chromatogram(xdata_no_peaks, mz = c(200, 210), rt = c(2500, 3500))

  # Should still create a plot (just the chromatogram, no peaks)
  p <- gplot(chr[1, 1])
  expect_s3_class(p, "ggplot")
})

test_that("gplot handles custom labels and title", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

  # Custom labels
  p <- gplot(chr[1, 1],
             xlab = "RT (seconds)",
             ylab = "Signal",
             main = "Test Chromatogram")
  expect_s3_class(p, "ggplot")

  # Check labels are set
  expect_equal(p$labels$x, "RT (seconds)")
  expect_equal(p$labels$y, "Signal")
  expect_equal(p$labels$title, "Test Chromatogram")
})

test_that("gplot handles peak styling parameters", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

  # Test peak color parameters
  p1 <- gplot(chr[1, 1], peakCol = "red", peakBg = "blue")
  expect_s3_class(p1, "ggplot")

  # Test point character for point type
  p2 <- gplot(chr[1, 1], peakType = "point", peakPch = 19)
  expect_s3_class(p2, "ggplot")
})

test_that("gplot default peakType is polygon", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

  # Default should create plot (polygon is default)
  p <- gplot(chr[1, 1])
  expect_s3_class(p, "ggplot")

  # Should be equivalent to explicit polygon
  p_poly <- gplot(chr[1, 1], peakType = "polygon")
  expect_s3_class(p_poly, "ggplot")
})

test_that("gplot plot structure is correct", {
  data <- get_shared_data()
  xdata <- data$xdata_exp

  chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))

  # Create plot with polygon peaks
  p <- gplot(chr[1, 1], peakType = "polygon")

  # Check that it has layers (chromatogram line + peaks)
  expect_true(length(p$layers) >= 1)

  # First layer should be the chromatogram line
  expect_true("GeomLine" %in% class(p$layers[[1]]$geom))
})
