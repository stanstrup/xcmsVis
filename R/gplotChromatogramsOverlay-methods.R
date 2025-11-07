#' @include AllGenerics.R
NULL

#' Shared implementation function for gplotChromatogramsOverlay
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_point geom_rect geom_polygon
#'   theme_bw labs xlim ylim
#' @importFrom patchwork wrap_plots
#' @importFrom xcms rtime intensity chromPeaks hasChromPeaks
#' @importFrom tibble as_tibble
#' @keywords internal
.gplotChromatogramsOverlay_impl <- function(object,
                                            col = "#00000060",
                                            type = "l",
                                            main = NULL,
                                            xlab = "retention time",
                                            ylab = "intensity",
                                            xlim = numeric(),
                                            ylim = numeric(),
                                            peakType = c("polygon", "point", "rectangle", "none"),
                                            peakBg = NULL,
                                            peakCol = NULL,
                                            peakPch = 1,
                                            stacked = 0,
                                            transform = identity,
                                            ...) {

    peakType <- match.arg(peakType)

    # Set default peak colors if not provided
    if (is.null(peakCol))
        peakCol <- col
    if (is.null(peakBg))
        peakBg <- "#00000020"

    nrows <- nrow(object)
    ncols <- ncol(object)

    # Prepare main titles (one per row)
    if (is.null(main))
        main <- rep("", nrows)
    else if (length(main) == 1)
        main <- rep(main, nrows)
    else if (length(main) != nrows)
        stop("Length of 'main' must be 1 or equal to number of rows")

    # Create a plot for each row
    plot_list <- list()

    for (row_idx in seq_len(nrows)) {
        # Collect data from all columns for this row
        chrom_list <- list()
        for (col_idx in seq_len(ncols)) {
            chr <- object[row_idx, col_idx]
            rt <- xcms::rtime(chr)
            int <- xcms::intensity(chr)

            # Apply transform and stacking
            int <- transform(int)
            int <- int + (col_idx - 1) * stacked

            chrom_list[[col_idx]] <- data.frame(
                rt = rt,
                intensity = int,
                sample = col_idx
            )
        }
        chrom_df <- do.call(rbind, chrom_list)

        # Calculate xlim and ylim if not provided
        if (length(xlim) == 0) {
            xlim_use <- range(chrom_df$rt, na.rm = TRUE)
        } else {
            xlim_use <- xlim
        }

        if (length(ylim) == 0) {
            ylim_use <- range(chrom_df$intensity, na.rm = TRUE)
        } else {
            ylim_use <- ylim
        }

        # Create base plot
        p <- ggplot(chrom_df, aes(x = rt, y = intensity, group = sample)) +
            geom_line(color = col) +
            theme_bw() +
            labs(
                x = xlab,
                y = ylab,
                title = main[row_idx]
            ) +
            xlim(xlim_use[1], xlim_use[2]) +
            ylim(ylim_use[1], ylim_use[2])

        # Add peak annotations if present and requested
        if (peakType != "none" && any(xcms::hasChromPeaks(object[row_idx, , drop = FALSE]))) {
            pks <- xcms::chromPeaks(object[row_idx, , drop = FALSE])

            if (nrow(pks) > 0) {
                peaks_df <- as_tibble(pks)

                # Apply transform and stacking to peak intensities
                peaks_df$maxo <- transform(peaks_df$maxo)
                if (stacked > 0) {
                    # Need to add stacking based on column/sample
                    col_col <- which(colnames(peaks_df) == "column")
                    if (length(col_col)) {
                        peaks_df$maxo <- peaks_df$maxo + (peaks_df$column - 1) * stacked
                    }
                }

                if (peakType == "point") {
                    p <- p + geom_point(
                        data = peaks_df,
                        aes(x = rt, y = maxo),
                        color = peakCol,
                        shape = peakPch,
                        inherit.aes = FALSE
                    )
                } else if (peakType == "rectangle") {
                    p <- p + geom_rect(
                        data = peaks_df,
                        aes(xmin = rtmin, xmax = rtmax, ymin = 0, ymax = maxo),
                        color = peakCol,
                        fill = peakBg,
                        inherit.aes = FALSE
                    )
                } else if (peakType == "polygon") {
                    # For polygons, extract intensity values for each peak
                    for (i in seq_len(nrow(peaks_df))) {
                        pk <- peaks_df[i, ]
                        sample_idx <- pk$column
                        chr <- object[row_idx, sample_idx]
                        chr_rt <- xcms::rtime(chr)
                        chr_int <- xcms::intensity(chr)

                        # Apply transform and stacking
                        chr_int <- transform(chr_int)
                        chr_int <- chr_int + (sample_idx - 1) * stacked

                        # Get points within peak bounds
                        idx <- which(chr_rt >= pk$rtmin & chr_rt <= pk$rtmax)
                        if (length(idx) > 0) {
                            poly_df <- data.frame(
                                rt = chr_rt[idx],
                                intensity = chr_int[idx]
                            )
                            # Add baseline points to close polygon
                            baseline_y <- (sample_idx - 1) * stacked
                            poly_df <- rbind(
                                data.frame(rt = pk$rtmin, intensity = baseline_y),
                                poly_df,
                                data.frame(rt = pk$rtmax, intensity = baseline_y)
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

        plot_list[[row_idx]] <- p
    }

    # Return single plot or combine with patchwork
    if (nrows == 1) {
        return(plot_list[[1]])
    } else {
        return(wrap_plots(plot_list, ncol = 1))
    }
}

#' @rdname gplotChromatogramsOverlay
#' @export
setMethod("gplotChromatogramsOverlay", "XChromatograms",
          function(object, col = "#00000060", type = "l", main = NULL,
                   xlab = "retention time", ylab = "intensity",
                   xlim = numeric(), ylim = numeric(),
                   peakType = c("polygon", "point", "rectangle", "none"),
                   peakBg = NULL, peakCol = NULL, peakPch = 1,
                   stacked = 0, transform = identity, ...) {

              .gplotChromatogramsOverlay_impl(
                  object = object, col = col, type = type, main = main,
                  xlab = xlab, ylab = ylab, xlim = xlim, ylim = ylim,
                  peakType = peakType, peakBg = peakBg, peakCol = peakCol,
                  peakPch = peakPch, stacked = stacked, transform = transform, ...
              )
          })

#' @rdname gplotChromatogramsOverlay
#' @export
setMethod("gplotChromatogramsOverlay", "MChromatograms",
          function(object, col = "#00000060", type = "l", main = NULL,
                   xlab = "retention time", ylab = "intensity",
                   xlim = numeric(), ylim = numeric(),
                   peakType = c("polygon", "point", "rectangle", "none"),
                   peakBg = NULL, peakCol = NULL, peakPch = 1,
                   stacked = 0, transform = identity, ...) {

              .gplotChromatogramsOverlay_impl(
                  object = object, col = col, type = type, main = main,
                  xlab = xlab, ylab = ylab, xlim = xlim, ylim = ylim,
                  peakType = peakType, peakBg = peakBg, peakCol = peakCol,
                  peakPch = peakPch, stacked = stacked, transform = transform, ...
              )
          })
