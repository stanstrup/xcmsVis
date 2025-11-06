#' @include utils.R
NULL

#' ggplot2 Version of plotAdjustedRtime
#'
#' @description
#' Visualizes retention time correction by plotting the difference between
#' adjusted and raw retention times across samples. This is a ggplot2
#' implementation of XCMS's `plotAdjustedRtime()` function, enabling
#' modern visualization and interactive plotting capabilities.
#'
#' @param object An `XCMSnExp` or `XcmsExperiment` object with retention time
#'   adjustment results.
#' @param color_by Column name from sample metadata to use for coloring lines.
#'   This should be provided as an unquoted column name (e.g., `sample_group`).
#'   For XCMSnExp objects, this comes from `pData(object)`. For XcmsExperiment
#'   objects, this comes from `sampleData(object)`.
#' @param include_columns Character vector of column names from sample metadata
#'   to include in the tooltip text. If `NULL` (default), all columns are included.
#' @param adjustedRtime Logical, whether to use adjusted retention times on the
#'   x-axis. Default is `TRUE`.
#'
#' @return A `ggplot` object showing retention time adjustment. Each line
#'   represents one sample, and grey points/lines show the peak groups used
#'   for alignment (when using PeakGroupsParam).
#'
#' @details
#' The function:
#' \itemize{
#'   \item Plots adjusted RT vs. the difference (adjusted RT - raw RT)
#'   \item Shows one line per sample colored by the specified variable
#'   \item Overlays peak groups used for alignment (grey circles and dashed lines)
#'   \item Includes tooltip-ready text for interactive plotting with plotly
#' }
#'
#' The grey circles represent individual peaks that were used for alignment,
#' and the grey dashed lines connect peaks from the same feature across samples.
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#' library(BiocParallel)
#'
#' # Load example data
#' cdf_files <- dir(system.file("cdf", package = "faahKO"),
#'                  recursive = TRUE, full.names = TRUE)[1:3]
#'
#' # Create XcmsExperiment and perform basic workflow
#' xdata <- readMsExperiment(spectraFiles = cdf_files, BPPARAM = SerialParam())
#' MsExperiment::sampleData(xdata)$sample_group <- c("KO", "KO", "WT")
#'
#' # Peak detection
#' cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
#' xdata <- findChromPeaks(xdata, param = cwp, BPPARAM = SerialParam())
#'
#' # Peak grouping
#' pdp <- PeakDensityParam(sampleGroups = c("KO", "KO", "WT"),
#'                         minFraction = 0.4, bw = 30)
#' xdata <- groupChromPeaks(xdata, param = pdp)
#'
#' # Retention time adjustment
#' pgp <- PeakGroupsParam(minFraction = 0.4)
#' xdata <- adjustRtime(xdata, param = pgp)
#'
#' # Create plot
#' p <- gplotAdjustedRtime(xdata, color_by = sample_group)
#' print(p)
#' }
#'
#' @seealso
#' \code{\link[xcms]{plotAdjustedRtime}} for the original XCMS implementation
#'
#' @export
setGeneric("gplotAdjustedRtime", function(object,
                                          color_by,
                                          include_columns = NULL,
                                          adjustedRtime = TRUE)
  standardGeneric("gplotAdjustedRtime"))

