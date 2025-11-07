#' @include AllGenerics.R
NULL

#' Helper function to compute density and find feature groups
#'
#' @keywords internal
.compute_peak_density <- function(pks, param) {
    bw_param <- param@bw
    full_rt_range <- range(pks[, "rt"])
    dens_from <- full_rt_range[1] - 3 * bw_param
    dens_to <- full_rt_range[2] + 3 * bw_param
    densN <- max(512, 2 * 2^(ceiling(log2(diff(full_rt_range) / (bw_param / 2)))))

    dens <- stats::density(pks[, "rt"], bw = bw_param, from = dens_from,
                           to = dens_to, n = densN)

    list(
        x = dens$x,
        y = dens$y,
        bw = bw_param,
        from = dens_from,
        to = dens_to
    )
}

#' Helper function to simulate feature grouping based on peak density
#'
#' @keywords internal
.simulate_feature_groups <- function(pks, dens_x, dens_y, param) {
    # Determine which column has sample info
    smpl_col <- which(colnames(pks) == "sample")
    if (!length(smpl_col))
        smpl_col <- which(colnames(pks) == "column")

    sample_groups <- param@sampleGroups
    if (length(sample_groups) == 0) {
        sample_groups <- rep(1, max(pks[, smpl_col]))
    }
    sample_groups_table <- table(sample_groups)

    dens_max <- max(dens_y)
    dens_y_copy <- dens_y

    feature_list <- list()
    snum <- 0

    while (dens_y_copy[max_y <- which.max(dens_y_copy)] > dens_max / 20 &&
           snum < param@maxFeatures) {
        # Use XCMS internal descendMin function
        feat_range <- xcms:::descendMin(dens_y_copy, max_y)
        dens_y_copy[feat_range[1]:feat_range[2]] <- 0

        feat_idx <- which(pks[, "rt"] >= dens_x[feat_range[1]] &
                          pks[, "rt"] <= dens_x[feat_range[2]])

        tt <- table(sample_groups[unique(pks[feat_idx, smpl_col])])

        if (!any(tt / sample_groups_table[names(tt)] >=
                 param@minFraction & tt >= param@minSamples))
            next

        snum <- snum + 1L
        feature_list[[snum]] <- data.frame(
            rtmin = min(pks[feat_idx, "rt"]),
            rtmax = max(pks[feat_idx, "rt"]),
            feature_id = snum
        )
    }

    if (length(feature_list) > 0) {
        do.call(rbind, feature_list)
    } else {
        data.frame(rtmin = numeric(), rtmax = numeric(), feature_id = integer())
    }
}

