test_that(".validate_xcms_object accepts XcmsExperiment", {
  skip_if_not_installed("MsExperiment")

  # Create a minimal XcmsExperiment
  xdata <- MsExperiment::MsExperiment()

  # Should not throw error
  expect_true(.validate_xcms_object(xdata))
})

test_that(".validate_xcms_object rejects invalid objects", {
  expect_error(
    .validate_xcms_object("not an XCMS object"),
    "'object' must be an 'XCMSnExp' or 'XcmsExperiment' object"
  )

  expect_error(
    .validate_xcms_object(data.frame(x = 1:10)),
    "'object' must be an 'XCMSnExp' or 'XcmsExperiment' object"
  )
})

test_that(".get_sample_data works with XcmsExperiment", {
  skip_if_not_installed("MsExperiment")

  # Create XcmsExperiment with sample data
  xdata <- MsExperiment::MsExperiment()
  sd <- data.frame(
    sample_name = c("sample1", "sample2"),
    sample_group = c("A", "B")
  )
  MsExperiment::sampleData(xdata) <- sd

  # Get sample data
  result <- .get_sample_data(xdata)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true("sample_name" %in% colnames(result))
  expect_true("sample_group" %in% colnames(result))
})

test_that(".get_sample_data works with XCMSnExp", {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MSnbase")
  skip_if_not_installed("faahKO")

  # Load example data to create XCMSnExp
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)
  cdf_files <- cdf_files[1:2]

  pd <- data.frame(
    sample_name = basename(cdf_files),
    sample_group = c("KO", "WT"),
    stringsAsFactors = FALSE
  )

  raw_data <- MSnbase::readMSData(
    files = cdf_files,
    pdata = new("NAnnotatedDataFrame", pd),
    mode = "onDisk"
  )

  # Get sample data
  result <- .get_sample_data(raw_data)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true("sample_name" %in% colnames(result))
  expect_true("sample_group" %in% colnames(result))
})

test_that(".get_sample_data rejects invalid objects", {
  expect_error(
    .get_sample_data("not an XCMS object"),
    "Object must be XcmsExperiment or XCMSnExp"
  )
})
