test_that("gplotAdjustedRtime requires XCMSnExp object", {
  expect_error(
    gplotAdjustedRtime("not an XCMSnExp object"),
    "'object' has to be an 'XCMSnExp' object"
  )
})

test_that("gplotAdjustedRtime warns when no adjustment present", {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MSnbase")

  # This test would require creating a minimal XCMSnExp object
  # without adjustment, which is complex. For now, we skip.
  skip("Requires mock XCMSnExp object")
})

test_that("gplotAdjustedRtime returns ggplot object", {
  skip_if_not_installed("xcms")
  skip_if_not_installed("MSnbase")

  # This test would require a complete XCMSnExp object with
  # retention time adjustment. For now, we skip.
  skip("Requires complete XCMSnExp test data")
})
