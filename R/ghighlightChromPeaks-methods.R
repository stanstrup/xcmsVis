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
        # For polygon, replicate the exact behavior of xcms::highlightChromPeaks
        # Extract chromatograms for the entire mz range (not per-peak mz)
        if (nrow(pks) > 0) {
            # Get sample column name
            if ("sample" %in% colnames(pks)) {
                sample_col <- "sample"
            } else {
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

            # Extract chromatograms for the entire mz range across all samples
            # This matches: chrs <- chromatogram(x, rt = range(pks[, c("rtmin", "rtmax")]), mz = mz)
            rt_range <- range(pks[, c("rtmin", "rtmax")])
            chrs <- chromatogram(object, rt = rt_range, mz = mz)

            # Order peaks by maxo (descending) to draw largest peaks first
            pks <- pks[order(pks[, "maxo"], decreasing = TRUE), , drop = FALSE]

            # For each peak, filter the chromatogram and create polygon
            for (j in seq_len(nrow(pks))) {
                i <- pks[j, sample_col]
                peak_rt_range <- c(pks[j, "rtmin"], pks[j, "rtmax"])

                # Get the chromatogram for this sample
                chr <- chrs[1, i]

                # Filter chromatogram to peak RT range
                chr_rt <- rtime(chr)
                chr_int <- intensity(chr)

                # Filter to peak region
                idx <- which(chr_rt >= peak_rt_range[1] & chr_rt <= peak_rt_range[2])

                if (length(idx) > 0) {
                    xs <- chr_rt[idx]
                    ys <- chr_int[idx]

                    # Close the polygon: add endpoints at baseline
                    xs <- c(xs, xs[length(xs)], xs[1])
                    ys <- c(ys, 0, 0)

                    # Remove NA values
                    nona <- !is.na(ys)

                    if (sum(nona) > 0) {
                        poly_df <- data.frame(
                            rt = xs[nona],
                            intensity = ys[nona]
                        )

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
