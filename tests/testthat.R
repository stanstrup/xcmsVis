library(testthat)
library(xcmsVis)

## Create test data available to all unit tests
library(MSnbase)
library(xcms)
library(MsExperiment)

cdf_files <- dir(system.file("cdf", package = "faahKO"),
                 recursive = TRUE, full.names = TRUE)
cdf_files <- cdf_files[c(1:3, 7:9)]
pd <- data.frame(
    sample_name = basename(cdf_files),
    sample_group = rep(c("KO", "WT"), each = 3)
)

xdata_exp <- readMsExperiment(spectraFiles = cdf_files, sampleData = pd) |>
    findChromPeaks(param = CentWaveParam(peakwidth = c(20, 80), ppm = 25))
xdata_snexp <- as(as(xdata_exp, "XcmsExperiment"), "XCMSnExp")

test_check("xcmsVis")
