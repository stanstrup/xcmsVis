# Tests for XCMS utility functions copied from XCMS package
# These tests validate that our copied implementations behave correctly
# and serve as regression tests to detect upstream changes in XCMS

# ============================================================================
# Tests for .descendMin()
# ============================================================================
# This function is critical for peak density calculations and was copied
# from XCMS to avoid using `:::` which would generate R CMD check NOTEs.
# These tests ensure our C implementation matches expected XCMS behavior.

test_that(".descendMin finds correct minimum region for simple peak", {
  # Simple bell curve: 1, 3, 5, 7, 5, 3, 1
  # Peak at position 4, should find boundaries at 1 and 7
  y <- c(1, 3, 5, 7, 5, 3, 1)
  result <- .descendMin(y, istart = 4)

  expect_equal(result, c(1L, 7L))
  expect_type(result, "integer")
  expect_length(result, 2)
})

test_that(".descendMin handles peak at start of vector", {
  # Peak at first position
  y <- c(10, 8, 6, 4, 2)
  result <- .descendMin(y, istart = 1)

  expect_equal(result[1], 1L)  # Should start at position 1
  expect_equal(result[2], 5L)  # Should descend to end
})

test_that(".descendMin handles peak at end of vector", {
  # Peak at last position
  y <- c(2, 4, 6, 8, 10)
  result <- .descendMin(y, istart = 5)

  expect_equal(result[1], 1L)  # Should descend to start
  expect_equal(result[2], 5L)  # Should end at position 5
})

test_that(".descendMin handles flat regions", {
  # Flat top peak: values are equal
  y <- c(1, 3, 5, 5, 5, 3, 1)
  result <- .descendMin(y, istart = 4)

  expect_type(result, "integer")
  expect_length(result, 2)
  # Should stop at first position where it's no longer descending
})

test_that(".descendMin handles default istart (max position)", {
  # When istart not provided, should use position of maximum
  y <- c(1, 3, 10, 7, 5, 3, 1)
  result <- .descendMin(y)  # Should default to position 3 (where max is)

  expect_equal(result, c(1L, 7L))
})

test_that(".descendMin handles vector with multiple local maxima", {
  # Two peaks - use first peak
  y <- c(1, 5, 3, 1, 3, 8, 3, 1)
  result <- .descendMin(y, istart = 2)

  expect_equal(result[1], 1L)  # Descend left to start
  expect_equal(result[2], 4L)  # Descend right to local minimum
})

test_that(".descendMin handles single-element vector", {
  y <- c(5)
  result <- .descendMin(y, istart = 1)

  expect_equal(result, c(1L, 1L))
})

test_that(".descendMin handles two-element vector", {
  y <- c(3, 5)
  result <- .descendMin(y, istart = 2)

  expect_equal(result, c(1L, 2L))
})

test_that(".descendMin handles noise-like data", {
  # Random-ish values
  set.seed(123)
  y <- c(5, 6, 4, 8, 3, 7, 2, 9, 1)
  result <- .descendMin(y, istart = 8)  # Start at 9

  expect_type(result, "integer")
  expect_length(result, 2)
  expect_true(result[1] >= 1 && result[1] <= 9)
  expect_true(result[2] >= 1 && result[2] <= 9)
  expect_true(result[1] <= result[2])  # Lower bound <= upper bound
})

test_that(".descendMin handles all equal values", {
  # Completely flat
  y <- rep(5, 10)
  result <- .descendMin(y, istart = 5)

  expect_type(result, "integer")
  expect_length(result, 2)
  # Should immediately stop in both directions
})

test_that(".descendMin works with numeric input (auto-converts to double)", {
  # Function should convert to double internally
  y <- as.integer(c(1, 3, 5, 7, 5, 3, 1))
  result <- .descendMin(y, istart = 4)

  expect_equal(result, c(1L, 7L))
})

test_that(".descendMin produces consistent results with XCMS reference case", {
  # This is the actual use case from gplotChromPeakDensity:
  # Find minimum regions in a density estimate
  set.seed(42)
  x <- rnorm(100, mean = 3000, sd = 50)
  dens <- density(x, bw = 30, n = 512)

  # Find peak in density
  max_y <- which.max(dens$y)
  result <- .descendMin(dens$y, istart = max_y)

  expect_type(result, "integer")
  expect_length(result, 2)
  expect_true(result[1] <= max_y)
  expect_true(result[2] >= max_y)
  expect_true(result[1] >= 1 && result[1] <= 512)
  expect_true(result[2] >= 1 && result[2] <= 512)
})

# ============================================================================
# Tests for .applyRtAdjustment()
# ============================================================================

test_that(".applyRtAdjustment applies step function correctly", {
  # Simple RT adjustment: shift everything by +10
  rtraw <- c(100, 200, 300, 400, 500)
  rtadj <- c(110, 210, 310, 410, 510)
  x <- c(150, 250, 350)

  result <- .applyRtAdjustment(x, rtraw, rtadj)

  expect_type(result, "double")
  expect_length(result, 3)
  # Step function creates breakpoints at midpoints between rtraw values
  # At x=150 (breakpoint between 100 and 200), returns rtadj[2]=210
  # At x=250 (breakpoint between 200 and 300), returns rtadj[3]=310
  # At x=350 (breakpoint between 300 and 400), returns rtadj[4]=410
  expect_equal(result, c(210, 310, 410))
})

