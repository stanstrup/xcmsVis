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
#' xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files,
#'                                         BPPARAM = BiocParallel::SerialParam())
#' xdata <- xcms::findChromPeaks(xdata, param = xcms::CentWaveParam(),
#'                                BPPARAM = BiocParallel::SerialParam())
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
#' xdata <- MsExperiment::readMsExperiment(spectraFiles = cdf_files,
#'                                         BPPARAM = BiocParallel::SerialParam())
#' xdata <- xcms::findChromPeaks(xdata, param = xcms::CentWaveParam(),
#'                                BPPARAM = BiocParallel::SerialParam())
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
                                              peakType = c("polygon", "point", "rectangle", "none"),
                                              peakCol = "#00000060",
                                              peakBg = "#00000020",
                                              peakPch = 1,
                                              simulate = TRUE,
                                              ...)
  standardGeneric("gplotChromPeakDensity"))

#' ggplot2 Version of plotChromatogramsOverlay
#'
#' @description
#' Creates overlay plots of multiple chromatograms, with one plot per row in
#' the `XChromatograms` or `MChromatograms` object. Each plot overlays all samples (columns)
#' for that m/z slice (row). This is a ggplot2 implementation of XCMS's
#' `plotChromatogramsOverlay()` function, enabling modern visualization and
#' interactive plotting capabilities.
#'
#' @param object An `XChromatograms` or `MChromatograms` object.
#' @param col Color for the chromatogram lines (default: "#00000060").
#' @param type Plot type (default: "l" for line).
#' @param main Character vector of panel titles, one per row. If NULL (default), no titles are used.
#'   If length 1, the same title is used for all panels. Use `+ labs()` for ggplot2-style customization.
#' @param xlim Numeric vector of length 2 specifying retention time range.
#'   Default: numeric() (auto-calculate). Use `+ labs()` to customize axis labels and titles.
#' @param ylim Numeric vector of length 2 specifying intensity range.
#'   Default: numeric() (auto-calculate).
#' @param peakType Type of peak annotation: "polygon", "point", "rectangle", or "none"
#'   (default: "polygon").
#' @param peakBg Background color for peak markers (default: NULL, uses peakCol with transparency).
#' @param peakCol Color for peak markers (default: NULL, uses col).
#' @param peakPch Point character for peak markers when peakType = "point" (default: 1).
#' @param stacked Numeric value for stacking offset. If > 0, chromatograms will be
#'   offset vertically by this amount for visual separation (default: 0).
#' @param transform Function to transform intensity values (default: identity).
#'   Useful for log-transformations or other intensity scaling.
#' @param ... Additional arguments (for compatibility).
#'
#' @return If the object has one row: a single ggplot object.
#'   If the object has multiple rows: a patchwork object combining multiple ggplot objects.
#'
#' @details
#' This function creates overlay plots where all samples (columns) in a given
#' m/z slice (row) are overlaid in a single plot. If the object contains multiple
#' rows, each row gets its own panel stacked vertically using patchwork.
#'
#' The function differs from `gplot` for XChromatograms in that:
#' \itemize{
#'   \item It explicitly handles multiple rows (whereas gplot warns and uses only the first)
#'   \item It supports `stacked` parameter for vertical offset
#'   \item It supports `transform` parameter for intensity transformations
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
#' # Extract chromatograms for multiple m/z ranges
#' chr <- chromatogram(xdata, mz = rbind(c(305.05, 305.15), c(344.0, 344.2)))
#'
#' # Create overlay plot for all rows
#' gplotChromatogramsOverlay(chr)
#'
#' # With stacked offset for visual separation
#' gplotChromatogramsOverlay(chr, stacked = 1e6)
#'
#' # With log transformation
#' gplotChromatogramsOverlay(chr, transform = log1p)
#' }
#'
#' @seealso
#' \code{\link[xcms]{plotChromatogramsOverlay}} for the original XCMS implementation
#' \code{\link{gplot}} for single-row overlay plots
#'
#' @export
setGeneric("gplotChromatogramsOverlay", function(object,
                                                  col = "#00000060",
                                                  type = "l",
                                                  main = NULL,
                                                  xlim = numeric(),
                                                  ylim = numeric(),
                                                  peakType = c("polygon", "point", "rectangle", "none"),
                                                  peakBg = NULL,
                                                  peakCol = NULL,
                                                  peakPch = 1,
                                                  stacked = 0,
                                                  transform = identity,
                                                  ...)
  standardGeneric("gplotChromatogramsOverlay"))

