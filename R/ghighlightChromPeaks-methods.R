#' @include AllGenerics.R
NULL

# Shared implementation function for ghighlightChromPeaks
#'
#' @importFrom xcms chromPeaks hasChromPeaks rtime intensity
#' @importFrom ggplot2 geom_rect geom_point geom_polygon aes
#' @importFrom tibble tibble
#' @importFrom methods is
#' @keywords internal
.ghighlightChromPeaks_impl <- function(object,
                                       rt,
                                       mz,
                                       peakIds = character(),
                                       border = "#00000040",
                                       fill = NA,
                                       type = c("rect", "point", "polygon"),
                                       whichPeaks = c("any", "within", "apex_within")) {

    type <- match.arg(type)
    whichPeaks <- match.arg(whichPeaks)

    # Check that peaks exist
    if (!hasChromPeaks(object)) {
        stop("No chromatographic peaks found in object. ",
             "Run findChromPeaks() first.", call. = FALSE)
    }

    # Get all peaks from the chromatogram
    pks <- chromPeaks(object)

    # Return empty list if no peaks
    if (nrow(pks) == 0) {
        return(list())
    }

    # Handle peakIds or filtering
    if (length(peakIds) > 0) {
        # Use specific peak IDs
        if (!all(peakIds %in% rownames(pks))) {
            stop("'peakIds' do not match rownames of 'chromPeaks(object)'",
                 call. = FALSE)
        }
        pks <- pks[peakIds, , drop = FALSE]
    } else if (!missing(rt) || !missing(mz)) {
        # Filter peaks by rt and/or mz
        if (!missing(rt)) {
            if (whichPeaks == "within") {
                keep <- pks[, "rtmin"] >= rt[1] & pks[, "rtmax"] <= rt[2]
            } else if (whichPeaks == "apex_within") {
                keep <- pks[, "rt"] >= rt[1] & pks[, "rt"] <= rt[2]
            } else {  # "any"
                keep <- pks[, "rtmax"] >= rt[1] & pks[, "rtmin"] <= rt[2]
            }
            pks <- pks[keep, , drop = FALSE]
        }

        if (!missing(mz) && nrow(pks) > 0) {
            if (whichPeaks == "within") {
                keep <- pks[, "mzmin"] >= mz[1] & pks[, "mzmax"] <= mz[2]
            } else if (whichPeaks == "apex_within") {
                keep <- pks[, "mz"] >= mz[1] & pks[, "mz"] <= mz[2]
            } else {  # "any"
                keep <- pks[, "mzmax"] >= mz[1] & pks[, "mzmin"] <= mz[2]
            }
            pks <- pks[keep, , drop = FALSE]
        }
    }

    # Return empty list if no peaks after filtering
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
        # For polygon, extract chromatogram data from the object
        chrom_rt <- rtime(object)
        chrom_int <- intensity(object)
        chrom_df <- data.frame(rt = chrom_rt, intensity = chrom_int)

        # For each peak, extract the chromatogram region and create polygon
        for (i in seq_len(nrow(pks))) {
            peak_rt_range <- c(pks[i, "rtmin"], pks[i, "rtmax"])

            # Filter chromatogram data to peak region
            idx <- which(chrom_df$rt >= peak_rt_range[1] &
                        chrom_df$rt <= peak_rt_range[2])

            if (length(idx) > 0) {
                peak_chrom <- chrom_df[idx, ]

                # Create polygon coordinates (close the shape at baseline)
                poly_df <- rbind(
                    data.frame(rt = peak_rt_range[1], intensity = 0),
                    peak_chrom,
                    data.frame(rt = peak_rt_range[2], intensity = 0)
                )

                # Remove NA values
                poly_df <- poly_df[!is.na(poly_df$intensity), ]

                if (nrow(poly_df) > 0) {
                    layers[[length(layers) + 1]] <- geom_polygon(
                        data = poly_df,
                        aes(x = rt, y = intensity),
                        color = border,
                        fill = fill,
                        inherit.aes = FALSE
                    )
                }
            }
        }
    }

    return(layers)
}

#' @rdname ghighlightChromPeaks
#' @export
setMethod("ghighlightChromPeaks", "XChromatogram",
          function(object, rt, mz, peakIds = character(),
                   border = "#00000040", fill = NA,
                   type = c("rect", "point", "polygon"),
                   whichPeaks = c("any", "within", "apex_within")) {
              .ghighlightChromPeaks_impl(object, rt, mz, peakIds,
                                        border, fill, type, whichPeaks)
          })