#' Shared implementation function for gplotChromPeakDensity
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_line geom_rect geom_vline
#'   geom_segment theme_bw labs scale_y_continuous theme element_blank
#' @importFrom patchwork plot_layout wrap_plots
#' @importFrom xcms chromPeaks hasChromPeaks hasFeatures featureDefinitions
#'   processHistory rtime
#' @importFrom methods is
#' @keywords internal
.gplotChromPeakDensity_impl <- function(object,
                                         param,
                                         col = "#00000060",
                                         xlab = "retention time",
                                         main = NULL,
                                         peakType = c("polygon", "point", "rectangle", "none"),
                                         peakCol = "#00000060",
                                         peakBg = "#00000020",
                                         peakPch = 1,
                                         simulate = TRUE,
                                         ...) {

    peakType <- match.arg(peakType)

    # Validate object
    if (!any(xcms::hasChromPeaks(object)))
        stop("No chromatographic peaks present. Please run 'findChromPeaks' first.",
             call. = FALSE)

    if (nrow(object) > 1)
        stop("Currently only plotting of a single chromatogram in multiple samples ",
             "is supported. Please subset 'object' to one row.", call. = FALSE)

    # Get or validate param
    if (missing(param)) {
        param <- NULL
        if (xcms::hasFeatures(object)) {
            ph <- xcms::processHistory(object, type = "Peak grouping")
            if (length(ph)) {
                ph <- ph[[length(ph)]]
                if (is(ph, "XProcessHistory") &&
                    is(ph@param, "PeakDensityParam"))
                    param <- ph@param
            }
        }
    }

    if (!length(param))
        stop("Object 'param' is missing", call. = FALSE)

    # Get feature definitions if not simulating
    fts <- NULL
    if (!simulate && xcms::hasFeatures(object))
        fts <- xcms::featureDefinitions(object)

    # Get retention time range for x-axis limits
    xl <- range(lapply(object, function(z) range(xcms::rtime(z))))

    # Create upper panel: chromatogram plot
    p_upper <- gplot(object, col = col, xlab = "", main = main,
                     peakType = peakType, peakCol = peakCol,
                     peakBg = peakBg, peakPch = peakPch, ...) +
        theme(axis.title.x = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank())

    # Create lower panel: peak density plot
    pks <- xcms::chromPeaks(object)

    # Determine which column has sample info
    smpl_col <- which(colnames(pks) == "sample")
    if (!length(smpl_col))
        smpl_col <- which(colnames(pks) == "column")

    # Calculate density
    dens <- .compute_peak_density(pks, param)

    # Prepare data for plotting
    min_max_smple <- c(1, ncol(object))
    yl <- c(0, max(dens$y))
    ypos <- seq(from = yl[1], to = yl[2],
                length.out = diff(min_max_smple) + 1)

    # Create peak points data frame
    peaks_df <- data.frame(
        rt = pks[, "rt"],
        sample = pks[, smpl_col],
        y = ypos[pks[, smpl_col]]
    )

    # Create density line data frame
    dens_df <- data.frame(
        x = dens$x,
        y = dens$y
    )

    # Prepare feature rectangles data (if applicable) - must be added FIRST as bottom layer
    features <- NULL
    if (simulate) {
        # Simulate feature grouping
        features <- .simulate_feature_groups(pks, dens$x, dens$y, param)
    } else if (!is.null(fts) && nrow(fts) > 0) {
        features <- as.data.frame(fts)
    }

    # Start building lower plot - rectangles MUST be first layer (drawn behind points/lines)
    p_lower <- ggplot()

    # Add feature rectangles as FIRST layer (background)
    if (!is.null(features) && nrow(features) > 0) {
        p_lower <- p_lower +
            geom_rect(data = features,
                      aes(xmin = rtmin, xmax = rtmax,
                          ymin = yl[1], ymax = yl[2]),
                      fill = "#00000020", color = "#00000040",
                      inherit.aes = FALSE)
        # Add median lines for actual correspondence results
        if (!simulate && !is.null(fts)) {
            p_lower <- p_lower +
                geom_vline(data = features, aes(xintercept = rtmed),
                           color = "#00000040", linetype = 2)
        }
    } else if (!simulate) {
        warning("No feature definitions present. Either use 'groupChromPeaks' ",
                "first or set 'simulate = TRUE'")
    }

    # Add vertical segments from y=0 to sample position, then points, then density line
    p_lower <- p_lower +
        geom_segment(data = peaks_df, aes(x = rt, xend = rt, y = 0, yend = y),
                     color = peakCol) +
        geom_point(data = peaks_df, aes(x = rt, y = y),
                   color = peakCol, fill = peakBg, shape = peakPch) +
        geom_point(data = peaks_df, aes(x = rt, y = 0),
                   color = peakCol, fill = peakBg, shape = peakPch) +
        geom_line(data = dens_df, aes(x = x, y = y)) +
        scale_y_continuous(
            breaks = ypos,
            labels = seq(from = min_max_smple[1], to = min_max_smple[2])
        ) +
        labs(x = xlab, y = "sample") +
        theme_bw() +
        xlim(xl)

    # Combine panels using patchwork
    p_combined <- p_upper / p_lower +
        plot_layout(heights = c(1, 1))

    return(p_combined)
}

#' @rdname gplotChromPeakDensity
#' @export
setMethod("gplotChromPeakDensity", "XChromatograms",
          function(object, param, col = "#00000060", xlab = "retention time",
                   main = NULL, peakType = c("polygon", "point", "rectangle", "none"),
                   peakCol = "#00000060", peakBg = "#00000020", peakPch = 1,
                   simulate = TRUE, ...) {

              .gplotChromPeakDensity_impl(object = object, param = param,
                                          col = col, xlab = xlab, main = main,
                                          peakType = peakType, peakCol = peakCol,
                                          peakBg = peakBg, peakPch = peakPch,
                                          simulate = simulate, ...)
          })

#' @rdname gplotChromPeakDensity
#' @export
setMethod("gplotChromPeakDensity", "MChromatograms",
          function(object, param, col = "#00000060", xlab = "retention time",
                   main = NULL, peakType = c("polygon", "point", "rectangle", "none"),
                   peakCol = "#00000060", peakBg = "#00000020", peakPch = 1,
                   simulate = TRUE, ...) {

              # Convert MChromatograms to XChromatograms if needed
              # MChromatograms should work the same way as XChromatograms
              .gplotChromPeakDensity_impl(object = object, param = param,
                                          col = col, xlab = xlab, main = main,
                                          peakType = peakType, peakCol = peakCol,
                                          peakBg = peakBg, peakPch = peakPch,
                                          simulate = simulate, ...)
          })
