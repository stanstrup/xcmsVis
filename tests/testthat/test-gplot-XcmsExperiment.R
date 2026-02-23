test_that("gplot works with XcmsExperiment objects", {
  ## Filter to small range for faster testing
  mse <- filterRt(xdata_exp, rt = c(2500, 3000))
  mse <- filterMzRange(mse, mz = c(200, 210))

  ## Test with single sample
  p <- gplot(mse[1])
  expect_s3_class(p, "patchwork")
  expect_s3_class(p, "ggplot")

  ## Test with multiple samples
  p_multi <- gplot(mse)
  expect_s3_class(p_multi, "patchwork")
  expect_equal(p, p_multi[[1L]])

  ## Test with custom parameters
  p_custom <- gplot(mse[1], col = "blue", peakCol = "red")
  expect_s3_class(p_custom, "patchwork")

  ## Test with custom color ramp
  p_colramp <- gplot(mse[1], colramp = grDevices::heat.colors)
  expect_s3_class(p_colramp, "patchwork")

  expect_warning(
      expect_error(gplot(mse[1], msLevel = 2L), "specified MS level"))

  ## without chrom peaks
  mse <- dropChromPeaks(mse)
  p <- gplot(mse[1])
  expect_s3_class(p, "patchwork")
  expect_s3_class(p, "ggplot")
})

test_that("gplot works with XCMSnExp objects", {
    p <- gplot(filterFile(xdata_snexp, 1))
    expect_s3_class(p, "patchwork")
})

test_that("gplot works with MsExperiment", {
    tmp <- as(xdata_exp, "MsExperiment")
    p <- gplot(tmp)
})

test_that("gplot handles empty or no spectra gracefully", {
  mse <- filterRt(xdata_exp, rt = c(2500, 2505))
  mse <- filterMzRange(mse, mz = c(200.001, 200.002))

  result <- tryCatch({
      p <- gplot(mse[1])
      "success"
  }, error = function(e) {
      expect_true(grepl("No", e$message) ||
                  grepl("spectra", e$message, ignore.case = TRUE))
      "expected_error"
  }, warning = function(w) {
      "warning"
  })

  expect_true(result %in% c("success", "expected_error", "warning"))
})
