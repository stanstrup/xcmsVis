## Prepare test data
pdp <- PeakDensityParam(sampleGroups = pd$sample_group,
                        minFraction = 0.4, bw = 30)
xdata_exp_grp <- groupChromPeaks(xdata_exp, param = pdp)
pgp <- PeakGroupsParam(minFraction = 0.4)
xdata_exp_algn <- adjustRtime(xdata_exp_grp, pgp)
xdata_snexp_algn <- as(xdata_exp_algn, "XCMSnExp")

## subset-based
pgp <- PeakGroupsParam(minFraction = 0.4, subset = c(1, 2, 3, 5))
xdata_exp_algn_sub <- adjustRtime(xdata_exp_grp, pgp)
xdata_snexp_algn_sub <- as(xdata_exp_algn_sub, "XCMSnExp")

test_that("gplotAdjustedRtime requires valid XCMS object", {
  expect_error(
    gplotAdjustedRtime("not an XCMS object"),
    "unable to find an inherited method"
  )
})

test_that("gplotAdjustedRtime handles missing color_by gracefully", {
    ## Test without color_by (should be fine, all will be grey)
    expect_no_failure(
        gplotAdjustedRtime(xdata_exp_algn)
    )
    expect_no_failure(
        gplotAdjustedRtime(xdata_snexp_algn)
    )
    res <- gplotAdjustedRtime(xdata_exp_algn)
    res_2 <- gplotAdjustedRtime(xdata_snexp_algn)
    expect_equal(res, res_2)
})

## Tests: results same for different xcms objects and parameters work

test_that("gplotAdjustedRtime works", {
    p <- gplotAdjustedRtime(xdata_exp_algn, color_by = sample_group)
    expect_s3_class(p, "ggplot")
    p2 <- gplotAdjustedRtime(xdata_snexp_algn, color_by = sample_group)
    expect_s3_class(p2, "ggplot")
    expect_equal(p, p2)
    
    ## Test with explicit column specification
    p2 <- gplotAdjustedRtime(xdata_exp_algn, color_by = sample_group,
                             include_columns = "sample_group")
    expect_s3_class(p2, "ggplot")

    ## other column for coloring
    sampleData(xdata_exp_algn)$file_idx <- factor(seq_along(xdata_exp_algn))
    p3 <- gplotAdjustedRtime(xdata_exp_algn, color_by = file_idx)
    expect_s3_class(p3, "ggplot")

    expect_warning(gplotAdjustedRtime(xdata_exp), "No alignment")
})

test_that("gplotAdjustedRtime works with subset alignment", {
    p <- gplotAdjustedRtime(xdata_exp_algn_sub, color_by = sample_group)
    expect_s3_class(p, "ggplot")
    p2 <- gplotAdjustedRtime(xdata_snexp_algn_sub, color_by = sample_group)
    expect_s3_class(p2, "ggplot")
    expect_equal(p, p2)
    
    ## Test with explicit column specification
    p2 <- gplotAdjustedRtime(xdata_exp_algn_sub, color_by = sample_group,
                             include_columns = "sample_group")
    expect_s3_class(p2, "ggplot")

    ## other column for coloring
    sampleData(xdata_exp_algn_sub)$file_idx <- factor(seq_along(xdata_exp_algn))
    p3 <- gplotAdjustedRtime(xdata_exp_algn_sub, color_by = file_idx)
    expect_s3_class(p3, "ggplot")
})

test_that("gplotAdjustedRtime plot has correct structure", {
    p <- gplotAdjustedRtime(xdata_exp_algn, color_by = sample_group)

    ## Check plot structure - verify layers exist
    expect_true(length(p$layers) >= 2)

    ## Check layer types (order: line, point, line)
    expect_true("GeomLine" %in% class(p$layers[[1]]$geom))
    expect_true("GeomPoint" %in% class(p$layers[[2]]$geom))
    expect_true("GeomLine" %in% class(p$layers[[3]]$geom))
})
