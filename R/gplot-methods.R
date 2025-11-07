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

#' @rdname gplot
#' @importFrom ggplot2 ggplot aes geom_line theme_bw labs
#' @importFrom xcms rtime intensity chromPeaks hasChromPeaks
#' @export
setMethod("gplot", "XChromatograms",
          function(x,
                   col = "#00000060",
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

              # For multi-row XChromatograms, we'll just plot the first row with all columns overlaid
              # This matches the expected behavior for plotChromPeakDensity
              if (nrow(x) > 1) {
                  warning("gplot for XChromatograms with multiple rows only plots the first row")
                  x <- x[1, , drop = FALSE]
              }

              # Collect data from all columns (samples)
              chrom_list <- list()
              for (i in seq_len(ncol(x))) {
                  chr <- x[1, i]
                  chrom_list[[i]] <- data.frame(
                      rt = xcms::rtime(chr),
                      intensity = xcms::intensity(chr),
                      sample = i
                  )
              }
              chrom_df <- do.call(rbind, chrom_list)

              # Create base plot with all chromatograms
              p <- ggplot(chrom_df, aes(x = rt, y = intensity, group = sample)) +
                  geom_line(color = col, linetype = lty) +
                  theme_bw() +
                  labs(
                      x = xlab,
                      y = ylab,
                      title = main
                  )

              # Add peak annotations if present and requested
              if (peakType != "none" && any(xcms::hasChromPeaks(x))) {
                  pks <- xcms::chromPeaks(x)
                  if (nrow(pks) > 0) {
                      # For XChromatograms, peaks have row and column indices
                      # Filter to first row
                      pks <- pks[pks[, "row"] == 1, , drop = FALSE]

                      if (nrow(pks) > 0) {
                          peaks_df <- as_tibble(pks)

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
                              # Collect all polygons with NA breaks (matches XCMS behavior)
                              xs_all <- numeric()
                              ys_all <- numeric()

                              for (i in seq_len(nrow(peaks_df))) {
                                  pk <- peaks_df[i, ]
                                  sample_idx <- pk$column
                                  chr <- x[1, sample_idx]
                                  chr_rt <- xcms::rtime(chr)
                                  chr_int <- xcms::intensity(chr)

                                  # Get points within peak bounds
                                  idx <- which(chr_rt >= pk$rtmin & chr_rt <= pk$rtmax)
                                  if (length(idx) == 0) next

                                  xs <- chr_rt[idx]
                                  ys <- chr_int[idx]

                                  # Replace infinite values with 0 (matches XCMS)
                                  ys[is.infinite(ys)] <- 0

                                  # Add baseline points at start and end
                                  xs <- c(xs[1], xs, xs[length(xs)])
                                  ys <- c(0, ys, 0)

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
          })

#' @rdname gplot
#' @export
setMethod("gplot", "MChromatograms",
          function(x,
                   col = "#00000060",
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
              # MChromatograms can be handled the same way as XChromatograms
              # Convert to XChromatograms if it has peaks, otherwise treat as regular MChromatograms
              if (is(x, "XChromatograms")) {
                  gplot(x, col = col, lty = lty, type = type, xlab = xlab,
                       ylab = ylab, main = main, peakType = peakType,
                       peakCol = peakCol, peakBg = peakBg, peakPch = peakPch, ...)
              } else {
                  # Regular MChromatograms - plot as overlaid lines
                  peakType <- match.arg(peakType)

                  if (nrow(x) > 1) {
                      warning("gplot for MChromatograms with multiple rows only plots the first row")
                      x <- x[1, , drop = FALSE]
                  }

                  # Collect data from all columns
                  chrom_list <- list()
                  for (i in seq_len(ncol(x))) {
                      chr <- x[1, i]
                      chrom_list[[i]] <- data.frame(
                          rt = xcms::rtime(chr),
                          intensity = xcms::intensity(chr),
                          sample = i
                      )
                  }
                  chrom_df <- do.call(rbind, chrom_list)

                  # Create plot
                  p <- ggplot(chrom_df, aes(x = rt, y = intensity, group = sample)) +
                      geom_line(color = col, linetype = lty) +
                      theme_bw() +
                      labs(
                          x = xlab,
                          y = ylab,
                          title = main
                      )

                  return(p)
              }
          })
