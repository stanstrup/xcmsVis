#' Get sample data from XCMS object
#'
#' Internal helper to handle both XCMSnExp and XcmsExperiment objects
#'
#' @param object XCMSnExp or XcmsExperiment object
#' @return data.frame with sample metadata
#' @keywords internal
#' @importFrom MsExperiment sampleData
.get_sample_data <- function(object) {
  if (is(object, "XcmsExperiment")) {
    as.data.frame(MsExperiment::sampleData(object))
  } else if (is(object, "XCMSnExp")) {
    xcms::pData(object)
  } else {
    stop("Object must be XcmsExperiment or XCMSnExp", call. = FALSE)
  }
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
