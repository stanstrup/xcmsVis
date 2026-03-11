#' @include AllGenerics.R
NULL

# Helper function to add polygon peak annotations
#'
#' @param chr_obj Chromatogram object to extract data from (for single
#'     chromatogram)
#' @param peaks_df Data frame with peak information
#' @param peak_ids Character vector of peak IDs (rownames from chromPeaks)
#' @param peakCol Color for polygon border
#' @param peakBg Color for polygon fill
#' @keywords internal
#'
#' @importFrom ProtGenerics filterRt rtime intensity
#'
#' @noRd
.add_polygon_peaks <- function(chr_obj, peaks_df, peak_ids, peakCol, peakBg) {
    ## Collect all polygons with NA breaks (matches XCMS behavior)
    xs_all <- numeric()
    ys_all <- numeric()
    ids_all <- character()
    for (i in seq_len(nrow(peaks_df))) {
        chr_filtered <- filterRt(chr_obj, rt = c(peaks_df$rtmin[i],
                                                 peaks_df$rtmax[i]))
        xs <- rtime(chr_filtered)
        if (!length(xs)) next
        ## Get intensities and handle infinite values
        ints <- intensity(chr_filtered)
        ints[is.infinite(ints)] <- 0
        ## Add baseline points at start and end
        xs <- c(xs[1], xs, xs[length(xs)])
        ys <- c(0, ints, 0)
        ## Filter out NA values (both xs and ys together)
        nona <- !is.na(ys)
        ## Get peak ID for this peak
        peak_id <- if (i <= length(peak_ids)) peak_ids[i]
                   else paste0("Peak_", i)
        ## Add NA break between peaks (not before first peak)
        if (length(xs_all) > 0) {
            xs_all <- c(xs_all, NA)
            ys_all <- c(ys_all, NA)
            ids_all <- c(ids_all, NA)
        }
        xs_all <- c(xs_all, xs[nona])
        ys_all <- c(ys_all, ys[nona])
        ids_all <- c(ids_all, rep(peak_id, sum(nona)))
    }
    ## Return data frame for polygon, or NULL if no data
    if (length(xs_all) > 0) {
        data.frame(rt = xs_all, intensity = ys_all, peak_id = ids_all)
    } else {
        NULL
    }
}

