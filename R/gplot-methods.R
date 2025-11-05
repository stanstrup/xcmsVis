#' @include AllGenerics.R
NULL

# Shared implementation function for gplot
#'
#' @importFrom xcms rtime intensity chromPeaks hasChromPeaks
#' @importFrom ggplot2 ggplot aes geom_line geom_point theme_bw labs
#' @importFrom tibble as_tibble
#' @importFrom methods is
#' @keywords internal
.gplot_impl <- function(x,
                        col = "black",
                        lty = 1,
                        type = "l",
                        xlab = "retention time",
                        ylab = "intensity",
                        main = NULL,
                        peakType = c("polygon", "point", "rectangle", "none"),
                        peakCol = "#00000060",
                        peakBg = "#00000020",
                        peakPch = 1,
                        ...) {

    peakType <- match.arg(peakType)

    # Extract chromatogram data
    rt <- rtime(x)
    int <- intensity(x)

    # Create data frame
    chrom_df <- data.frame(
        rt = rt,
        intensity = int
    )

    # Create base plot
    p <- ggplot(chrom_df, aes(x = rt, y = intensity)) +
        geom_line(color = col, linetype = lty) +
        theme_bw() +
        labs(
            x = xlab,
            y = ylab,
            title = main
        )

    # Add peak annotations if present
    if (hasChromPeaks(x) && peakType != "none") {
        peaks <- chromPeaks(x)

        if (nrow(peaks) > 0) {
            peaks_df <- as_tibble(peaks)

            if (peakType == "point") {
                # Add points at peak apex
                p <- p + geom_point(
                    data = peaks_df,
                    aes(x = rt, y = maxo),
                    color = peakCol,
                    shape = peakPch,
                    inherit.aes = FALSE
                )
            } else if (peakType == "rectangle") {
                # Add rectangles spanning peak bounds
                p <- p + geom_rect(
                    data = peaks_df,
                    aes(xmin = rtmin, xmax = rtmax, ymin = 0, ymax = maxo),
                    color = peakCol,
                    fill = peakBg,
                    inherit.aes = FALSE
                )
            } else if (peakType == "polygon") {
                # Add polygons following peak shape
                # For each peak, extract points within rt range
                for (i in seq_len(nrow(peaks_df))) {
                    pk <- peaks_df[i, ]
                    # Get chromatogram points within peak bounds
                    idx <- which(chrom_df$rt >= pk$rtmin & chrom_df$rt <= pk$rtmax)
                    if (length(idx) > 0) {
                        poly_df <- chrom_df[idx, ]
                        # Add baseline points to close polygon
                        poly_df <- rbind(
                            data.frame(rt = pk$rtmin, intensity = 0),
                            poly_df,
                            data.frame(rt = pk$rtmax, intensity = 0)
                        )
                        p <- p + geom_polygon(
                            data = poly_df,
                            aes(x = rt, y = intensity),
                            color = peakCol,
                            fill = peakBg,
                            inherit.aes = FALSE
                        )
                    }
                }
            }
        }
    }

    return(p)
}

#' @rdname gplot
#' @export
setMethod("gplot", "XChromatogram",
          function(x,
                   col = "black",
                   lty = 1,
                   type = "l",
                   xlab = "retention time",
                   ylab = "intensity",
                   main = NULL,
                   peakType = c("polygon", "point", "rectangle", "none"),
                   peakCol = "#00000060",
                   peakBg = "#00000020",
                   peakPch = 1,
                   ...) {
              .gplot_impl(x, col, lty, type, xlab, ylab, main,
                         peakType, peakCol, peakBg, peakPch, ...)
          })
