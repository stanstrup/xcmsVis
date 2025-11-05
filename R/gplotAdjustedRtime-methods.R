#' @include AllGenerics.R
#' @include utils.R

#' Internal implementation for gplotAdjustedRtime
#'
#' @param object XCMSnExp or XcmsExperiment object
#' @param color_by Column name for coloring (NSE)
#' @param include_columns Columns to include in tooltip
#' @param adjustedRtime Logical (not currently used)
#' @return ggplot object
#' @keywords internal
#' @noRd
#' @importFrom stats na.omit
#' @importFrom xcms hasAdjustedRtime processHistory processParam
#' @importFrom tibble tibble as_tibble rownames_to_column
#' @importFrom tidyr pivot_longer unnest unite
#' @importFrom dplyr %>% mutate filter select right_join left_join inner_join group_by group_nest rename pull all_of join_by
#' @importFrom purrr map map_lgl pluck map2 imap_dfr
#' @importFrom ggplot2 ggplot aes geom_line geom_point theme_bw
.gplotAdjustedRtime_impl <- function(object,
                                      color_by,
                                      include_columns = NULL,
                                      adjustedRtime = TRUE) {

  # Input validation
  .validate_xcms_object(object)

  if (!hasAdjustedRtime(object)) {
    warning("No alignment/retention time correction results present.")
  }

  # Get sample metadata - helper handles both object types
  sample_data <- .get_sample_data(object)

  # Get spectra data - helper handles both object types
  rts <- .get_spectra_data(object) %>%
    left_join(sample_data, by = c(dataOrigin = "spectraOrigin")) %>%
    as_tibble() %>%
    select(spectraOrigin_base, raw = rtime, adjusted = rtime_adjusted)

  # Add sample metadata
  rts <- sample_data %>%
    as_tibble() %>%
    right_join(rts, by = "spectraOrigin_base", multiple = "all")


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

  pkGroup <- pkGroup %>%
    rownames_to_column("feature") %>%
    as_tibble() %>%
    pivot_longer(-feature, names_to = "spectraOrigin_base", values_to = "rtime") %>%
    group_by(spectraOrigin_base) %>%
    group_nest(.key = "feature")



  # Calculate adjusted retention times for peak groups
  good_peaks <- rts %>%
    select(spectraOrigin_base, raw, adjusted) %>%
    filter(spectraOrigin_base %in% pkGroup$spectraOrigin_base   ) %>%
    group_by(spectraOrigin_base) %>%
    group_nest(.key = "correction") %>%
    inner_join(pkGroup, by = "spectraOrigin_base") %>%
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

#' @rdname gplotAdjustedRtime
#' @export
setMethod("gplotAdjustedRtime", "XCMSnExp",
          function(object, color_by, include_columns = NULL, adjustedRtime = TRUE) {
            .gplotAdjustedRtime_impl(object, {{ color_by }}, include_columns, adjustedRtime)
          })

#' @rdname gplotAdjustedRtime
#' @export
setMethod("gplotAdjustedRtime", "XcmsExperiment",
          function(object, color_by, include_columns = NULL, adjustedRtime = TRUE) {
            .gplotAdjustedRtime_impl(object, {{ color_by }}, include_columns, adjustedRtime)
          })