## Shared implementation function for gplot
#'
#' @param x `Chromatogram`/`XChromatogram` object.
#'
#' @importFrom xcms rtime intensity chromPeaks hasChromPeaks
#' @importFrom ggplot2 ggplot aes geom_line geom_point theme_bw labs
#' @importFrom tibble as_tibble
#' @importFrom methods is
#' @keywords internal
#' @noRd
.gplot_impl <- function(x,
                        col = "black",
                        lty = 1,
                        type = "l",
                        peakType = c("polygon", "point", "rectangle", "none"),
                        peakCol = "#00000060",
                        peakBg = "#00000020",
                        peakPch = 1,
                        ...) {
    peakType <- match.arg(peakType)
    ## Create data frame
    chrom_df <- data.frame(
        rt = rtime(x),
        intensity = intensity(x)
    )
    ## Create base plot
    p <- ggplot(chrom_df, aes(x = rt, y = intensity)) +
        geom_line(color = col, linetype = lty) +
        theme_bw() +
        labs(
            x = "retention time",
            y = "intensity"
        )
    ## Add peak annotations if present
    if (hasChromPeaks(x) && peakType != "none") {
        peaks <- chromPeaks(x)
        if (nrow(peaks) > 0) {
            peaks_df <- as_tibble(peaks)
            ## Add peak IDs for tooltip support
            peaks_df$peak_id <- rownames(peaks)
            if (peakType == "point") {
                ## Add points at peak apex
                ## Use wrapper that suppresses 'text' aesthetic warning
                ## (for plotly tooltips)
                p <- p + .geom_point_text(
                    data = peaks_df,
                    aes(x = rt, y = maxo, text = peak_id),
                    color = peakCol,
                    shape = peakPch,
                    inherit.aes = FALSE
                )
            } else if (peakType == "rectangle") {
                ## Add rectangles spanning peak bounds
                ## Use wrapper that suppresses 'text' aesthetic warning
                ## (for plotly tooltips)
                p <- p + .geom_rect_text(
                    data = peaks_df,
                    aes(xmin = rtmin, xmax = rtmax, ymin = 0, ymax = maxo, text = peak_id),
                    color = peakCol,
                    fill = peakBg,
                    inherit.aes = FALSE
                )
            } else if (peakType == "polygon") {
                ## Get peak IDs from rownames
                peak_ids <- rownames(peaks)
                poly_df <- .add_polygon_peaks(x, peaks_df, peak_ids,
                                              peakCol, peakBg)
                if (!is.null(poly_df)) {
                    ## Use wrapper that suppresses 'text' aesthetic
                    ## warning (for plotly tooltips)
                    p <- p + .geom_polygon_text(
                        data = poly_df,
                        aes(x = rt, y = intensity, text = peak_id),
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

#' @rdname gplot
#'
#' @importClassesFrom xcms XChromatogram
#'
#' @export
setMethod("gplot", "XChromatogram",
          function(x,
                   col = "black",
                   lty = 1,
                   type = "l",
                   peakType = c("polygon", "point", "rectangle", "none"),
                   peakCol = "#00000060",
                   peakBg = "#00000020",
                   peakPch = 1,
                   ...) {
              .gplot_impl(x, col, lty, type, peakType, peakCol, peakBg,
                          peakPch, ...)
          })

#' @rdname gplot
#'
#' @importFrom ggplot2 ggplot aes geom_line theme_bw labs
#' @importFrom xcms chromPeaks hasChromPeaks
#' @importClassesFrom xcms XChromatograms
#'
#' @export
setMethod("gplot", "XChromatograms",
          function(x,
                   col = "#00000060",
                   lty = 1,
                   type = "l",
                   peakType = c("polygon", "point", "rectangle", "none"),
                   peakCol = "#00000060",
                   peakBg = "#00000020",
                   peakPch = 1,
                   include_columns = NULL,
                   ...) {
              peakType <- match.arg(peakType)
              ## For multi-row XChromatograms, we'll just plot the first row
              ## with all columns overlaid
              ## This matches the expected behavior for plotChromPeakDensity
              if (nrow(x) > 1) {
                  warning("gplot for XChromatograms with multiple rows ",
                          "only plots the first row")
                  x <- x[1, , drop = FALSE]
              }
              ## Resolve color parameters against pData columns
              pd <- Biobase::pData(x)
              pd_cols <- colnames(pd)
              col_info <- .resolve_color(col, pd_cols)
              peakCol_info <- .resolve_color(peakCol, pd_cols)
              peakBg_info <- .resolve_color(peakBg, pd_cols)
              any_mapping <- col_info$type == "mapping" ||
                  peakCol_info$type == "mapping" ||
                  peakBg_info$type == "mapping"
              needs_pdata <- any_mapping || !is.null(include_columns)
              ## Build the base chromatogram plot
              chrom_list <- list()
              for (i in seq_len(ncol(x))) {
                  chr <- x[1, i]
                  chrom_list[[i]] <- data.frame(
                      rt = rtime(chr),
                      intensity = intensity(chr),
                      sample = i
                  )
              }
              chrom_df <- do.call(rbind, chrom_list)
              ## Join pData when needed (color mapping or tooltips)
              if (needs_pdata) {
                  pd$sample <- seq_len(nrow(pd))
                  chrom_df <- merge(chrom_df, pd, by = "sample")
              }
              ## Build tooltip text for chromatogram lines
              tooltip <- .build_tooltip(chrom_df, include_columns, pd_cols)
              has_tooltip <- !is.null(tooltip)
              if (has_tooltip) chrom_df$text <- tooltip
              ## Create base plot
              if (col_info$type == "mapping") {
                  if (has_tooltip) {
                      p <- ggplot(chrom_df,
                                  aes(x = rt, y = intensity, group = sample,
                                      color = .data[[col_info$value]],
                                      text = text)) +
                          .geom_line_text(linetype = lty)
                  } else {
                      p <- ggplot(chrom_df,
                                  aes(x = rt, y = intensity, group = sample,
                                      color = .data[[col_info$value]])) +
                          geom_line(linetype = lty)
                  }
              } else {
                  if (has_tooltip) {
                      p <- ggplot(chrom_df,
                                  aes(x = rt, y = intensity, group = sample,
                                      text = text)) +
                          .geom_line_text(color = col_info$value,
                                          linetype = lty)
                  } else {
                      p <- ggplot(chrom_df,
                                  aes(x = rt, y = intensity,
                                      group = sample)) +
                          geom_line(color = col_info$value, linetype = lty)
                  }
              }
              p <- p + theme_bw() +
                  labs(x = "retention time", y = "intensity")
              ## Add peak annotations if present and requested
              if (peakType != "none" && any(hasChromPeaks(x))) {
                  pks <- chromPeaks(x)
                  if (nrow(pks) > 0) {
                      ## Filter to first row
                      pks <- pks[pks[, "row"] == 1, , drop = FALSE]
                      if (nrow(pks) > 0) {
                          peaks_df <- as_tibble(pks)
                          peaks_df$peak_id <- rownames(pks)
                          ## Join pData to peaks for colors or tooltips
                          if (needs_pdata) {
                              peaks_df$sample <- peaks_df$column
                              peaks_df <- merge(peaks_df, pd, by = "sample")
                          }
                          ## Build peak tooltip (peak_id + metadata)
                          pk_tooltip <- .build_tooltip(
                              peaks_df, include_columns, pd_cols,
                              extra = peaks_df$peak_id)
                          if (!is.null(pk_tooltip)) {
                              peaks_df$text <- pk_tooltip
                          } else {
                              peaks_df$text <- peaks_df$peak_id
                          }
                          if (peakType == "point") {
                              if (peakCol_info$type == "mapping") {
                                  p <- p + .geom_point_text(
                                      data = peaks_df,
                                      aes(x = rt, y = maxo, text = text,
                                          color = .data[[peakCol_info$value]]),
                                      shape = peakPch,
                                      inherit.aes = FALSE
                                  )
                              } else {
                                  p <- p + .geom_point_text(
                                      data = peaks_df,
                                      aes(x = rt, y = maxo, text = text),
                                      color = peakCol_info$value,
                                      shape = peakPch,
                                      inherit.aes = FALSE
                                  )
                              }
                          } else if (peakType == "rectangle") {
                              if (peakBg_info$type == "mapping") {
                                  p <- p + .geom_rect_text(
                                      data = peaks_df,
                                      aes(xmin = rtmin, xmax = rtmax,
                                          ymin = 0, ymax = maxo,
                                          text = text,
                                          fill = .data[[peakBg_info$value]]),
                                      color = if (peakCol_info$type == "static")
                                                  peakCol_info$value
                                              else NA,
                                      inherit.aes = FALSE
                                  )
                              } else if (peakCol_info$type == "mapping") {
                                  p <- p + .geom_rect_text(
                                      data = peaks_df,
                                      aes(xmin = rtmin, xmax = rtmax,
                                          ymin = 0, ymax = maxo,
                                          text = text,
                                          color = .data[[peakCol_info$value]]),
                                      fill = peakBg_info$value,
                                      inherit.aes = FALSE
                                  )
                              } else {
                                  p <- p + .geom_rect_text(
                                      data = peaks_df,
                                      aes(xmin = rtmin, xmax = rtmax,
                                          ymin = 0, ymax = maxo,
                                          text = text),
                                      color = peakCol_info$value,
                                      fill = peakBg_info$value,
                                      inherit.aes = FALSE
                                  )
                              }
                          } else if (peakType == "polygon") {
                              poly_df <- data.frame()
                              for (j in seq_len(ncol(x))) {
                                  chr <- x[1L, j]
                                  pks_j <- chromPeaks(chr)
                                  if (nrow(pks_j)) {
                                      pks_j_df <- as_tibble(pks_j)
                                      pdf_j <- .add_polygon_peaks(
                                          chr, pks_j_df,
                                          rownames(pks_j),
                                          if (peakCol_info$type == "static")
                                              peakCol_info$value
                                          else "#00000060",
                                          if (peakBg_info$type == "static")
                                              peakBg_info$value
                                          else "#00000020")
                                      if (!is.null(pdf_j)) {
                                          pdf_j$sample <- j
                                          poly_df <- rbind(poly_df, pdf_j)
                                      }
                                  }
                              }
                              if (nrow(poly_df) > 0) {
                                  if (needs_pdata) {
                                      poly_df <- merge(poly_df, pd,
                                                       by = "sample")
                                  }
                                  ## Build polygon tooltip
                                  poly_tip <- .build_tooltip(
                                      poly_df, include_columns, pd_cols,
                                      extra = poly_df$peak_id)
                                  if (!is.null(poly_tip)) {
                                      poly_df$text <- poly_tip
                                  } else {
                                      poly_df$text <- poly_df$peak_id
                                  }
                                  if (peakBg_info$type == "mapping") {
                                      p <- p + .geom_polygon_text(
                                          data = poly_df,
                                          aes(x = rt, y = intensity,
                                              text = text,
                                              fill = .data[[peakBg_info$value]],
                                              group = interaction(
                                                  sample, peak_id)),
                                          color = if (peakCol_info$type ==
                                                      "static")
                                                      peakCol_info$value
                                                  else NA,
                                          inherit.aes = FALSE
                                      )
                                  } else if (peakCol_info$type == "mapping") {
                                      p <- p + .geom_polygon_text(
                                          data = poly_df,
                                          aes(x = rt, y = intensity,
                                              text = text,
                                              color = .data[[
                                                  peakCol_info$value]],
                                              group = interaction(
                                                  sample, peak_id)),
                                          fill = peakBg_info$value,
                                          inherit.aes = FALSE
                                      )
                                  } else {
                                      p <- p + .geom_polygon_text(
                                          data = poly_df,
                                          aes(x = rt, y = intensity,
                                              text = text),
                                          color = peakCol_info$value,
                                          fill = peakBg_info$value,
                                          inherit.aes = FALSE
                                      )
                                  }
                              }
                          }
                      }
                  }
              }
              return(p)
          })

#' @rdname gplot
#'
#' @importClassesFrom MSnbase MChromatograms
#' @importFrom Biobase pData
#' @importFrom rlang .data
#'
#' @export
setMethod("gplot", "MChromatograms",
          function(x,
                   col = "#00000060",
                   lty = 1,
                   type = "l",
                   peakType = c("polygon", "point", "rectangle", "none"),
                   peakCol = "#00000060",
                   peakBg = "#00000020",
                   peakPch = 1,
                   include_columns = NULL,
                   ...) {
              if (nrow(x) > 1) {
                  warning("gplot for MChromatograms with multiple rows only",
                          " plots the first row")
                  x <- x[1, , drop = FALSE]
              }
              ## Get pData and resolve color parameter
              pd <- Biobase::pData(x)
              pd_cols <- colnames(pd)
              col_info <- .resolve_color(col, pd_cols)
              needs_pdata <- col_info$type == "mapping" ||
                  !is.null(include_columns)
              ## Collect data from all columns
              chrom_list <- list()
              for (i in seq_len(ncol(x))) {
                  chr <- x[1, i]
                  chrom_list[[i]] <- data.frame(
                      rt = rtime(chr),
                      intensity = intensity(chr),
                      sample = i
                  )
              }
              chrom_df <- do.call(rbind, chrom_list)
              ## Join pData when needed (color mapping or tooltips)
              if (needs_pdata) {
                  pd$sample <- seq_len(nrow(pd))
                  chrom_df <- merge(chrom_df, pd, by = "sample")
              }
              ## Build tooltip text
              tooltip <- .build_tooltip(chrom_df, include_columns, pd_cols)
              has_tooltip <- !is.null(tooltip)
              if (has_tooltip) chrom_df$text <- tooltip
              ## Create plot
              if (col_info$type == "mapping") {
                  if (has_tooltip) {
                      p <- ggplot(chrom_df,
                                  aes(x = rt, y = intensity, group = sample,
                                      color = .data[[col_info$value]],
                                      text = text)) +
                          .geom_line_text(linetype = lty)
                  } else {
                      p <- ggplot(chrom_df,
                                  aes(x = rt, y = intensity, group = sample,
                                      color = .data[[col_info$value]])) +
                          geom_line(linetype = lty)
                  }
              } else {
                  if (has_tooltip) {
                      p <- ggplot(chrom_df,
                                  aes(x = rt, y = intensity, group = sample,
                                      text = text)) +
                          .geom_line_text(color = col_info$value,
                                          linetype = lty)
                  } else {
                      p <- ggplot(chrom_df,
                                  aes(x = rt, y = intensity,
                                      group = sample)) +
                          geom_line(color = col_info$value, linetype = lty)
                  }
              }
              p <- p + theme_bw() +
                  labs(x = "retention time", y = "intensity")
              return(p)
          })
