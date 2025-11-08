#' @include AllGenerics.R
NULL

# Shared implementation function for gplotChromPeakImage
#'
#' @importFrom xcms chromPeaks rtime fileNames hasChromPeaks
#' @importFrom ggplot2 ggplot aes geom_tile theme_bw labs scale_fill_viridis_c scale_y_discrete coord_cartesian
#' @importFrom tibble tibble
#' @importFrom tidyr expand_grid
#' @importFrom dplyr mutate group_by summarise left_join n
#' @importFrom methods is
#' @keywords internal
.gplotChromPeakImage_impl <- function(object,
                                      binSize = 30,
                                      xlim = NULL,
                                      log_transform = FALSE,
                                      msLevel = 1L) {

    .validate_xcms_object(object)

    # Check that peaks exist
    if (!hasChromPeaks(object)) {
        stop("No chromatographic peaks found in object. ",
             "Run findChromPeaks() first.", call. = FALSE)
    }

    # Get retention time range
    if (is.null(xlim)) {
        xlim <- c(floor(min(rtime(object))), ceiling(max(rtime(object))))
    }

    # Create bins
    brks <- seq(xlim[1], xlim[2], by = binSize)
    if (brks[length(brks)] < xlim[2]) {
        brks <- c(brks, brks[length(brks)] + binSize)
    }

    # Get peaks within xlim
    pks <- chromPeaks(object, rt = xlim, msLevel = msLevel)

    # Get file names
    file_names <- basename(fileNames(object))
    n_samples <- length(file_names)

    if (nrow(pks) > 0) {
        # Create data frame with peak retention times and sample indices
        pks_df <- tibble(
            rt = pks[, "rt"],
            sample = pks[, "sample"]
        )

        # Bin peaks and count per sample
        pks_df <- pks_df %>%
            mutate(rt_bin = cut(rt, breaks = brks, include.lowest = TRUE,
                               labels = FALSE)) %>%
            group_by(sample, rt_bin) %>%
            summarise(count = n(), .groups = "drop")

        # Create complete grid of all samples and bins
        all_combinations <- expand_grid(
            sample = 1:n_samples,
            rt_bin = 1:(length(brks) - 1)
        )

        # Join with counts (missing combinations will have NA)
        counts_df <- all_combinations %>%
            left_join(pks_df, by = c("sample", "rt_bin")) %>%
            mutate(count = ifelse(is.na(count), 0, count))

        # Add sample names and bin centers
        counts_df <- counts_df %>%
            mutate(
                sample_name = file_names[sample],
                rt_center = brks[rt_bin] + binSize / 2
            )

        # Apply log transformation if requested
        if (log_transform) {
            counts_df <- counts_df %>%
                mutate(count = log2(count + 1))  # Add 1 to avoid log(0)
        }

    } else {
        # No peaks found - create empty data frame
        counts_df <- expand_grid(
            sample = 1:n_samples,
            rt_bin = 1:(length(brks) - 1)
        ) %>%
            mutate(
                count = 0,
                sample_name = file_names[sample],
                rt_center = brks[rt_bin] + binSize / 2
            )
    }

    # Create the plot
    p <- ggplot(counts_df, aes(x = rt_center, y = sample_name, fill = count)) +
        geom_tile() +
        scale_fill_viridis_c(
            name = if (log_transform) "log2(count)" else "count",
            direction = -1  # Reverse scale: higher values = darker (match original XCMS)
        ) +
        scale_y_discrete(limits = rev(file_names)) +  # Reverse to match original
        theme_bw() +
        labs(
            x = "retention time",
            y = NULL,
            title = "Chromatographic peak counts"
        ) +
        coord_cartesian(xlim = xlim)

    return(p)
}

#' @rdname gplotChromPeakImage
#' @export
setMethod("gplotChromPeakImage", "XCMSnExp",
          function(object, binSize = 30, xlim = NULL,
                   log_transform = FALSE, msLevel = 1L) {
              .gplotChromPeakImage_impl(object, binSize, xlim,
                                       log_transform, msLevel)
          })

#' @rdname gplotChromPeakImage
#' @export
setMethod("gplotChromPeakImage", "XcmsExperiment",
          function(object, binSize = 30, xlim = NULL,
                   log_transform = FALSE, msLevel = 1L) {
              .gplotChromPeakImage_impl(object, binSize, xlim,
                                       log_transform, msLevel)
          })