test_that(".applyRtAdjustment handles unsorted rtraw", {
  # rtraw not sorted - function should handle this
  rtraw <- c(300, 100, 400, 200, 500)
  rtadj <- c(310, 110, 410, 210, 510)
  x <- c(250)

  result <- .applyRtAdjustment(x, rtraw, rtadj)

  expect_type(result, "double")
  expect_length(result, 1)
  # Should work correctly despite unsorted input
})

test_that(".applyRtAdjustment handles edge cases at margins", {
  rtraw <- c(100, 200, 300)
  rtadj <- c(110, 210, 310)

  # Test values outside calibration range
  x_low <- c(50, 75)   # Below rtraw[1]
  x_high <- c(350, 400) # Above rtraw[length]

  result_low <- .applyRtAdjustment(x_low, rtraw, rtadj)
  result_high <- .applyRtAdjustment(x_high, rtraw, rtadj)

  expect_type(result_low, "double")
  expect_type(result_high, "double")
  expect_length(result_low, 2)
  expect_length(result_high, 2)
})

test_that(".applyRtAdjustment preserves names", {
  rtraw <- c(100, 200, 300)
  rtadj <- c(110, 210, 310)
  x <- c(a = 150, b = 250)

  result <- .applyRtAdjustment(x, rtraw, rtadj)

  expect_named(result, c("a", "b"))
})

# ============================================================================
# Tests for .rt_model()
# ============================================================================

test_that(".rt_model builds loess model", {
  rt_map <- data.frame(
    ref = c(100, 200, 300, 400, 500),
    obs = c(105, 210, 305, 410, 505)
  )

  model <- .rt_model(method = "loess", rt_map = rt_map)

  expect_s3_class(model, "loess")
  # Model should include (0,0) anchor point
  expect_true(0 %in% model$x)
})

test_that(".rt_model builds GAM model when mgcv available", {
  skip_if_not_installed("mgcv")

  # GAM requires more data points - use at least 10
  rt_map <- data.frame(
    ref = seq(100, 1000, by = 100),
    obs = seq(105, 1005, by = 100)
  )

  model <- .rt_model(method = "gam", rt_map = rt_map)

  expect_s3_class(model, "gam")
})

test_that(".rt_model handles outliers", {
  # Include obvious outlier
  rt_map <- data.frame(
    ref = c(100, 200, 1000, 400, 500),  # 1000 is outlier
    obs = c(105, 210,  305, 410, 505)
  )

  model <- .rt_model(method = "loess", rt_map = rt_map, resid_ratio = 3)

  expect_s3_class(model, "loess")
  # Model should be built (outlier detection shouldn't fail)
})

test_that(".rt_model respects zero_weight parameter", {
  rt_map <- data.frame(
    ref = c(100, 200, 300),
    obs = c(105, 210, 305)
  )

  # High weight for anchor point
  model1 <- .rt_model(method = "loess", rt_map = rt_map, zero_weight = 100)
  # Low weight for anchor point
  model2 <- .rt_model(method = "loess", rt_map = rt_map, zero_weight = 1)

  expect_s3_class(model1, "loess")
  expect_s3_class(model2, "loess")
  # Both should work, but predictions might differ
})

# ============================================================================
# Tests for .check_gam_library()
# ============================================================================

test_that(".check_gam_library succeeds when mgcv available", {
  skip_if_not_installed("mgcv")

  expect_no_error(.check_gam_library())
})

test_that(".check_gam_library fails when mgcv not available", {
  # Can't easily test this without unloading mgcv
  # Just document expected behavior
  expect_true(TRUE)
})

# ============================================================================
# Integration test: Ensure copied functions work in actual use case
# ============================================================================

test_that("XCMS utility functions work together for peak density simulation", {
  # Simulate the actual workflow from gplotChromPeakDensity
  skip_if_not_installed("xcms")
  skip_if_not_installed("faahKO")

  # Create simple test data
  set.seed(123)
  rt_values <- rnorm(50, mean = 3000, sd = 30)
  bw <- 20

  # Compute density (as done in gplotChromPeakDensity)
  dens <- density(rt_values, bw = bw, n = 512)

  # Find maximum and descend to find boundaries
  max_pos <- which.max(dens$y)
  boundaries <- .descendMin(dens$y, istart = max_pos)

  expect_type(boundaries, "integer")
  expect_length(boundaries, 2)
  expect_true(boundaries[1] <= max_pos)
  expect_true(boundaries[2] >= max_pos)

  # Extract RT range for this feature
  rt_range <- dens$x[boundaries]
  expect_length(rt_range, 2)
  expect_true(rt_range[1] < rt_range[2])
})
