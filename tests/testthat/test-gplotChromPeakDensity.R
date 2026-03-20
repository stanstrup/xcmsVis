xchr <- chromatogram(xdata_exp, mz = c(305.05, 305.15))
mchr <- chromatogram(as(xdata_exp, "MsExperiment"), mz = c(305.05, 305.15))
xchr_no_peaks <- as(mchr, "XChromatograms")
prm <- PeakDensityParam(sampleGroups = sampleData(xdata_exp)$sample_group,
                        bw = 30)

test_that("gplotChromPeakDensity works with XChromatograms", {
    p <- gplotChromPeakDensity(xchr, param = prm)

    expect_s3_class(p, "patchwork")
    expect_true(inherits(p, "gg"))

    expect_warning(gplotChromPeakDensity(xchr, param = prm, simulate = FALSE),
                   "No feature definitions present")
})

test_that("gplotChromPeakDensity works with correspondence results", {
    tmp <- loadXcmsData()
    chr <- chromatogram(tmp, mz = c(305.07, 305.12))
    ## Works without `param`
    p <- gplotChromPeakDensity(chr)
    expect_s3_class(p, "patchwork")

    p2 <- gplotChromPeakDensity(chr, simulate = FALSE)
    expect_equal(p, p2)

    ## same results as with simulate = TRUE
    prm <- chr@.processHistory[[5]]@param
    chr <- dropFeatureDefinitions(chr)
    p2 <- gplotChromPeakDensity(chr, param = prm)
    expect_equal(p, p2)
    
    expect_error(gplotChromPeakDensity(chr), "is missing")
})

test_that("gplotChromPeakDensity errors without peaks", {
    expect_error(
        gplotChromPeakDensity(xchr_no_peaks, param = prm),
        "No chromatographic peaks present"
    )
})

test_that("gplotChromPeakDensity errors without param", {
    expect_error(gplotChromPeakDensity(xchr), "is missing")
})

test_that("gplotChromPeakDensity errors for multiple rows", {
    tmp <- loadXcmsData()
    chr <- chromatogram(tmp, mz = rbind(c(305.05, 305.15), c(344.0, 344.2)))
    expect_error(gplotChromPeakDensity(chr), "only plotting of a single")    
})

test_that("gplotChromPeakDensity works with different peak types", {
    for (pt in c("polygon", "point", "rectangle", "none")) {
        p <- gplotChromPeakDensity(xchr, param = prm, peakType = pt)
        print(p)
        expect_s3_class(p, "patchwork")
    }
})
