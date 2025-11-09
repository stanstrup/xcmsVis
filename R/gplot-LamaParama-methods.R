#' @include AllGenerics.R
NULL

#' ggplot2 Version of plot for LamaParama
#'
#' @description
#' Creates a ggplot2 version of the retention time alignment model visualization for LamaParama objects.
#' LamaParama objects contain parameters and results from landmark-based retention time alignment.
#'
#' @param x A `LamaParama` object containing retention time alignment parameters and results.
#' @param index Integer specifying which retention time map to plot (default: 1).
#' @param colPoints Color for the matched peak points (default: semi-transparent black).
#' @param colFit Color for the fitted model line (default: semi-transparent black).
#' @param xlab X-axis label (default: "Matched Chromatographic peaks").
#' @param ylab Y-axis label (default: "Lamas").
#' @param ... Additional parameters (currently unused, for S4 compatibility).
#'
#' @return A ggplot object.
#'
#' @details
#' This function visualizes the retention time alignment model for a specific sample.
#' The plot shows:
#' \itemize{
#'   \item Points representing matched chromatographic peaks between the sample and reference
#'   \item A fitted line (loess or GAM) showing the retention time correction model
#' }
#'
#' The LamaParama object contains parameters for landmark-based alignment including:
#' \itemize{
#'   \item `method`: The fitting method ("loess" or "gam")
#'   \item `span`: Span parameter for loess fitting
#'   \item `outlierTolerance`: Tolerance for outlier detection
#'   \item `zeroWeight`: Weight for the (0,0) anchor point
#'   \item `bs`: Basis function for GAM fitting
#'   \item `rtMap`: List of data frames with retention time pairs
#' }
#'
#' @examples
#' \donttest{
#' library(xcmsVis)
#' library(xcms)
#' library(faahKO)
#' library(MsExperiment)
#'
#' # Load example data
#' fls <- dir(system.file("cdf/KO", package = "faahKO"), full.names = TRUE)[1:3]
#' xdata <- readMsExperiment(fls, BPPARAM = SerialParam())
#'
#' # Perform peak detection
#' xdata <- findChromPeaks(xdata, param = CentWaveParam(), BPPARAM = SerialParam())
#' xdata <- groupChromPeaks(xdata, param = PeakDensityParam(sampleGroups = rep(1, 3)))
#'
#' # Get alignment parameters with landmark alignment
#' param <- LamaParama(tolerance = 50)
#' # Note: LamaParama needs to be run via adjustRtime to populate rtMap
#' # This example shows the structure but may not run without proper setup
#'
#' # Visualize the first alignment
#' # gplot(param, index = 1)
#' }
#'
#' @seealso
#' \code{\link[xcms]{LamaParama}} for the parameter class.
#'
#' @export
#' @rdname gplot
#' @importFrom ggplot2 ggplot aes geom_point geom_line labs theme_bw
#' @importFrom methods is
setMethod("gplot", "LamaParama",
          function(x, index = 1L,
                   colPoints = "#00000060",
                   colFit = "#00000080",
                   xlab = "Matched Chromatographic peaks",
                   ylab = "Lamas", ...) {

  # Get the retention time model using XCMS internal function
  model <- xcms:::.rt_model(method = x@method,
                            rt_map = x@rtMap[[index]],
                            span = x@span,
                            resid_ratio = x@outlierTolerance,
                            zero_weight = x@zeroWeight,
                            bs = x@bs)

  # Get the data points
  datap <- x@rtMap[[index]]

  # Create data frame for points
  point_data <- data.frame(
    obs = datap[, 2L],
    ref = datap[, 1L]
  )

  # Create data frame for fitted line
  obs_range <- range(point_data$obs)
  fit_obs <- seq(obs_range[1], obs_range[2], length.out = 100)
  fit_ref <- predict(model, newdata = data.frame(obs = fit_obs))
  line_data <- data.frame(
    obs = fit_obs,
    ref = fit_ref
  )

  # Create ggplot
  p <- ggplot() +
    geom_point(data = point_data, aes(x = obs, y = ref),
               color = colPoints) +
    geom_line(data = line_data, aes(x = obs, y = ref),
              color = colFit) +
    labs(x = xlab, y = ylab) +
    theme_bw()

  return(p)
})
