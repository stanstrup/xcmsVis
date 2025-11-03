#' ggplot2 Version of plotAdjustedRtime
#'
#' @description
#' Visualizes retention time correction by plotting the difference between
#' adjusted and raw retention times across samples. This is a ggplot2
#' implementation of XCMS's `plotAdjustedRtime()` function, enabling
#' modern visualization and interactive plotting capabilities.
#'
#' @param object An `XCMSnExp` or `XcmsExperiment` object with retention time
#'   adjustment results.
#' @param color_by Column name from sample metadata to use for coloring lines.
#'   This should be provided as an unquoted column name (e.g., `sample_group`).
#'   For XCMSnExp objects, this comes from `pData(object)`. For XcmsExperiment
#'   objects, this comes from `sampleData(object)`.
#' @param include_columns Character vector of column names from sample metadata
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
#' @importFrom stats setNames
#' @importFrom xcms rtime hasAdjustedRtime fromFile processHistory processParam
#' @importFrom MsExperiment sampleData
#' @importFrom tibble tibble as_tibble
#' @importFrom tidyr separate pivot_wider pivot_longer unnest unite
#' @importFrom dplyr %>% mutate filter select bind_rows bind_cols right_join left_join group_by group_nest rename pull all_of join_by
#' @importFrom purrr map map_lgl pluck map2 imap_dfr
#' @importFrom ggplot2 ggplot aes geom_line geom_point theme_bw
gplotAdjustedRtime <- function(object,
                                color_by,
                                include_columns = NULL,
                                adjustedRtime = TRUE) {

  # Input validation
  .validate_xcms_object(object)

  if (!hasAdjustedRtime(object)) {
    warning("No alignment/retention time correction results present.")
  }

  # Get sample metadata (works with both object types)
  sample_data <- .get_sample_data(object)

  # Get spectra data (works with both object types)
  rts <- .get_spectra_data(object) %>%
    left_join(sample_data, by = c(dataOrigin = "spectraOrigin")) %>%
    as_tibble() %>%
    select(fromFile, raw = rtime, adjusted = rtime_adjusted)

  # Add sample metadata
  rts <- sample_data %>%
    as_tibble() %>%
    right_join(rts, by = "fromFile", multiple = "all")


  # Get the peak groups matrix and prepare for plotting
  # Find which processHistory element contains PeakGroupsParam
  which_is_groups <- object %>%
    processHistory() %>%
    map(processParam) %>%
    map_lgl(~ is(., "PeakGroupsParam")) %>%
    which()

  if (length(which_is_groups) == 0) {
    stop("No PeakGroupsParam found in processHistory. ",
         "Retention time adjustment may not have been performed with peak groups.")
  }

  pkGroup <- object %>%
    processHistory() %>%
    map(processParam) %>%
    pluck(which_is_groups) %>%
    xcms:::peakGroupsMatrix() %>%
    as.data.frame()

   new_names <-
   tibble(spectraOrigin_base = colnames(pkGroup)) %>%
    left_join(sample_data, by = join_by(spectraOrigin_base)) %>%
     pull(fromFile)

  pkGroup <- pkGroup %>%
    select(which(!is.na(new_names))) %>%  # if you filter after RT adjustment you no longer have the metadata.
    setNames(., na.omit(new_names)) %>%
    rownames_to_column("feature") %>%
    as_tibble() %>%
    pivot_longer(-feature, names_to = "fromFile", values_to = "rtime") %>%
    mutate(fromFile = as.integer(fromFile)) %>%
    group_by(fromFile) %>%
    group_nest(.key = "feature")

  # Calculate adjusted retention times for peak groups
  good_peaks <- rts %>%
    select(fromFile, raw, adjusted) %>%
    filter(fromFile %in% pkGroup$fromFile) %>%
    group_by(fromFile) %>%
    group_nest(.key = "correction") %>%
    right_join(pkGroup, by = "fromFile") %>%
    mutate(
      feature_correct = map2(
        feature,
        correction,
        function(feat, corr) {
          feat %>%
            mutate(
              adjusted = xcms:::.applyRtAdjustment(
                rtime,
                corr$raw,
                corr$adjusted
              )
            ) %>%
            select(adjusted)
        }
      )
    ) %>%
    select(-correction) %>%
    unnest(cols = c(feature, feature_correct)) %>%
    rename(raw = rtime) %>%
    filter(!is.na(raw))

  # Add tooltip text for interactive plotting
  if (is.null(include_columns)) {
    include_columns <- colnames(sample_data)
  }

  rts <- rts %>%
    select(all_of(include_columns)) %>%
    imap_dfr(~ paste(.y, .x, sep = ": ")) %>%
    unite(text, sep = "<br>") %>%
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
      shape = 19
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
