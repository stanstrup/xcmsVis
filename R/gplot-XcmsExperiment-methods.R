#' @include AllGenerics.R
NULL

#' ggplot2 Version of plot for XcmsExperiment and XCMSnExp
#'
#' @description
#' Creates a two-panel visualization of MS data showing:
#' - Upper panel: Base Peak Intensity (BPI) chromatogram vs retention time
#' - Lower panel: m/z vs retention time scatter plot with intensity-based coloring
#'
#' This is a ggplot2 implementation of XCMS's `plot()` method for MsExperiment objects,
#' enabling modern visualization and interactive plotting capabilities.
#'
#' @param x XcmsExperiment or XCMSnExp object
#' @param msLevel integer(1) MS level to visualize (default: 1)
#' @param peakCol character(1) color for peak rectangles (default: "#ff000060")
#' @param col character(1) color for point borders (default: "grey")
#' @param colramp function color ramp for intensity mapping (default: grDevices::topo.colors)
#' @param pch integer(1) point shape (default: 21 = filled circle)
#' @param main character vector of titles (one per sample). If NULL, uses sample names.
#' @param xlab character(1) x-axis label (default: "Retention time")
#' @param ... additional arguments (for compatibility)
#'
#' @return A ggplot or patchwork object showing the two-panel visualization.
#'   For single samples, returns a patchwork object with two panels.
#'   For multiple samples, returns a patchwork object with all sample plots stacked.
#'
#' @details
#' The function:
#' \itemize{
#'   \item Extracts spectra data filtered by MS level
#'   \item Applies adjusted retention times if available
#'   \item Upper panel: plots BPI (max intensity per retention time) with intensity-colored points
#'   \item Lower panel: plots m/z vs retention time scatter with intensity-colored points
#'   \item Overlays detected peaks as rectangles (if available)
#'   \item Uses consistent color scale across both panels based on intensity
#' }
#'
#' @examples
#' \dontrun{
#' library(xcmsVis)
#' library(xcms)
#' library(MsExperiment)
#'
#' # Load and filter data
#' fticr_xdata <- readMSData2(...)
#' mse <- filterRt(fticr_xdata, rt = c(175, 189)) %>%
#'        filterMzRange(mz = c(106.02, 106.07))
#'
#' # Plot MS data
#' gplot(mse)
#'
#' # With detected peaks
#' mse_peaks <- findChromPeaks(mse, ...)
#' gplot(mse_peaks, peakCol = "red")
#'
#' # Multiple samples
#' gplot(mse[1:3])
#' }
#'
#' @seealso
#' \code{\link[xcms]{plot,MsExperiment,missing-method}} for the original XCMS implementation
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_rect scale_fill_gradientn
#'   labs theme_bw theme element_blank coord_cartesian margin
#' @importFrom patchwork plot_layout wrap_plots
#' @importFrom xcms hasAdjustedRtime applyAdjustedRtime chromPeaks hasChromPeaks
#' @importFrom MSnbase spectra filterMsLevel rtime
#' @importFrom dplyr group_by summarize
#' @importFrom methods as is
#' @importFrom grDevices topo.colors
#'
#' @rdname gplot-XcmsExperiment
#' @export
setMethod("gplot", "XcmsExperiment",
          function(x, msLevel = 1L, peakCol = "#ff000060",
                   col = "grey", colramp = grDevices::topo.colors,
                   pch = 21, main = NULL, xlab = "Retention time", ...) {

              # Apply adjusted retention times if present
              if (xcms::hasAdjustedRtime(x)) {
                  x <- xcms::applyAdjustedRtime(x)
              }

              # Extract peak information per sample
              pkl <- NULL
              if (xcms::hasChromPeaks(x)) {
                  pkl <- xcms::chromPeaks(x, msLevel = msLevel)
                  if (nrow(pkl) > 0) {
                      pkl <- split.data.frame(
                          pkl,
                          factor(pkl[, "sample"], levels = seq_along(x))
                      )
                  } else {
                      pkl <- NULL
                  }
              }

              # Convert to MsExperiment for data extraction
              mse <- methods::as(x, "MsExperiment")

              # Get sample names for titles
              if (is.null(main)) {
                  fns <- MsExperiment::sampleData(mse)$spectraOrigin
                  if (is.null(fns) || length(fns) == 0) {
                      fns <- paste("Sample", seq_along(mse))
                  } else {
                      fns <- basename(fns)
                  }
              } else {
                  fns <- main
              }

              # Create plot for each sample
              plot_list <- list()
              for (i in seq_along(mse)) {
                  z <- mse[i]

                  # Extract and filter spectra
                  flt <- MSnbase::filterMsLevel(MSnbase::spectra(z), msLevel = msLevel)

                  # Skip if no spectra
                  if (length(flt) == 0) {
                      warning("No spectra found for sample ", i, " at MS level ", msLevel)
                      next
                  }

                  # Convert spectra to list format
                  lst <- methods::as(flt, "list")
                  lns <- lengths(lst) / 2  # Each spectrum has mz and intensity vectors
                  lst <- do.call(rbind, lst)

                  # Create data frame with rt, mz, i columns
                  df <- data.frame(
                      rt = rep(MSnbase::rtime(flt), lns),
                      lst
                  )
                  colnames(df)[colnames(df) == "intensity"] <- "i"

                  # Get peaks for this sample
                  pks <- NULL
                  if (!is.null(pkl) && length(pkl) >= i && !is.null(pkl[[i]])) {
                      pks <- pkl[[i]]
                  }

                  # Create two-panel plot for this sample
                  p <- .create_sample_plot(df, pks, main = fns[i],
                                           col = col, colramp = colramp,
                                           pch = pch, peakCol = peakCol,
                                           xlab = xlab, ...)

                  plot_list[[i]] <- p
              }

              # Combine all sample plots vertically
              if (length(plot_list) == 0) {
                  stop("No plots could be created. Check that data exists for the specified MS level.")
              } else if (length(plot_list) == 1) {
                  return(plot_list[[1]])
              } else {
                  return(wrap_plots(plot_list, ncol = 1))
              }
          })

