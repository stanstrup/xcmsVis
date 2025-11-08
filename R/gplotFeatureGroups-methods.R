#' @include AllGenerics.R
NULL

# Shared implementation function for gplotFeatureGroups
#'
#' @importFrom xcms featureGroups featureDefinitions
#' @importFrom ggplot2 ggplot aes geom_point geom_path theme_bw labs coord_cartesian
#' @importFrom tibble tibble
#' @importFrom methods is
#' @keywords internal
.gplotFeatureGroups_impl <- function(x,
                                     xlim = numeric(),
                                     ylim = numeric(),
                                     xlab = "retention time",
                                     ylab = "m/z",
                                     pch = 4,
                                     col = "#00000060",
                                     type = "o",
                                     main = "Feature groups",
                                     featureGroups = character(),
                                     ...) {

    # Validate input object
    if (!(inherits(x, "XCMSnExp") | inherits(x, "XcmsExperiment"))) {
        stop("'x' is supposed to be an xcms result object", call. = FALSE)
    }

    # Check for feature groups
    fgs <- featureGroups(x)
    if (!length(fgs)) {
        stop("No feature groups present. Please run 'groupFeatures' first",
             call. = FALSE)
    }

    # Convert to factor and filter to requested groups
    fts <- factor(fgs)
    if (!length(featureGroups)) {
        featureGroups <- levels(fts)
    }
    fts <- fts[fts %in% featureGroups]
    fts <- droplevels(fts)

    if (!length(fts)) {
        stop("None of the specified feature groups found", call. = FALSE)
    }

    # Get feature definitions for the selected groups
    fdef <- featureDefinitions(x)[featureGroups(x) %in% fts, ]

    # Split rtmed and mzmed by feature group, then sort by m/z within each group
    # This ensures lines go consistently from top to bottom (or bottom to top)
    rts <- split(fdef$rtmed, fts)
    mzs <- split(fdef$mzmed, fts)

    # Sort each group by m/z (descending, so lines go top to bottom)
    # Also track the feature group names for tooltips
    fg_names <- names(rts)
    sorted_data <- lapply(seq_along(rts), function(i) {
        order_idx <- order(mzs[[i]], decreasing = TRUE)
        list(rt = rts[[i]][order_idx], mz = mzs[[i]][order_idx], fg = fg_names[i])
    })
    rts <- lapply(sorted_data, function(x) x$rt)
    mzs <- lapply(sorted_data, function(x) x$mz)

    # Create coordinate vectors with NA separators between groups
    # This is the key technique from XCMS to break line connections between groups
    # For ggplot2, we also need to track which group each point belongs to
    # Use descriptive column names for better plotly tooltips
    xy <- tibble(
        `Retention Time` = unlist(lapply(rts, function(z) c(z, NA)), use.names = FALSE),
        `m/z` = unlist(lapply(mzs, function(z) c(z, NA)), use.names = FALSE),
        # Add group ID - each feature group gets a unique ID, including the NA separator
        group = rep(seq_along(rts), times = sapply(rts, function(z) length(z) + 1)),
        # Add feature group name - this will show nicely in plotly tooltips
        `Feature Group` = rep(fg_names, times = sapply(rts, function(z) length(z) + 1))
    )

    # Calculate axis limits if not provided
    if (length(xlim) != 2) {
        xlim <- range(unlist(rts, use.names = FALSE))
    }
    if (length(ylim) != 2) {
        ylim <- range(unlist(mzs, use.names = FALSE))
    }

    # Create the plot
    # type = "o" means overplotted points and lines
    # type = "l" means lines only
    # type = "p" means points only
    # The 'group' aesthetic ensures lines only connect features within the same group
    # Using backticks for column names with spaces - these show up nicely in plotly tooltips
    # NOTE: Use geom_path() instead of geom_line() because geom_line() sorts by x,
    # but we need to preserve the data order (sorted by m/z within groups)
    p <- ggplot(xy, aes(x = `Retention Time`, y = `m/z`, group = group))

    if (type %in% c("o", "l")) {
        p <- p + geom_path(color = col, na.rm = FALSE, ...)
    }
    if (type %in% c("o", "p")) {
        p <- p + geom_point(color = col, shape = pch, na.rm = TRUE, ...)
    }

    p <- p +
        theme_bw() +
        labs(x = xlab, y = ylab, title = main) +
        coord_cartesian(xlim = xlim, ylim = ylim)

    return(p)
}

#' @rdname gplotFeatureGroups
#' @export
setMethod("gplotFeatureGroups", "XCMSnExp",
          function(x, xlim = numeric(), ylim = numeric(),
                   xlab = "retention time", ylab = "m/z",
                   pch = 4, col = "#00000060", type = "o",
                   main = "Feature groups", featureGroups = character(),
                   ...) {
              .gplotFeatureGroups_impl(x, xlim, ylim, xlab, ylab,
                                      pch, col, type, main, featureGroups, ...)
          })

#' @rdname gplotFeatureGroups
#' @export
setMethod("gplotFeatureGroups", "XcmsExperiment",
          function(x, xlim = numeric(), ylim = numeric(),
                   xlab = "retention time", ylab = "m/z",
                   pch = 4, col = "#00000060", type = "o",
                   main = "Feature groups", featureGroups = character(),
                   ...) {
              .gplotFeatureGroups_impl(x, xlim, ylim, xlab, ylab,
                                      pch, col, type, main, featureGroups, ...)
          })
