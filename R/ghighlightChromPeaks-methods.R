#' @include AllGenerics.R
NULL

# Shared implementation function for ghighlightChromPeaks
#'
#' @importFrom xcms chromPeaks hasChromPeaks
#' @importFrom ggplot2 geom_rect geom_point annotate
#' @importFrom tibble tibble
#' @importFrom methods is
#' @keywords internal
.ghighlightChromPeaks_impl <- function(object,
                                       chrom_data,
                                       rt,
                                       mz,
                                       peakIds = character(),
                                       border = "#00000040",
                                       fill = NA,
                                       type = c("rect", "point", "polygon"),
                                       whichPeaks = c("any", "within", "apex_within"),
                                       msLevel = 1L) {

    .validate_xcms_object(object)
    type <- match.arg(type)
    whichPeaks <- match.arg(whichPeaks)

    # Check that peaks exist
    if (!hasChromPeaks(object)) {
        stop("No chromatographic peaks found in object. ",
             "Run findChromPeaks() first.", call. = FALSE)
    }

    # Handle peakIds vs rt/mz
    if (length(peakIds) > 0) {
        # Use specific peak IDs
        all_peaks <- chromPeaks(object, msLevel = msLevel)
        if (!all(peakIds %in% rownames(all_peaks))) {
            stop("'peakIds' do not match rownames of 'chromPeaks(object)'",
                 call. = FALSE)
        }
        pks <- all_peaks[peakIds, , drop = FALSE]
    } else {
        # Use rt and mz ranges
        if (missing(rt)) rt <- c(-Inf, Inf)
        if (missing(mz)) mz <- c(-Inf, Inf)

        pks <- chromPeaks(object, rt = rt, mz = mz, ppm = 0,
                         type = whichPeaks, msLevel = msLevel)
    }

    # Return empty list if no peaks
    if (nrow(pks) == 0) {
        return(list())
    }

    # Create ggplot layers based on type
    layers <- list()

    if (type == "rect") {
        # Create rectangles from rtmin to rtmax, baseline to maxo
        pks_df <- tibble(
            xmin = pks[, "rtmin"],
            xmax = pks[, "rtmax"],
            ymin = 0,
            ymax = pks[, "maxo"]
        )

        layers[[1]] <- geom_rect(
            data = pks_df,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            color = border,
            fill = fill,
            inherit.aes = FALSE
        )

    } else if (type == "point") {
        # Create points at peak apex
        pks_df <- tibble(
            x = pks[, "rt"],
            y = pks[, "maxo"]
        )

        layers[[1]] <- geom_point(
            data = pks_df,
            aes(x = x, y = y),
            color = if (is.na(fill)) border else fill,
            inherit.aes = FALSE
        )

    } else if (type == "polygon") {
        # For polygon, we need the actual chromatogram data
        # This is more complex and requires matching peaks to chrom_data
        if (missing(chrom_data) || is.null(chrom_data)) {
            warning("Polygon type requires 'chrom_data' to be provided. ",
                   "Falling back to 'rect' type.")
            return(.ghighlightChromPeaks_impl(object, chrom_data, rt, mz,
                                             peakIds, border, fill, "rect",
                                             whichPeaks, msLevel))
        }

        # For each peak, extract the chromatogram region and create polygon
        # This is simplified - a full implementation would need to filter
        # chrom_data by rt range for each peak
        for (i in seq_len(nrow(pks))) {
            peak_rt_range <- c(pks[i, "rtmin"], pks[i, "rtmax"])

            # Filter chromatogram data to peak region
            peak_chrom <- chrom_data[
                chrom_data$rt >= peak_rt_range[1] &
                chrom_data$rt <= peak_rt_range[2], ]

            if (nrow(peak_chrom) > 0) {
                # Create polygon coordinates (close the shape)
                poly_df <- tibble(
                    x = c(peak_chrom$rt, rev(peak_chrom$rt)[1],
                         peak_chrom$rt[1]),
                    y = c(peak_chrom$intensity, 0, 0)
                )

                # Remove NA values
                poly_df <- poly_df[!is.na(poly_df$y), ]

                if (nrow(poly_df) > 0) {
                    layers[[length(layers) + 1]] <- annotate(
                        "polygon",
                        x = poly_df$x,
                        y = poly_df$y,
                        color = border,
                        fill = fill
                    )
                }
            }
        }
    }

    return(layers)
}

#' @rdname ghighlightChromPeaks
#' @export
setMethod("ghighlightChromPeaks", "XCMSnExp",
          function(object, chrom_data, rt, mz, peakIds = character(),
                   border = "#00000040", fill = NA,
                   type = c("rect", "point", "polygon"),
                   whichPeaks = c("any", "within", "apex_within"),
                   msLevel = 1L) {
              .ghighlightChromPeaks_impl(object, chrom_data, rt, mz, peakIds,
                                        border, fill, type, whichPeaks, msLevel)
          })

#' @rdname ghighlightChromPeaks
#' @export
setMethod("ghighlightChromPeaks", "XcmsExperiment",
          function(object, chrom_data, rt, mz, peakIds = character(),
                   border = "#00000040", fill = NA,
                   type = c("rect", "point", "polygon"),
                   whichPeaks = c("any", "within", "apex_within"),
                   msLevel = 1L) {
              .ghighlightChromPeaks_impl(object, chrom_data, rt, mz, peakIds,
                                        border, fill, type, whichPeaks, msLevel)
          })
