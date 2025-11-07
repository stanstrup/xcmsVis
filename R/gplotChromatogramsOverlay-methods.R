#' @include AllGenerics.R
NULL

#' Shared implementation function for gplotChromatogramsOverlay
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_point geom_rect geom_polygon
#'   theme_bw labs xlim ylim facet_wrap
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
    transform <- match.fun(transform)

    # Set default peak colors if not provided
    if (is.null(peakCol))
        peakCol <- col
    if (is.null(peakBg))
        peakBg <- "#00000020"

    nrows <- nrow(object)
    ncols <- ncol(object)

    # Prepare main titles (one per column/sample)
    if (is.null(main))
        main <- rep("", ncols)
    else if (length(main) == 1)
        main <- rep(main, ncols)
    else if (length(main) != ncols)
        stop("Length of 'main' must be 1 or equal to number of columns (samples)")

    # Collect data from all rows for each column
    # Each column gets its own plot with all rows overlaid
    all_data <- list()
    for (col_idx in seq_len(ncols)) {
        chrom_list <- list()
        for (row_idx in seq_len(nrows)) {
            chr <- object[row_idx, col_idx]
            rt <- xcms::rtime(chr)
            int <- xcms::intensity(chr)

            # Apply transform
            int <- transform(int)

            # Apply stacking based on row index (EIC) if stacked > 0
            if (stacked > 0) {
                # Calculate stacking position based on m/z if available
                # For now, use row index for consistent behavior
                int <- int + (row_idx - 1) * stacked
            }

            chrom_list[[row_idx]] <- data.frame(
                rt = rt,
                intensity = int,
                row = row_idx,
                col = col_idx
            )
        }
        all_data[[col_idx]] <- do.call(rbind, chrom_list)
        all_data[[col_idx]]$panel_title <- main[col_idx]
    }

    # Combine all data
    combined_df <- do.call(rbind, all_data)

    # Calculate xlim and ylim if not provided
    if (length(xlim) == 0) {
        xlim_use <- range(combined_df$rt, na.rm = TRUE)
    } else {
        xlim_use <- xlim
    }

    if (length(ylim) == 0) {
        # Always start from 0 to match XCMS behavior
        ylim_use <- c(0, max(combined_df$intensity, na.rm = TRUE))
    } else {
        ylim_use <- ylim
    }

    # Create base plot
    # Group by row to overlay different EICs (rows) in same plot
    p <- ggplot(combined_df, aes(x = rt, y = intensity, group = row)) +
        geom_line(color = col) +
        theme_bw() +
        labs(x = xlab, y = ylab) +
        xlim(xlim_use[1], xlim_use[2]) +
        ylim(ylim_use[1], ylim_use[2])

    # Add faceting if multiple columns (samples)
    if (ncols > 1) {
        p <- p + facet_wrap(~ panel_title, ncol = 1, scales = "free_y")
    } else {
        # Single sample - add title if provided
        if (!is.null(main) && main[1] != "") {
            p <- p + labs(title = main[1])
        }
    }

    # Add peak annotations if present and requested
    if (peakType != "none" && any(xcms::hasChromPeaks(object))) {
        for (col_idx in seq_len(ncols)) {
            # Get peaks for this column across all rows
            col_data <- object[, col_idx, drop = FALSE]
            if (!any(xcms::hasChromPeaks(col_data)))
                next

            pks <- xcms::chromPeaks(col_data)
            if (nrow(pks) == 0)
                next

            peaks_df <- as_tibble(pks)
            peaks_df$col <- col_idx
            peaks_df$panel_title <- main[col_idx]

            # Determine which column has row info
            row_col <- which(colnames(peaks_df) == "row")
            if (length(row_col) == 0)
                next

            # Apply transform to peak intensities
            peaks_df$maxo <- transform(peaks_df$maxo)

            # Apply stacking
            if (stacked > 0) {
                peaks_df$maxo <- peaks_df$maxo + (peaks_df$row - 1) * stacked
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
                peaks_df$ymin <- if (stacked > 0) {
                    (peaks_df$row - 1) * stacked
                } else {
                    0
                }
                p <- p + geom_rect(
                    data = peaks_df,
                    aes(xmin = rtmin, xmax = rtmax, ymin = ymin, ymax = maxo),
                    color = peakCol,
                    fill = peakBg,
                    inherit.aes = FALSE
                )
            } else if (peakType == "polygon") {
                # Collect all polygons with NA breaks (matches XCMS behavior)
                xs_all <- numeric()
                ys_all <- numeric()

                for (i in seq_len(nrow(peaks_df))) {
                    pk <- peaks_df[i, ]
                    row_idx <- pk$row
                    chr <- object[row_idx, col_idx]

                    # Use filterRt to extract peak region (matches XCMS exactly)
                    chr_filtered <- MSnbase::filterRt(chr, rt = c(pk$rtmin, pk$rtmax))
                    xs <- xcms::rtime(chr_filtered)

                    # Check if we have any points
                    if (!length(xs)) next

                    # Get intensities
                    ints <- xcms::intensity(chr_filtered)

                    # Apply transform
                    ints <- transform(ints)

                    # Handle infinite values
                    ints[is.infinite(ints)] <- 0

                    # Apply stacking
                    baseline_y <- if (stacked > 0) (row_idx - 1) * stacked else 0
                    if (stacked > 0) {
                        ints <- ints + baseline_y
                    }

                    # Add baseline points at start and end
                    xs <- c(xs[1], xs, xs[length(xs)])
                    ys <- c(baseline_y, ints, baseline_y)

                    # Filter out NA values (both xs and ys together)
                    nona <- !is.na(ys)

                    # Add NA break between peaks (not before first peak)
                    if (length(xs_all) > 0) {
                        xs_all <- c(xs_all, NA)
                        ys_all <- c(ys_all, NA)
                    }

                    xs_all <- c(xs_all, xs[nona])
                    ys_all <- c(ys_all, ys[nona])
                }

                # Draw all polygons in one call with NA breaks
                if (length(xs_all) > 0) {
                    poly_df <- data.frame(rt = xs_all, intensity = ys_all)
                    poly_df$panel_title <- main[col_idx]

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

    return(p)
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
                   stacked = 0, transform = identity, ...) {

              # MChromatograms doesn't have peaks, so set peakType to "none"
              .gplotChromatogramsOverlay_impl(
                  object = object, col = col, type = type, main = main,
                  xlab = xlab, ylab = ylab, xlim = xlim, ylim = ylim,
                  peakType = "none", peakBg = NULL, peakCol = NULL,
                  peakPch = 1, stacked = stacked, transform = transform, ...
              )
          })
