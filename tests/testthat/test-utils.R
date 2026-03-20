test_that(".validate_xcms_object accepts xcms result objects", {
    expect_no_error(.validate_xcms_object(xdata_exp))
    expect_no_error(.validate_xcms_object(xdata_snexp))
    expect_no_error(.validate_xcms_object(as(xdata_exp, "MsExperiment")))
})

test_that(".validate_xcms_object rejects invalid objects", {
    expect_error(
        .validate_xcms_object("not an XCMS object"),
        "'object' must be an 'XCMSnExp', 'OnDiskMSnExp'."
    )
    expect_error(
        .validate_xcms_object(data.frame(x = 1:10)),
        "'object' must be an 'XCMSnExp', 'OnDiskMSnExp'"
    )
})

test_that(".get_sample_data works with XcmsExperiment", {
    result <- .get_sample_data(xdata_exp)

    expect_s3_class(result, "data.frame")
    ref <- as.data.frame(sampleData(xdata_exp))
    expect_true(all(c("sample_name", "sample_group", "spectraOrigin",
                      "spectraOrigin_base") %in% colnames(result)))
    expect_equal(result$sample_group, ref$sample_group)
    expect_equal(result$sample_name, ref$sample_name)
    expect_equal(result$spectraOrigin, ref$spectraOrigin)
})

test_that(".get_sample_data works with XCMSnExp", {
    tmp <- xdata_snexp
    pData(tmp)$spectraOrigin <- NULL
    result <- .get_sample_data(tmp)

    expect_s3_class(result, "data.frame")
    ref <- pData(tmp)
    expect_true(all(c("sample_name", "sample_group", "spectraOrigin",
                      "spectraOrigin_base") %in% colnames(result)))
    expect_equal(result$sample_group, ref$sample_group)
    expect_equal(result$sample_name, ref$sample_name)
})

test_that(".get_sample_data errors", {
    expect_error(
        .get_sample_data("not an XCMS object"),
        "'object' must be an 'XCMSnExp', 'OnDiskMSnExp'"
    )
    tmp <- xdata_snexp
    pData(tmp)$spectraOrigin <- NULL
    tmp@processingData@files <- character()
    expect_error(.get_sample_data(tmp), "No files defined")
})

test_that(".get_spectra_data works", {
    res <- xcmsVis:::.get_spectra_data(xdata_exp)
    expect_true(is.data.frame(res))
    expect_equal(colnames(res), c("dataOrigin", "spectraOrigin_base",
                                  "rtime", "rtime_adjusted"))
    expect_equal(res$rtime, rtime(spectra(xdata_exp)))
    expect_equal(res$rtime, res$rtime_adjusted)

    res <- xcmsVis:::.get_spectra_data(xdata_snexp)
    expect_true(is.data.frame(res))
    expect_equal(colnames(res), c("dataOrigin", "spectraOrigin_base",
                                  "rtime", "rtime_adjusted"))
    expect_equal(res$rtime, rtime(spectra(xdata_exp)))
    expect_equal(res$rtime, unname(res$rtime_adjusted))

    tmp <- loadXcmsData()
    res <- xcmsVis:::.get_spectra_data(tmp)
    expect_true(is.data.frame(res))
    expect_equal(colnames(res), c("dataOrigin", "spectraOrigin_base",
                                  "rtime", "rtime_adjusted"))
    expect_equal(res$rtime, rtime(spectra(tmp)))
    expect_true(sum(res$rtime != res$rtime_adjusted) > nrow(res) / 2)
})

test_that(".selectively_suppress_warnings works", {
    dummy <- function() warning("Test")
    expect_warning(
        .selectively_suppress_warnings(dummy, pattern = "what")(), "Test")
    expect_no_warning(
        .selectively_suppress_warnings(dummy, pattern = "Test")())
})