#' ggplot2 Version of plotFeatureGroups
#'
#' @description
#' Visualizes feature groups by plotting features connected across retention time
#' and m/z dimensions. This is a ggplot2 implementation of XCMS's `plotFeatureGroups()`
#' function, enabling modern visualization and interactive plotting capabilities.
#'
#' @param x An `XCMSnExp` or `XcmsExperiment` object with feature grouping results.
#' @param xlim Numeric vector of length 2 specifying retention time range.
#'   Default: numeric() (auto-calculate from data).
#' @param ylim Numeric vector of length 2 specifying m/z range.
#'   Default: numeric() (auto-calculate from data).
#' @param pch Point character for feature markers (default: 4).
#' @param col Color for feature points and connecting lines (default: "#00000060").
#' @param type Plot type (default: "o" for overplotted points and lines).
#' @param featureGroups Character vector of feature group identifiers to plot.
#'   If empty (default), all feature groups are plotted.
#' @param ... Additional arguments passed to geom functions.
#'
#' @return A ggplot object showing features connected by lines within each
#'   feature group across retention time and m/z dimensions.
#'
#' @details
#' The function:
#' \itemize{
#'   \item Extracts feature definitions and their grouping information
#'   \item Plots each feature as a point at (rtmed, mzmed)
#'   \item Connects features within the same group with lines
#'   \item Feature groups are created by `groupFeatures()` which identifies
#'         features that likely represent the same compound (isotopes, adducts, etc.)
#' }
#'
#' Feature groups must be present in the object before calling this function.
#' Run `groupFeatures()` first to create feature groups based on retention time,
#' m/z relationships, or other criteria.
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#' library(BiocParallel)
#' library(MsFeatures)
#'
#' # Load example data
#' cdf_files <- dir(system.file("cdf", package = "faahKO"),
#'                  recursive = TRUE, full.names = TRUE)[1:3]
#'
#' # Create XcmsExperiment and perform complete workflow
#' xdata <- readMsExperiment(spectraFiles = cdf_files, BPPARAM = SerialParam())
#' xdata <- findChromPeaks(xdata, param = CentWaveParam(), BPPARAM = SerialParam())
#' xdata <- groupChromPeaks(xdata, param = PeakDensityParam(
#'   sampleGroups = rep(1, 3), minFraction = 0.5))
#'
#' # Disable parallel processing to avoid warnings
#' register(SerialParam())
#' xdata <- adjustRtime(xdata, param = ObiwarpParam())
#' xdata <- groupChromPeaks(xdata, param = PeakDensityParam(
#'   sampleGroups = rep(1, 3), minFraction = 0.5))
#'
#' # Group features (identify related features like isotopes/adducts)
#' xdata <- groupFeatures(xdata, param = SimilarRtimeParam())
#'
#' # Visualize feature groups
#' gplotFeatureGroups(xdata)
#'
#' # Visualize specific feature groups only
#' gplotFeatureGroups(xdata, featureGroups = c("FG.0001", "FG.0002"))
#' }
#'
#' @seealso
#' \code{\link[xcms:plotFeatureGroups]{xcms::plotFeatureGroups()}} for the original XCMS implementation.
#' See \code{MsFeatures::groupFeatures()} for creating feature groups.
#'
#' @export
setGeneric("gplotFeatureGroups", function(x,
                                          xlim = numeric(),
                                          ylim = numeric(),
                                          pch = 4,
                                          col = "#00000060",
                                          type = "o",
                                          featureGroups = character(),
                                          ...)
  standardGeneric("gplotFeatureGroups"))

#' ggplot2 Version of plotPrecursorIons
#'
#' @description
#' Creates a ggplot2 version of precursor ion visualization for MsExperiment objects.
#' This function plots the m/z and retention time of all precursor ions in MS2 spectra,
#' useful for visualizing DDA (Data-Dependent Acquisition) data.
#'
#' @param object An `MsExperiment` object containing MS/MS data.
#' @param pch Point shape for precursor ions (default: 21 = filled circle).
#' @param col Point color (default: semi-transparent black).
#' @param bg Point background/fill color (default: very transparent black).
#' @param ... Additional arguments passed to ggplot2 functions.
#'
#' @return A ggplot object (or list of ggplot objects if multiple files).
#'   Use `+ labs()` to customize axis labels and titles.
#'
#' @details
#' This function visualizes the precursor ions selected for fragmentation in MS/MS experiments.
#' Each point represents a precursor ion, with:
#' \itemize{
#'   \item X-axis: Retention time of the MS2 spectrum
#'   \item Y-axis: Precursor m/z value
#' }
#'
#' For MsExperiment objects with multiple files, separate plots are created for each file.
#'
#' The plot range includes all MS1 data to provide context, but only shows precursor ions
#' from MS2 spectra.
#'
#' Default labels are provided ("retention time", "m/z"), but can be customized using
#' ggplot2's `labs()` function, e.g., `gplotPrecursorIons(x) + labs(x = "RT (s)")`.
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(MsExperiment)
#' library(ggplot2)
#'
#' ## Load a test data file with DDA LC-MS/MS data
#' fl <- system.file("TripleTOF-SWATH", "PestMix1_DDA.mzML", package = "msdata")
#' pest_dda <- readMsExperiment(fl)
#'
#' gplotPrecursorIons(pest_dda)
#'
#' ## Customize labels with ggplot2
#' gplotPrecursorIons(pest_dda) + labs(x = "RT (s)", y = "Precursor m/z", title = "DDA Analysis")
#'
#' ## Subset the data object to plot the data specifically for one or
#' ## selected file/sample:
#' gplotPrecursorIons(pest_dda[1L])
#' }
#'
#' @seealso
#' \code{\link[xcms]{plotPrecursorIons}} for the original XCMS implementation.
#'
#' @export
setGeneric("gplotPrecursorIons", function(object,
                                          pch = 21,
                                          col = "#00000080",
                                          bg = "#00000020", ...)
  standardGeneric("gplotPrecursorIons"))
