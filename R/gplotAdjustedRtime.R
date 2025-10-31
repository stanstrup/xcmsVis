#' ggplot2 Version of plotAdjustedRtime
#'
#' @description
#' Visualizes retention time correction by plotting the difference between
#' adjusted and raw retention times across samples. This is a ggplot2
#' implementation of XCMS's `plotAdjustedRtime()` function, enabling
#' modern visualization and interactive plotting capabilities.
#'
#' @param object An `XCMSnExp` object with retention time adjustment results.
#' @param color_by Column name from `pData(object)` to use for coloring lines.
#'   This should be provided as an unquoted column name (e.g., `sample_group`).
#' @param include_columns Character vector of column names from `pData(object)`
#'   to include in the tooltip text. If `NULL` (default), all columns are included.
#' @param adjustedRtime Logical, whether to use adjusted retention times on the
#'   x-axis. Default is `TRUE`.
#'
#' @return A `ggplot` object showing retention time adjustment. Each line
#'   represents one sample, and grey points/lines show the peak groups used
#'   for alignment (when using PeakGroupsParam).
#'
#' @details
#' The function:
#' \itemize{
#'   \item Plots adjusted RT vs. the difference (adjusted RT - raw RT)
#'   \item Shows one line per sample colored by the specified variable
#'   \item Overlays peak groups used for alignment (grey circles and dashed lines)
#'   \item Includes tooltip-ready text for interactive plotting with plotly
#' }
#'
#' The grey circles represent individual peaks that were used for alignment,
#' and the grey dashed lines connect peaks from the same feature across samples.
#'
#' @examples
#' \dontrun{
#' library(xcmsVis)
#' library(xcms)
#'
#' # After performing XCMS workflow with retention time correction
#' p <- gplotAdjustedRtime(xdata, color_by = sample_group)
#' print(p)
#'
#' # Make interactive
#' library(plotly)
#' ggplotly(p, tooltip = "text")
#' }
#'
#' @seealso
#' \code{\link[xcms]{plotAdjustedRtime}} for the original XCMS implementation
#'
#' @export
#' @importFrom methods is
#' @importFrom xcms rtime hasAdjustedRtime fromFile pData processHistory processParam chromPeaks chromPeakData featureDefinitions fileNames
#' @importFrom tibble tibble
#' @importFrom tidyr separate pivot_wider pivot_longer unnest
#' @importFrom dplyr %>% mutate filter select bind_rows bind_cols right_join group_by group_nest
#' @importFrom purrr map map_lgl pluck map2
#' @importFrom ggplot2 ggplot aes geom_line geom_point theme_bw
gplotAdjustedRtime <- function(object,
                                color_by,
                                include_columns = NULL,
                                adjustedRtime = TRUE) {

  # Input validation
  if (!is(object, "XCMSnExp")) {
    stop("'object' has to be an 'XCMSnExp' object.")
  }

  if (!hasAdjustedRtime(object)) {
    warning("No alignment/retention time correction results present.")
  }

  # Get raw and adjusted retention times
  rt_noadj <- rtime(object, adjusted = FALSE, bySample = FALSE) %>%
    {tibble(names = names(.), rt = .)} %>%
    separate(col = "names", sep = "\\.", into = c("fromFile", "spectrum"))

  rt_adj <- rtime(object, adjusted = adjustedRtime, bySample = FALSE) %>%
    {tibble(names = names(.), rt = .)} %>%
    separate(col = "names", sep = "\\.", into = c("fromFile", "spectrum"))

  from_files <- fromFile(object) %>%
    names() %>%
    unique() %>%
    gsub("F(.*)\\..*", "\\1", .) %>%
    unique() %>%
    as.numeric()

  # Combine raw and adjusted retention times
  rts <- bind_rows(raw = rt_noadj, adjusted = rt_adj, .id = "adjusted") %>%
    pivot_wider(
      id_cols = c("fromFile", "spectrum"),
      names_from = adjusted,
      values_from = rt
    ) %>%
    mutate(fromFile = as.integer(gsub("^F(.*)", "\\1", fromFile)))

  # Add sample metadata
  rts <- pData(object) %>%
    mutate(fromFile = from_files) %>%
    right_join(rts, by = "fromFile", multiple = "all")

  # Find which process step used PeakGroupsParam
  which_is_groups <- object %>%
    processHistory() %>%
    map(processParam) %>%
    map_lgl(is, "PeakGroupsParam") %>%
    which()

  # Extract peak groups used for alignment
  subset_selected <- object %>%
    processHistory() %>%
    map(processParam) %>%
    pluck(which_is_groups)

  subset_selected <- subset_selected@subset

  files <- from_files[subset_selected]

  # Get the peak groups matrix and prepare for plotting
  pkGroup <- object %>%
    processHistory() %>%
    map(processParam) %>%
    pluck(which_is_groups) %>%
    xcms:::peakGroupsMatrix() %>%
    as.data.frame() %>%
    setNames(., files) %>%
    tibble::rownames_to_column("feature") %>%
    tibble::as_tibble() %>%
    pivot_longer(-feature, names_to = "fromFile", values_to = "rtime") %>%
    mutate(fromFile = as.integer(fromFile)) %>%
    group_by(fromFile) %>%
    group_nest(.key = "feature")

  # Calculate adjusted retention times for peak groups
  good_peaks <- rts %>%
    select(fromFile, raw, adjusted) %>%
    group_by(fromFile) %>%
    group_nest(.key = "correction") %>%
    right_join(pkGroup, by = "fromFile") %>%
    mutate(
      feature_correct = map2(
        feature, correction,
        ~ tibble(
          adjusted = xcms:::.applyRtAdjustment(
            ..1$rtime, ..2$raw, ..2$adjusted
          )
        )
      )
    ) %>%
    select(-correction) %>%
    unnest(cols = c(feature, feature_correct)) %>%
    dplyr::rename(raw = rtime) %>%
    filter(!is.na(raw))

  # Add tooltip text for interactive plotting
  if (is.null(include_columns)) {
    include_columns <- colnames(pData(object))
  }

  rts <- rts %>%
    select(all_of(include_columns)) %>%
    purrr::imap_dfr(~ paste(.y, .x, sep = ": ")) %>%
    tidyr::unite(text, sep = "<br>") %>%
    bind_cols(rts, .)

  # Create the plot
  p <- ggplot(
    data = rts,
    aes(
      x = adjusted,
      y = adjusted - raw,
      group = fromFile,
      color = {{ color_by }},
      text = text
    )
  ) +
    geom_line() +
    theme_bw() +
    geom_point(
      data = good_peaks,
      aes(x = adjusted, y = adjusted - raw),
      inherit.aes = FALSE,
      color = "grey",
      shape = 1
    ) +
    geom_line(
      data = good_peaks,
      aes(x = adjusted, y = adjusted - raw, group = feature),
      inherit.aes = FALSE,
      color = "grey",
      linetype = 2
    )

  return(p)
}