#' ggplot2 Version of plotChromPeaks
#'
#' @description
#' Visualizes identified chromatographic peaks as rectangles in the retention
#' time vs. m/z plane. This is a ggplot2 implementation of XCMS's
#' `plotChromPeaks()` function, enabling modern visualization and interactive
#' plotting capabilities.
#'
#' @param object An `XCMSnExp` or `XcmsExperiment` object with detected
#'   chromatographic peaks.
#' @param file Integer specifying which file/sample to plot (default: 1).
#' @param xlim Numeric vector of length 2 specifying retention time range.
#'   If `NULL` (default), uses full retention time range.
#' @param ylim Numeric vector of length 2 specifying m/z range. If `NULL`
#'   (default), uses full m/z range.
#' @param border Color for peak rectangle borders (default: semi-transparent black).
#' @param fill Color for peak rectangle fills (default: NA for no fill).
#' @param msLevel Integer specifying MS level (default: 1).
#'
#' @return A `ggplot` object showing chromatographic peaks as rectangles in
#'   retention time vs. m/z space.
#'
#' @details
#' The function:
#' \itemize{
#'   \item Plots each peak as a rectangle spanning its rt and m/z ranges
#'   \item Uses geom_rect to create the peak rectangles
#'   \item Supports interactive plotting through plotly conversion
#' }
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#' library(BiocParallel)
#'
#' # Load example data
#' cdf_files <- dir(system.file("cdf", package = "faahKO"),
#'                  recursive = TRUE, full.names = TRUE)[1:3]
#'
#' # Create XcmsExperiment and perform peak detection
#' xdata <- readMsExperiment(spectraFiles = cdf_files, BPPARAM = SerialParam())
#' cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
#' xdata <- findChromPeaks(xdata, param = cwp, BPPARAM = SerialParam())
#'
#' # Create plot
#' p <- gplotChromPeaks(xdata, file = 1)
#' print(p)
#' }
#'
#' @seealso
#' \code{\link[xcms]{plotChromPeaks}} for the original XCMS implementation
#'
#' @export
setGeneric("gplotChromPeaks", function(object,
                                       file = 1,
                                       xlim = NULL,
                                       ylim = NULL,
                                       border = "#00000060",
                                       fill = NA,
                                       msLevel = 1L)
  standardGeneric("gplotChromPeaks"))

#' ggplot2 Version of plotChromPeakImage
#'
#' @description
#' Creates an image/heatmap showing the number of detected chromatographic
#' peaks per sample across retention time bins. This is a ggplot2 implementation
#' of XCMS's `plotChromPeakImage()` function.
#'
#' @param object An `XCMSnExp` or `XcmsExperiment` object with detected
#'   chromatographic peaks.
#' @param binSize Numeric value specifying the bin size in seconds for the
#'   retention time axis (default: 30).
#' @param xlim Numeric vector of length 2 specifying retention time range.
#'   If `NULL` (default), uses full retention time range.
#' @param log_transform Logical, whether to log2-transform the peak counts
#'   (default: FALSE).
#' @param msLevel Integer specifying MS level (default: 1).
#'
#' @return A `ggplot` object showing peak counts as a heatmap with retention
#'   time on x-axis, samples on y-axis, and color representing peak density.
#'
#' @details
#' The function:
#' \itemize{
#'   \item Bins peaks across retention time using specified bin size
#'   \item Counts peaks per sample per bin
#'   \item Creates heatmap with color representing peak density
#'   \item Optionally applies log2 transformation to counts
#' }
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#' library(BiocParallel)
#'
#' # Load example data
#' cdf_files <- dir(system.file("cdf", package = "faahKO"),
#'                  recursive = TRUE, full.names = TRUE)[1:3]
#'
#' # Create XcmsExperiment and perform peak detection
#' xdata <- readMsExperiment(spectraFiles = cdf_files, BPPARAM = SerialParam())
#' cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
#' xdata <- findChromPeaks(xdata, param = cwp, BPPARAM = SerialParam())
#'
#' # Create plot
#' p <- gplotChromPeakImage(xdata, binSize = 30)
#' print(p)
#' }
#'
#' @seealso
#' \code{\link[xcms]{plotChromPeakImage}} for the original XCMS implementation
#'
#' @export
setGeneric("gplotChromPeakImage", function(object,
                                           binSize = 30,
                                           xlim = NULL,
                                           log_transform = FALSE,
                                           msLevel = 1L)
  standardGeneric("gplotChromPeakImage"))

