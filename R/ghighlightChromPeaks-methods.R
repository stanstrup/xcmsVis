#' @include AllGenerics.R
NULL

# Shared implementation function for ghighlightChromPeaks
#'
#' @importFrom xcms chromPeaks hasChromPeaks rtime intensity chromatogram
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
        # For polygon, we need to extract chromatogram data for each peak
        # Get sample information for each peak
        if ("sample" %in% colnames(pks)) {
            sample_col <- "sample"
        } else {
            # For XCMSnExp, the column might be named differently
            sample_col <- NULL
            for (col in c("sample", "fileIdx")) {
                if (col %in% colnames(pks)) {
                    sample_col <- col
                    break
                }
            }
            if (is.null(sample_col)) {
                stop("Cannot determine sample column in chromPeaks matrix",
                     call. = FALSE)
            }
        }

        # For each peak, extract its chromatogram and create polygon
        for (i in seq_len(nrow(pks))) {
            peak_sample <- pks[i, sample_col]
            peak_mz_range <- c(pks[i, "mzmin"], pks[i, "mzmax"])
            peak_rt_range <- c(pks[i, "rtmin"], pks[i, "rtmax"])

            # Extract chromatogram for this peak's sample and m/z range
            # Expand RT range slightly to ensure we get the full peak shape
            rt_expand <- diff(peak_rt_range) * 0.1
            chr_rt_range <- c(peak_rt_range[1] - rt_expand,
                             peak_rt_range[2] + rt_expand)

            # Extract chromatogram
            chr <- tryCatch({
                chromatogram(object,
                           mz = peak_mz_range,
                           rt = chr_rt_range)[1, peak_sample]
            }, error = function(e) {
                NULL
            })

            if (!is.null(chr) && length(rtime(chr)) > 0) {
                # Get chromatogram data
                chrom_rt <- rtime(chr)
                chrom_int <- intensity(chr)

                # Filter to peak region
                idx <- which(chrom_rt >= peak_rt_range[1] &
                           chrom_rt <= peak_rt_range[2])

                if (length(idx) > 0) {
                    peak_chrom <- data.frame(
                        rt = chrom_rt[idx],
                        intensity = chrom_int[idx]
                    )

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
    }

    return(layers)
}

#' @rdname ghighlightChromPeaks
#' @export
setMethod("ghighlightChromPeaks", "XCMSnExp",
          function(object, rt, mz, peakIds = character(),
                   border = "#00000040", fill = NA,
                   type = c("rect", "point", "polygon"),
                   whichPeaks = c("any", "within", "apex_within")) {
              .ghighlightChromPeaks_impl(object, rt, mz, peakIds,
                                        border, fill, type, whichPeaks)
          })

#' @rdname ghighlightChromPeaks
#' @export
setMethod("ghighlightChromPeaks", "XcmsExperiment",
          function(object, rt, mz, peakIds = character(),
                   border = "#00000040", fill = NA,
                   type = c("rect", "point", "polygon"),
                   whichPeaks = c("any", "within", "apex_within")) {
              .ghighlightChromPeaks_impl(object, rt, mz, peakIds,
                                        border, fill, type, whichPeaks)
          })
