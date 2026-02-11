#' @include AllGenerics.R
NULL

# Shared implementation function for gplotChromPeakImage
#'
#' @importFrom xcms chromPeaks fileNames hasChromPeaks
#' @importFrom ggplot2 ggplot aes geom_tile theme_bw labs
#' @importFrom ggplot2 scale_fill_viridis_c scale_y_discrete coord_cartesian
#' @importFrom tibble tibble
#' @importFrom tidyr expand_grid
#' @importFrom dplyr mutate group_by summarise left_join n
#' @importFrom methods is
#'
#' @keywords internal
#'
#' @noRd
.gplotChromPeakImage_impl <- function(object,
                                      binSize = 30,
                                      xlim = NULL,
                                      log_transform = FALSE,
                                      msLevel = 1L) {
    .validate_xcms_object(object)
    if (!hasChromPeaks(object))
        stop("No chromatographic peaks found in object. ",
             "Run findChromPeaks() first.", call. = FALSE)
    if (is.null(xlim))
        xlim <- c(floor(min(rtime(object))), ceiling(max(rtime(object))))
    brks <- seq(xlim[1], xlim[2], by = binSize)
    if (brks[length(brks)] < xlim[2])
        brks <- c(brks, brks[length(brks)] + binSize)
    pks <- chromPeaks(object, rt = xlim, msLevel = msLevel)
    file_names <- basename(fileNames(object))
    n_samples <- length(file_names)
    if (nrow(pks) > 0) {
        pks_df <- tibble(
            rt = pks[, "rt"],
            sample = pks[, "sample"])
        pks_df <- pks_df %>%
            mutate(rt_bin = cut(rt, breaks = brks, include.lowest = TRUE,
                                labels = FALSE)) %>%
            group_by(sample, rt_bin) %>%
            summarise(count = n(), .groups = "drop")
        all_combinations <- expand_grid(
            sample = seq_len(n_samples),
            rt_bin = seq_len(length(brks) - 1)
        )
        counts_df <- all_combinations %>%
            left_join(pks_df, by = c("sample", "rt_bin")) %>%
            mutate(count = ifelse(is.na(count), 0, count))
        counts_df <- counts_df %>%
            mutate(
                sample_name = file_names[sample],
                rt_center = brks[rt_bin] + binSize / 2
            )
        if (log_transform) {
            counts_df <- counts_df %>%
                mutate(count = log2(count + 1))  # Add 1 to avoid log(0)
        }
    } else {
        counts_df <- expand_grid(
            sample = seq_len(n_samples),
            rt_bin = seq_len(length(brks) - 1)
        ) %>%
            mutate(
                count = 0,
                sample_name = file_names[sample],
                rt_center = brks[rt_bin] + binSize / 2
            )
    }
    p <- ggplot(counts_df, aes(x = rt_center, y = sample_name, fill = count)) +
        geom_tile() +
        scale_fill_viridis_c(
            name = if (log_transform) "log2(count)" else "count",
            direction = -1
        ) +
        scale_y_discrete(limits = rev(file_names)) +
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
#'
#' @export
setMethod("gplotChromPeakImage", "XCMSnExp",
          function(object, binSize = 30, xlim = NULL,
                   log_transform = FALSE, msLevel = 1L) {
              .gplotChromPeakImage_impl(object, binSize, xlim,
                                        log_transform, msLevel)
          })

#' @rdname gplotChromPeakImage
#'
#' @export
setMethod("gplotChromPeakImage", "XcmsExperiment",
          function(object, binSize = 30, xlim = NULL,
                   log_transform = FALSE, msLevel = 1L) {
              .gplotChromPeakImage_impl(object, binSize, xlim,
                                        log_transform, msLevel)
          })