#' ggplot2 Version of highlightChromPeaks
#'
#' @description
#' Adds chromatographic peak annotations to existing chromatogram plots.
#' This is a ggplot2 implementation that works with XCMSnExp or XcmsExperiment objects,
#' highlighting detected peaks with rectangles, points, or polygons.
#'
#' @param object An `XCMSnExp` or `XcmsExperiment` object with detected peaks.
#' @param rt Numeric vector of length 2 specifying retention time range for
#'   peak extraction (optional).
#' @param mz Numeric vector of length 2 specifying m/z range for peak extraction (optional).
#' @param peakIds Character vector of peak identifiers (rownames from chromPeaks)
#'   to highlight. If provided, `rt` and `mz` are ignored.
#' @param border Color for peak borders (default: semi-transparent grey).
#' @param fill Color for peak fills (default: NA).
#' @param type Character specifying visualization type: "rect" (rectangle),
#'   "point" (apex point), or "polygon" (peak shape). Default: "rect".
#' @param whichPeaks Character specifying peak selection: "any" (any overlap),
#'   "within" (fully contained), or "apex_within" (apex in range). Default: "any".
#'
#' @return A list of ggplot2 layer objects that can be added to an existing
#'   ggplot chromatogram.
#'
#' @details
#' This function returns ggplot2 layers (geoms) that can be added to an
#' existing chromatogram plot using the `+` operator. Unlike the base R
#' version which modifies an existing plot, this returns composable layers.
#'
#' Like the original `highlightChromPeaks`, this function takes the full
#' XCMSnExp/XcmsExperiment object and searches ALL peaks across all samples,
#' then filters by rt/mz. This means it can highlight peaks from multiple
#' samples. To highlight only peaks from a specific sample, filter the object
#' first using `filterFile()`.
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#' library(ggplot2)
#'
#' # Load and process example data
#' cdf_files <- system.file("cdf/KO/ko15.CDF", package = "faahKO")
#' xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files)
#' xdata <- xcms::findChromPeaks(xdata, param = xcms::CentWaveParam())
#'
#' # Extract chromatogram for plotting
#' chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))
#'
#' # Highlight peaks from the full dataset (all samples in xdata)
#' gplot(chr[1, 1], peakType = "none") +
#'   ghighlightChromPeaks(xdata, rt = c(2500, 3500), mz = c(200, 210))
#'
#' # Or filter to single sample first for cleaner visualization
#' xdata_filtered <- xcms::filterFile(xdata, 1)
#' gplot(chr[1, 1], peakType = "none") +
#'   ghighlightChromPeaks(xdata_filtered, rt = c(2500, 3500), mz = c(200, 210))
#' }
#'
#' @seealso
#' \code{\link[xcms]{highlightChromPeaks}} for the original XCMS implementation
#'
#' @export
setGeneric("ghighlightChromPeaks", function(object,
                                            rt,
                                            mz,
                                            peakIds = character(),
                                            border = "#00000040",
                                            fill = NA,
                                            type = c("rect", "point", "polygon"),
                                            whichPeaks = c("any", "within", "apex_within"))
  standardGeneric("ghighlightChromPeaks"))

#' ggplot2 Version of plot for XChromatogram
#'
#' @description
#' Creates a ggplot2 version of a chromatogram with detected peaks marked.
#' This is equivalent to the base R `plot()` method for XChromatogram objects.
#'
#' @param x An `XChromatogram` or `MChromatograms` object.
#' @param col Color for the chromatogram line (default: "black").
#' @param lty Line type for chromatogram (default: 1).
#' @param type Plot type (default: "l" for line).
#' @param xlab X-axis label (default: "retention time").
#' @param ylab Y-axis label (default: "intensity").
#' @param main Plot title (default: NULL).
#' @param peakType Type of peak annotation: "polygon", "point", "rectangle", or "none"
#'   (default: "polygon").
#' @param peakCol Color for peak markers (default: "#00000060").
#' @param peakBg Background color for peak markers (default: "#00000020").
#' @param peakPch Point character for peak markers when peakType = "point" (default: 1).
#' @param ... Additional arguments (for compatibility with plot).
#'
#' @return A ggplot object.
#'
#' @details
#' This function creates a complete chromatogram plot with detected peaks
#' automatically marked, similar to the base R `plot()` method for
#' XChromatogram objects. If the chromatogram contains detected peaks,
#' they will be shown according to the `peakType` parameter.
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#' library(ggplot2)
#'
#' # Load and process example data
#' cdf_files <- system.file("cdf/KO/ko15.CDF", package = "faahKO")
#' xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files)
#' xdata <- xcms::findChromPeaks(xdata, param = xcms::CentWaveParam())
#'
#' # Extract chromatogram
#' chr <- xcms::chromatogram(xdata, mz = c(200, 210), rt = c(2500, 3500))
#'
#' # Plot with ggplot2
#' gplot(chr[1, 1])
#' }
#'
#' @seealso
#' \code{\link[xcms]{plot,XChromatogram,ANY-method}} for the original XCMS implementation
#'
#' @export
setGeneric("gplot", function(x, ...)
  standardGeneric("gplot"))

