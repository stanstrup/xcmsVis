#' @include AllGenerics.R
NULL

# Declare global variables to avoid R CMD check NOTE
utils::globalVariables(c("Retention Time", "m/z", "group", "feature_group"))

# Shared implementation function for gplotFeatureGroups
#'
#' @importFrom xcms featureGroups featureDefinitions
#' @importFrom ggplot2 ggplot aes geom_point geom_path theme_bw labs
#' @importFrom ggplot2 coord_cartesian
#' @importFrom tibble tibble
#' @importFrom methods is
#'
#' @keywords internal
#'
#' @noRd
.gplotFeatureGroups_impl <- function(x,
                                     xlim = numeric(),
                                     ylim = numeric(),
                                     pch = 4,
                                     col = "#00000060",
                                     type = "o",
                                     featureGroups = character(),
                                     ...) {
    fgs <- featureGroups(x)
    if (all(is.na(fgs)))
        stop("No feature groups present. Please run 'groupFeatures' first",
             call. = FALSE)
    fts <- factor(fgs)
    if (!length(featureGroups))
        featureGroups <- levels(fts)
    fts <- fts[fts %in% featureGroups]
    fts <- droplevels(fts)
    if (!length(fts))
        stop("None of the specified feature groups found", call. = FALSE)
    fdef <- featureDefinitions(x)[featureGroups(x) %in% fts, ]
    ## Split rtmed and mzmed by feature group and sort by m/z within each group
    ## This ensures lines go consistently from top to bottom (or bottom to top)
    rts <- split(fdef$rtmed, fts)
    mzs <- split(fdef$mzmed, fts)
    fg_names <- names(rts)
    sorted_data <- lapply(seq_along(rts), function(i) {
        order_idx <- order(mzs[[i]], decreasing = TRUE)
        list(rt = rts[[i]][order_idx], mz = mzs[[i]][order_idx],
             fg = fg_names[i])
    })
    rts <- lapply(sorted_data, function(x) x$rt)
    mzs <- lapply(sorted_data, function(x) x$mz)
    ## Create coordinate vectors with NA separators between groups to break
    ## line connections between groups
    ## For ggplot2, we also need to track which group each point belongs to
    xy <- tibble(
        `Retention Time` = unlist(lapply(rts, function(z) c(z, NA)),
                                  use.names = FALSE),
        `m/z` = unlist(lapply(mzs, function(z) c(z, NA)), use.names = FALSE),
        ## Add group ID - each feature group (and NA) gets a unique ID.
        group = rep(seq_along(rts), times = lengths(rts) + 1L),
        ## Add feature group name for text aesthetic
        feature_group = rep(fg_names, times = lengths(rts) + 1L),
        text = paste0("Feature Group: ", feature_group)
    )
    if (length(xlim) != 2)
        xlim <- range(unlist(rts, use.names = FALSE))
    if (length(ylim) != 2)
        ylim <- range(unlist(mzs, use.names = FALSE))
    ## Create the plot
    ## type = "o" means overplotted points and lines
    ## type = "l" means lines only
    ## type = "p" means points only
    ## The 'group' aesthetic ensures lines connect features of the same group
    ## The 'text' aesthetic shows Feature Group in plotly tooltips
    ## NOTE: Use geom_path() instead of geom_line() because geom_line() sorts
    ## by x, but we need to preserve the data order (sorted by m/z within group)
    p <- ggplot(xy, aes(x = `Retention Time`, y = `m/z`,
                        group = group, text = text))
    if (type %in% c("o", "l"))
        p <- p + .geom_path_text(color = col, na.rm = FALSE, ...)
    if (type %in% c("o", "p"))
        p <- p + .geom_point_text(color = col, shape = pch, na.rm = TRUE, ...)
    p <- p +
        theme_bw() +
        labs(x = "retention time", y = "m/z", title = "Feature groups") +
        coord_cartesian(xlim = xlim, ylim = ylim)
    return(p)
}

#' @rdname gplotFeatureGroups
#'
#' @export
setMethod("gplotFeatureGroups", "XCMSnExp",
          function(x,
                   xlim = numeric(),
                   ylim = numeric(),
                   pch = 4,
                   col = "#00000060",
                   type = "o",
                   featureGroups = character(),
                   ...) {
              .gplotFeatureGroups_impl(x, xlim, ylim, pch, col, type,
                                       featureGroups, ...)
          })

#' @rdname gplotFeatureGroups
#'
#' @export
setMethod("gplotFeatureGroups", "XcmsExperiment",
          function(x,
                   xlim = numeric(),
                   ylim = numeric(),
                   pch = 4,
                   col = "#00000060",
                   type = "o",
                   featureGroups = character(),
                   ...) {
              .gplotFeatureGroups_impl(x, xlim, ylim, pch, col, type,
                                       featureGroups, ...)
          })
