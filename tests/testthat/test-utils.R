test_that(".validate_xcms_object accepts XcmsExperiment", {

  # Create a minimal XcmsExperiment (need to convert from MsExperiment)
  xdata <- as(MsExperiment::MsExperiment(), "XcmsExperiment")

  # Should not throw error (returns invisible(TRUE))
  expect_no_error(.validate_xcms_object(xdata))
})

test_that(".validate_xcms_object rejects invalid objects", {
  expect_error(
    .validate_xcms_object("not an XCMS object"),
    "'object' must be an 'XCMSnExp', 'OnDiskMSnExp' or 'XcmsExperiment' object."
  )

  expect_error(
    .validate_xcms_object(data.frame(x = 1:10)),
    "'object' must be an 'XCMSnExp', 'OnDiskMSnExp' or 'XcmsExperiment' object."
  )
})

test_that(".get_sample_data works with XcmsExperiment", {

  # Load example data to create XcmsExperiment with actual files
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)
  cdf_files <- cdf_files[1:2]

  # Create XcmsExperiment from files
  # Use SerialParam to avoid parallel processing warnings in tests
  xdata <- MsExperiment::readMsExperiment(
    spectraFiles = cdf_files,
    BPPARAM = BiocParallel::SerialParam()
  )
  MsExperiment::sampleData(xdata)$sample_name <- c("sample1", "sample2")
  MsExperiment::sampleData(xdata)$sample_group <- c("KO", "WT")
  xdata <- as(xdata, "XcmsExperiment")

  # Get sample data
  result <- .get_sample_data(xdata)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true("sample_name" %in% colnames(result))
  expect_true("sample_group" %in% colnames(result))
  expect_true("spectraOrigin" %in% colnames(result))
  expect_true("spectraOrigin_base" %in% colnames(result))
})

test_that(".get_sample_data works with XCMSnExp", {

  # Load example data to create XCMSnExp
  cdf_files <- dir(system.file("cdf", package = "faahKO"),
                   recursive = TRUE, full.names = TRUE)
  cdf_files <- cdf_files[c(1:2, 7:8)]

  pd <- data.frame(
    sample_name = basename(cdf_files),
    sample_group = c("KO", "KO", "WT", "WT"),
    stringsAsFactors = FALSE
  )

  raw_data <- MSnbase::readMSData(
    files = cdf_files,
    pdata = new("AnnotatedDataFrame", pd),
    mode = "onDisk"
  )


  # Get sample data
  result <- .get_sample_data(raw_data)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 4)
  expect_true("sample_name" %in% colnames(result))
  expect_true("sample_group" %in% colnames(result))
  expect_true("spectraOrigin" %in% colnames(result))
  expect_true("spectraOrigin_base" %in% colnames(result))
})

test_that(".get_sample_data rejects invalid objects", {
  expect_error(
    .get_sample_data("not an XCMS object"),
    "'object' must be an 'XCMSnExp', 'OnDiskMSnExp' or 'XcmsExperiment' object."
  )
})