#' ggplot2 Version of plotChromPeakDensity
#'
#' @description
#' Visualizes the density of chromatographic peaks along the retention time axis
#' to help evaluate peak density correspondence analysis settings. This is a ggplot2
#' implementation of XCMS's `plotChromPeakDensity()` function.
#'
#' @param object An `XChromatograms` or `MChromatograms` object with detected
#'   chromatographic peaks.
#' @param param A `PeakDensityParam` object defining the peak density correspondence
#'   parameters. If missing, the function will try to extract it from the object's
#'   process history (if correspondence has been performed).
#' @param col Color for the chromatogram lines in the upper panel (default: "#00000060").
#' @param xlab X-axis label (default: "retention time").
#' @param main Plot title (default: NULL).
#' @param peakType Type of peak annotation in upper panel: "polygon", "point",
#'   "rectangle", or "none" (default: "polygon").
#' @param peakCol Color for peak markers (default: "#00000060").
#' @param peakBg Background color for peak markers (default: "#00000020").
#' @param peakPch Point character for peak markers when peakType = "point" (default: 1).
#' @param simulate Logical, whether to simulate correspondence analysis (TRUE) or
#'   display existing results (FALSE). Default: TRUE.
#' @param ... Additional arguments passed to plot methods.
#'
#' @return A ggplot object with two panels:
#'   \itemize{
#'     \item Upper panel: Chromatogram(s) with identified peaks
#'     \item Lower panel: Peak density along retention time axis showing individual
#'           peaks as points (y-axis = sample) with density estimate overlaid as
#'           a line. Grey rectangles indicate peaks grouped into features.
#'   }
#'
#' @details
#' The function creates a two-panel visualization:
#' \itemize{
#'   \item Upper panel shows the chromatographic data with detected peaks
#'   \item Lower panel shows each peak at its retention time (x-axis) and sample (y-axis)
#'   \item A kernel density estimate is shown as a line
#'   \item Grey rectangles indicate peaks that would be (simulate=TRUE) or have been
#'         (simulate=FALSE) grouped into features based on the peak density method
#' }
#'
#' This visualization is particularly useful for optimizing `PeakDensityParam`
#' settings, especially the `bw` (bandwidth) parameter which controls the smoothing
#' of the density estimate.
#'
#' **Note:** Currently only supports plotting a single row (m/z slice) across multiple
#' samples. If `object` has multiple rows, please subset to one row first.
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#' library(BiocParallel)
#'
#' # Load example data
#' cdf_files <- dir(system.file("cdf", package = "faahKO"),
#'                  recursive = TRUE, full.names = TRUE)[1:3]
#'
#' # Create XcmsExperiment and perform peak detection
#' xdata <- readMsExperiment(spectraFiles = cdf_files, BPPARAM = SerialParam())
#' cwp <- CentWaveParam(peakwidth = c(20, 80), ppm = 25)
#' xdata <- findChromPeaks(xdata, param = cwp, BPPARAM = SerialParam())
#'
#' # Extract chromatogram for a specific m/z range
#' chr <- chromatogram(xdata, mz = c(305.05, 305.15))
#'
#' # Visualize peak density with default settings
#' prm <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 30)
#' gplotChromPeakDensity(chr, param = prm)
#'
#' # Try different bandwidth to see effect on peak grouping
#' prm2 <- PeakDensityParam(sampleGroups = rep(1, 3), bw = 60)
#' gplotChromPeakDensity(chr, param = prm2)
#' }
#'
#' @seealso
#' \code{\link[xcms]{plotChromPeakDensity}} for the original XCMS implementation
#'
#' @export
setGeneric("gplotChromPeakDensity", function(object,
                                              param,
                                              col = "#00000060",
                                              xlab = "retention time",
                                              main = NULL,
                                              peakType = c("polygon", "point", "rectangle", "none"),
                                              peakCol = "#00000060",
                                              peakBg = "#00000020",
                                              peakPch = 1,
                                              simulate = TRUE,
                                              ...)
  standardGeneric("gplotChromPeakDensity"))