#' @rdname gplot-XcmsExperiment
#' @export
setMethod("gplot", "XCMSnExp",
          function(x, msLevel = 1L, peakCol = "#ff000060",
                   col = "grey", colramp = grDevices::topo.colors,
                   pch = 21, main = NULL, xlab = "Retention time", ...) {

              # Convert XCMSnExp to XcmsExperiment and use the same method
              # XCMSnExp can be processed similarly
              xdata <- methods::as(x, "XcmsExperiment")
              gplot(xdata, msLevel = msLevel, peakCol = peakCol,
                    col = col, colramp = colramp, pch = pch,
                    main = main, xlab = xlab, ...)
          })

#' Helper function to create two-panel plot for a single sample
#'
#' @keywords internal
#' @noRd
.create_sample_plot <- function(df, pks, main = "", col = "grey",
                                colramp = grDevices::topo.colors,
                                pch = 21, peakCol = "#ff000060",
                                xlab = "Retention time", ...) {

    # Calculate BPI (max intensity per RT)
    bpi_df <- df %>%
        group_by(rt) %>%
        summarize(intensity = max(i, na.rm = TRUE), .groups = "drop")

    # Get intensity range for color scale
    intensity_range <- range(df$i, na.rm = TRUE)

    # Handle case where all intensities are the same
    if (diff(intensity_range) == 0) {
        intensity_range <- c(intensity_range[1] - 1, intensity_range[1] + 1)
    }

    # Get RT range for x-axis
    rt_range <- range(df$rt, na.rm = TRUE)

    # Upper panel: BPI chromatogram
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

    # Lower panel: m/z vs RT scatter
    p_lower <- ggplot(df, aes(x = rt, y = mz)) +
        geom_point(aes(fill = i),
                   color = col, pch = pch, size = 2) +
        scale_fill_gradientn(colors = colramp(256),
                            limits = intensity_range,
                            name = "Intensity") +
        labs(x = xlab, y = "m/z") +
        theme_bw() +
        theme(legend.position = "right",
              plot.margin = margin(0, 5, 5, 5)) +
        coord_cartesian(xlim = rt_range)

    # Add peak rectangles if present
    if (!is.null(pks) && nrow(pks) > 0) {
        peaks_df <- as.data.frame(pks)
        p_lower <- p_lower +
            geom_rect(data = peaks_df,
                     aes(xmin = rtmin, xmax = rtmax,
                         ymin = mzmin, ymax = mzmax),
                     fill = NA, color = peakCol,
                     inherit.aes = FALSE)
    }

    # Combine using patchwork with shared legend
    p_combined <- p_upper / p_lower +
        plot_layout(heights = c(1, 1), guides = "collect")

    return(p_combined)
}
