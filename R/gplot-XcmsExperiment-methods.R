#' @include AllGenerics.R
NULL

#' @title *ggplot2* Version of `plot()` for `XcmsExperiment` and `XCMSnExp`
#'
#' @description
#'
#' Creates a two-panel visualization of MS data showing:
#'
#' - Upper panel: Base Peak Intensity (BPI) chromatogram vs retention time
#'
#' - Lower panel: m/z vs retention time scatter plot with intensity-based
#'   coloring
#'
#' This is a *ggplot2* implementation of *xcms*'s `plot()` method for
#' `MsExperiment` objects, enabling modern visualization and interactive
#' plotting capabilities.
#'
#' @param x `XcmsExperiment` or `XCMSnExp` object
#'
#' @param msLevel `integer(1)` defining the MS level to visualize (default: `1`)
#'
#' @param peakCol `character(1)` color to indicate identified chromatographic
#'     peaks (default: `"#ff000060"`)
#'
#' @param col `character(1)` color for point borders (default: `"grey"`)
#'
#' @param colramp function color ramp for intensity mapping (default:
#'     `grDevices::topo.colors`)
#'
#' @param pch `integer(1)` point shape (default: `21` = filled circle)
#'
#' @param ... additional arguments (for compatibility)
#'
#' @return A `ggplot` or patchwork object showing the two-panel visualization.
#'   For single samples, returns a patchwork object with two panels.
#'   For multiple samples, returns a patchwork object with all sample plots
#'   stacked. Use `+ labs()` to customize axis labels and titles.
#'
#' @details
#'
#' The function:
#'
#' - Extracts spectra data filtered by MS level
#'
#' - Applies adjusted retention times if available
#'
#' - Upper panel: plots BPI (max intensity per retention time) with
#'   intensity-colored points
#'
#' - Lower panel: plots m/z vs retention time scatter with intensity-colored
#'   points
#'
#' - Overlays detected chromatographic peaks as rectangles (if available)
#'
#' - Uses consistent color scale across both panels based on intensity
#'
#' @examples
#' library(xcmsVis)
#' library(xcms)
#' library(MsExperiment)
#'
#' # Load and filter data
#' xmse <- loadXcmsData()
#' xmse <- filterRt(xmse, rt = c(2620, 2740)) |>
#'         filterMzRange(mz = c(342, 344))
#'
#' # Plot MS data
#' gplot(xmse[1L])
#'
#' # Multiple samples
#' gplot(xmse[1:3])
#'
#' @seealso
#'
#' \code{\link[xcms]{plot,MsExperiment,missing-method}} for the original
#' *xcms* implementation
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_rect scale_fill_gradientn
#' @importFrom ggplot2 labs theme_bw theme element_blank coord_cartesian margin
#' @importFrom patchwork plot_layout wrap_plots
#' @importFrom xcms hasAdjustedRtime applyAdjustedRtime chromPeaks hasChromPeaks
#' @importFrom dplyr group_by summarize
#' @importFrom methods as is
#' @importFrom grDevices topo.colors
#' @importFrom MsExperiment sampleData
#' @importFrom ProtGenerics spectra filterMsLevel rtime
#'
#' @rdname gplot-XcmsExperiment
#'
#' @export
setMethod("gplot", "XcmsExperiment",
          function(x, msLevel = 1L, peakCol = "#ff000060",
                   col = "grey", colramp = grDevices::topo.colors,
                   pch = 21, ...) {
              if (hasAdjustedRtime(x))
                  x <- applyAdjustedRtime(x)
              ## Extract peak information per sample
              pkl <- NULL
              if (hasChromPeaks(x)) {
                  pkl <- chromPeaks(x, msLevel = msLevel)
                  if (nrow(pkl) > 0) {
                      pkl <- split.data.frame(
                          pkl,
                          factor(pkl[, "sample"], levels = seq_along(x))
                      )
                  } else {
                      pkl <- NULL
                  }
              }
              ## Convert to MsExperiment for data extraction
              mse <- as(x, "MsExperiment")
              ## Get sample names for default titles
              fns <- sampleData(mse)$spectraOrigin
              if (is.null(fns) || length(fns) == 0)
                  fns <- paste("Sample", seq_along(mse))
              else
                  fns <- basename(fns)
              plot_list <- list()
              for (i in seq_along(mse)) {
                  z <- mse[i]
                  ## Extract and filter spectra
                  flt <- filterMsLevel(spectra(z), msLevel = msLevel)
                  ## Skip if no spectra
                  if (length(flt) == 0) {
                      warning("No spectra found for sample ", i,
                              " at MS level ", msLevel)
                      next
                  }
                  lst <- as(flt, "list")
                  lns <- lengths(lst) / 2
                  lst <- do.call(rbind, lst)
                  df <- data.frame(
                      rt = rep(rtime(flt), lns),
                      lst
                  )
                  colnames(df)[colnames(df) == "intensity"] <- "i"
                  ## Get peaks for this sample
                  pks <- NULL
                  if (!is.null(pkl) && length(pkl) >= i && !is.null(pkl[[i]]))
                      pks <- pkl[[i]]
                  ## Create two-panel plot for this sample
                  p <- .create_sample_plot(df, pks, main = fns[i],
                                           col = col, colramp = colramp,
                                           pch = pch, peakCol = peakCol, ...)
                  plot_list[[i]] <- p
              }
              ## Combine all sample plots vertically
              if (length(plot_list) == 0) {
                  stop("No plots could be created. Check that data exists ",
                       "for the specified MS level.", call. = FALSE)
              } else if (length(plot_list) == 1) {
                  return(plot_list[[1]])
              } else {
                  return(wrap_plots(plot_list, ncol = 1))
              }
          })

