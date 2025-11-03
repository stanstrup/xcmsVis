# Global variables used in NSE (non-standard evaluation) contexts
utils::globalVariables(c(
  ".",
  "adjusted",
  "correction",
  "feature",
  "feature_correct",
  "rtime",
  "rtime_adjusted",
  "sample_index",
  "sample_name",
  "text",
  "retentionTime",
  "dataOrigin"
))

#' Get sample data from XCMS object
#'
#' Internal helper to handle both XCMSnExp and XcmsExperiment objects
#'
#' @param object XCMSnExp or XcmsExperiment object
#' @return data.frame with sample metadata
#' @keywords internal
#' @importFrom MsExperiment sampleData
#' @importFrom Biobase pData
.get_sample_data <- function(object) {
  if (is(object, "XcmsExperiment")) {
    out <- object %>%
      sampleData %>%
      as.data.frame %>%
      rename(fromFile = sample_index)
  } else if (is(object, "XCMSnExp")) {
    out <- pData(object)
  } else {
    stop("Object must be XcmsExperiment or XCMSnExp", call. = FALSE)
  }


   out$spectraOrigin_base <- basename(out$spectraOrigin)

  return(out)
}

#' Get spectra data from XCMS object
#'
#' Internal helper to extract spectra/feature data from both XCMSnExp and XcmsExperiment objects
#'
#' @param object XCMSnExp or XcmsExperiment object
#' @return data.frame with spectra data including retention times
#' @keywords internal
#' @importFrom MsExperiment spectra
#' @importFrom Spectra spectraData
#' @importFrom xcms rtime fData
#' @importFrom tibble rownames_to_column
#' @importFrom dplyr mutate rename left_join
.get_spectra_data <- function(object) {
  if (is(object, "XcmsExperiment")) {
    out <- object %>%
      spectra() %>%
      spectraData() %>%
      as.data.frame()
  } else if (is(object, "XCMSnExp")) {
    # Get sample data for joining
    sample_data <- pData(object)

    out <- fData(object) %>%
      mutate(rtime_adjusted = rtime(object, adjusted = TRUE)) %>%
      rownames_to_column("fromFile") %>%
      mutate(fromFile = as.integer(gsub("^F(.*?)\\.S.*", "\\1", fromFile))) %>%
      left_join(sample_data, by = c(fromFile = "sample_index")) %>%
      rename(rtime = retentionTime)
  } else {
    stop("Object must be XcmsExperiment or XCMSnExp", call. = FALSE)
  }

  return(out)
}

#' Validate XCMS object type
#'
#' @param object Object to validate
#' @return TRUE if valid, stops with error otherwise
#' @keywords internal
.validate_xcms_object <- function(object) {
  if (!is(object, "XCMSnExp") && !is(object, "XcmsExperiment")) {
    stop("'object' must be an 'XCMSnExp' or 'XcmsExperiment' object.",
         call. = FALSE)
  }
  invisible(TRUE)
}
