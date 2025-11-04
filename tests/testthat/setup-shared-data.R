# This file runs once before all tests to create shared test data
# The data is stored in the test environment and reused across all tests

# Check if required packages are available
if (requireNamespace("xcms", quietly = TRUE) &&
    requireNamespace("MsExperiment", quietly = TRUE) &&
    requireNamespace("MSnbase", quietly = TRUE) &&
    requireNamespace("faahKO", quietly = TRUE)) {

  # Load example data files
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)
  cdf_files <- cdf_files[c(1:3, 7:9)]  # 6 files total for comprehensive testing

  # Common parameters
  cwp <- xcms::CentWaveParam(peakwidth = c(20, 80), ppm = 25)

  # Create phenodata for both object types
  pd <- data.frame(
    sample_name = basename(cdf_files),
    sample_group = rep(c("KO", "WT"), each = 3),
    stringsAsFactors = FALSE
  )

  # Create XcmsExperiment object
  xdata_exp <- MsExperiment::readMsExperiment(spectraFiles = cdf_files)
  MsExperiment::sampleData(xdata_exp)$sample_name <- pd$sample_name
  MsExperiment::sampleData(xdata_exp)$sample_group <- pd$sample_group

  # Perform peak detection on XcmsExperiment
  xdata_exp <- xcms::findChromPeaks(xdata_exp, param = cwp)


  # Perform peak detection on XCMSnExp
  xdata_snexp <- as(as(xdata_exp, "XcmsExperiment"), "XCMSnExp")

  # Store in global environment for tests to access
  # Note: These will be available to all tests in this session
  .shared_test_data <<- list(
    xdata_exp = xdata_exp,
    xdata_snexp = xdata_snexp,
    sample_groups = pd$sample_group
  )

  message("Shared test data loaded successfully")
} else {
  # If packages aren't available, set to NULL
  # Individual tests will skip appropriately
  .shared_test_data <<- NULL
}
