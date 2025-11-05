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
#' @importFrom methods is
#' @importFrom stats setNames na.omit
#' @importFrom xcms rtime hasAdjustedRtime fromFile processHistory processParam
#' @importFrom MsExperiment sampleData
#' @importFrom tibble tibble as_tibble rownames_to_column
#' @importFrom tidyr separate pivot_wider pivot_longer unnest unite
#' @importFrom dplyr %>% mutate filter select bind_rows bind_cols right_join left_join group_by group_nest rename pull all_of join_by
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