#' @rdname gplot-XcmsExperiment
#'
#' @export
setMethod("gplot", "XCMSnExp",
          function(x, msLevel = 1L, peakCol = "#ff000060",
                   col = "grey", colramp = grDevices::topo.colors,
                   pch = 21, ...) {
              xdata <- as(x, "XcmsExperiment")
              gplot(xdata, msLevel = msLevel, peakCol = peakCol,
                    col = col, colramp = colramp, pch = pch, ...)
          })

#' Helper function to create two-panel plot for a single sample
#'
#' @keywords internal
#'
#' @noRd
.create_sample_plot <- function(df, pks, main = "", col = "grey",
                                colramp = grDevices::topo.colors,
                                pch = 21, peakCol = "#ff000060", ...) {
    ## Calculate BPI (max intensity per RT)
    bpi_df <- df |>
        group_by(rt) |>
        summarize(intensity = max(i, na.rm = TRUE), .groups = "drop")
    intensity_range <- range(df$i, na.rm = TRUE)
    if (diff(intensity_range) == 0)
        intensity_range <- c(intensity_range[1] - 1, intensity_range[1] + 1)
    rt_range <- range(df$rt, na.rm = TRUE)
    ## Upper panel: BPI chromatogram
    p_upper <- ggplot(bpi_df, aes(x = rt, y = intensity)) +
        geom_point(aes(fill = intensity),
                   color = col, pch = pch, size = 2) +
        scale_fill_gradientn(colors = colramp(256),
                            limits = intensity_range,
                            name = "Intensity") +
        labs(y = "Intensity", x = "", title = main) +
        theme_bw() +
        theme(axis.title.x = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank(),
              legend.position = "right",
              plot.margin = margin(5, 5, 0, 5)) +
        coord_cartesian(xlim = rt_range)
    ## Lower panel: m/z vs RT scatter
    p_lower <- ggplot(df, aes(x = rt, y = mz)) +
        geom_point(aes(fill = i),
                   color = col, pch = pch, size = 2) +
        scale_fill_gradientn(colors = colramp(256),
                            limits = intensity_range,
                            name = "Intensity") +
        labs(x = "Retention time", y = "m/z") +
        theme_bw() +
        theme(legend.position = "right",
              plot.margin = margin(0, 5, 5, 5)) +
        coord_cartesian(xlim = rt_range)
    ## Add peak rectangles if present
    if (!is.null(pks) && nrow(pks) > 0) {
        peaks_df <- as.data.frame(pks)
        p_lower <- p_lower +
            geom_rect(data = peaks_df,
                     aes(xmin = rtmin, xmax = rtmax,
                         ymin = mzmin, ymax = mzmax),
                     fill = NA, color = peakCol,
                     inherit.aes = FALSE)
    }
    ## Combine using patchwork with shared legend
    p_combined <- p_upper / p_lower +
        plot_layout(heights = c(1, 1), guides = "collect")
    return(p_combined)
}
