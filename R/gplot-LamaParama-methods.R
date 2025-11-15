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
#' \dontrun{
#' library(xcmsVis)
#' library(xcms)
#' library(MsExperiment)
#'
#' # LamaParama requires a reference dataset with landmarks
#' # See vignette("04-retention-time-alignment") for complete workflow
#'
#' # Load reference and test datasets
#' ref <- loadXcmsData("xmse")
#' tst <- loadXcmsData("faahko_sub2")
#'
#' # Extract landmarks from QC samples in reference
#' f <- sampleData(ref)$sample_type
#' f[f != "QC"] <- NA
#' ref_filtered <- filterFeatures(ref, PercentMissingFilter(threshold = 0, f = f))
#' ref_mz_rt <- featureDefinitions(ref_filtered)[, c("mzmed", "rtmed")]
#'
#' # Create and apply LamaParama alignment
#' lama_param <- LamaParama(lamas = ref_mz_rt, method = "loess", span = 0.5)
#' tst_adjusted <- adjustRtime(tst, param = lama_param)
#'
#' # Extract LamaParama result for visualization
#' proc_hist <- processHistory(tst_adjusted, type = xcms:::.PROCSTEP.RTIME.CORRECTION)
#' lama_result <- proc_hist[[length(proc_hist)]]@param
#'
#' # Visualize the first sample's alignment
#' gplot(lama_result, index = 1)
#' }
#'
#' @seealso
#' \code{\link[xcms]{LamaParama}} for the parameter class.
#'
#' @export
#' @rdname gplot
#' @importFrom ggplot2 ggplot aes geom_point geom_line labs theme_bw
#' @importFrom stats predict
#' @importFrom methods is
setMethod("gplot", "LamaParama",
          function(x, index = 1L,
                   colPoints = "#00000060",
                   colFit = "#00000080", ...) {

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
    labs(x = "Matched Chromatographic peaks", y = "Lamas") +
    theme_bw()

  return(p)
})
