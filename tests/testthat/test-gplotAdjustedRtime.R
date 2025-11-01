test_that("gplotAdjustedRtime requires valid XCMS object", {
  expect_error(
    gplotAdjustedRtime("not an XCMS object"),
    "'object' must be an 'XCMSnExp' or 'XcmsExperiment' object"
  )
})

test_that("gplotAdjustedRtime works with XcmsExperiment", {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MsExperiment")
  skip_if_not_installed("faahKO")

  # Load example data
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)
  cdf_files <- cdf_files[1:2]  # Use only 2 files for speed

  # Create XcmsExperiment object
  xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files)
  MsExperiment::sampleData(xdata)$sample_group <- c("KO", "WT")

  # Perform peak detection
  cwp <- xcms::CentWaveParam(peakwidth = c(20, 80), ppm = 25)
  xdata <- xcms::findChromPeaks(xdata, param = cwp)

  # Perform retention time adjustment
  xdata <- xcms::adjustRtime(
    xdata,
    param = xcms::PeakGroupsParam(minFraction = 0.4)
  )

  # Test that function returns ggplot
  p <- gplotAdjustedRtime(xdata, color_by = sample_group)
  expect_s3_class(p, "ggplot")

  # Test with explicit column specification
  p2 <- gplotAdjustedRtime(xdata, color_by = sample_group,
                           include_columns = "sample_group")
  expect_s3_class(p2, "ggplot")
})

test_that("gplotAdjustedRtime works with XCMSnExp", {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MSnbase")
  skip_if_not_installed("faahKO")

  # Load example data
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)
  cdf_files <- cdf_files[1:2]  # Use only 2 files for speed

  # Create phenodata
  pd <- data.frame(
    sample_name = basename(cdf_files),
    sample_group = c("KO", "WT"),
    stringsAsFactors = FALSE
  )

  # Create XCMSnExp object
  raw_data <- MSnbase::readMSData(
    files = cdf_files,
    pdata = new("NAnnotatedDataFrame", pd),
    mode = "onDisk"
  )

  # Perform peak detection
  cwp <- xcms::CentWaveParam(peakwidth = c(20, 80), ppm = 25)
  xdata <- xcms::findChromPeaks(raw_data, param = cwp)

  # Perform retention time adjustment
  xdata <- xcms::adjustRtime(
    xdata,
    param = xcms::PeakGroupsParam(minFraction = 0.4)
  )

  # Test that function returns ggplot
  p <- gplotAdjustedRtime(xdata, color_by = sample_group)
  expect_s3_class(p, "ggplot")

  # Test with explicit column specification
  p2 <- gplotAdjustedRtime(xdata, color_by = sample_group,
                           include_columns = "sample_group")
  expect_s3_class(p2, "ggplot")
})

test_that("gplotAdjustedRtime handles missing color_by gracefully", {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MsExperiment")
  skip_if_not_installed("faahKO")

  # Load example data
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)
  cdf_files <- cdf_files[1:2]

  # Create XcmsExperiment object
  xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files)

  # Perform peak detection and RT adjustment
  cwp <- xcms::CentWaveParam(peakwidth = c(20, 80), ppm = 25)
  xdata <- xcms::findChromPeaks(xdata, param = cwp)
  xdata <- xcms::adjustRtime(
    xdata,
    param = xcms::PeakGroupsParam(minFraction = 0.4)
  )

  # Test without color_by (should work with default coloring)
  expect_error(
    gplotAdjustedRtime(xdata),
    "argument \"color_by\" is missing"
  )
})

test_that("gplotAdjustedRtime plot has correct structure", {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MsExperiment")
  skip_if_not_installed("faahKO")

  # Load example data
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)
  cdf_files <- cdf_files[1:2]

  # Create XcmsExperiment object
  xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files)
  MsExperiment::sampleData(xdata)$sample_group <- c("KO", "WT")

  # Perform peak detection and RT adjustment
  cwp <- xcms::CentWaveParam(peakwidth = c(20, 80), ppm = 25)
  xdata <- xcms::findChromPeaks(xdata, param = cwp)
  xdata <- xcms::adjustRtime(
    xdata,
    param = xcms::PeakGroupsParam(minFraction = 0.4)
  )

  # Create plot
  p <- gplotAdjustedRtime(xdata, color_by = sample_group)

  # Check plot structure
  expect_true("GeomPoint" %in% class(p$layers[[1]]$geom))
  expect_true("GeomLine" %in% class(p$layers[[2]]$geom))

  # Check that data has expected columns
  plot_data <- p$data
  expect_true("rtime_adjusted" %in% colnames(plot_data))
  expect_true("rt_deviation" %in% colnames(plot_data))
  expect_true("tooltip_text" %in% colnames(plot_data))
})
