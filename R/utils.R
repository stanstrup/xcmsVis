# Global variables used in NSE (non-standard evaluation) contexts
utils::globalVariables(c(
  ".",
  "adjusted",
  "correction",
  "feature",
  "feature_correct",
  "rtime_adjusted",
  "sample_index",
  "sample_name",
  "text"
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
