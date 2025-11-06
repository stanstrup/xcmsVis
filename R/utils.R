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
  "retentionTime_adjusted",
  "dataOrigin",
  "spectraOrigin_base",
  "fileIdx",
  "n",
  "rtmin",
  "rtmax",
  "mzmin",
  "mzmax",
  "rt",
  "sample",
  "rt_bin",
  "count",
  "rt_center",
  "sample_name",
  "intensity",
  "xmin",
  "xmax",
  "ymin",
  "ymax",
  "x",
  "y",
  "maxo"
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
#' @importFrom MSnbase fileNames
#' @importFrom methods is

.get_sample_data <- function(object) {
  .validate_xcms_object(object)

  if (is(object, "XcmsExperiment")) {
    out <- object %>%
      sampleData %>%
      as.data.frame

  } else if (is(object, "XCMSnExp") | is(object, "OnDiskMSnExp")) {

    out <- pData(object)

  }

  if(is.null(out$spectraOrigin) && !(length(MSnbase::fileNames(object))>0) ) stop("No files defined in object!", call. = FALSE)


  if(is.null(out$spectraOrigin)) out$spectraOrigin <- MSnbase::fileNames(object)



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
#' @importFrom xcms rtime
#' @importFrom MSnbase fData
#' @importFrom dplyr mutate rename left_join n select
#' @importFrom methods is
.get_spectra_data <- function(object) {
  .validate_xcms_object(object)

  if (is(object, "XcmsExperiment")) {
    out <- object %>%
            spectra() %>%
            spectraData() %>%
            as.data.frame() %>%
            mutate(spectraOrigin_base = basename(dataOrigin)) %>%
            select(dataOrigin, spectraOrigin_base, rtime, rtime_adjusted)

  } else if (is(object, "XCMSnExp") | is(object, "OnDiskMSnExp")) {
    # Get sample data for joining
    sample_data <- .get_sample_data(object) %>%
                    mutate(fileIdx = 1:dplyr::n())

    out <- fData(object)

          if(!("retentionTime_adjusted" %in% names(object))){ # not sure why it is there sometimes and sometimes not
           out <- out %>%
                    mutate(retentionTime_adjusted = rtime(object, adjusted = TRUE))

          }

     out <- out %>%
            left_join(sample_data, by = "fileIdx") %>%
            rename(rtime = retentionTime, rtime_adjusted = retentionTime_adjusted, dataOrigin = "spectraOrigin") %>%
            select(dataOrigin, spectraOrigin_base, rtime, rtime_adjusted)
  }

  return(out)
}

#' Validate XCMS object type
#'
#' @param object Object to validate
#' @return TRUE if valid, stops with error otherwise
#' @keywords internal
#' @importFrom methods is
.validate_xcms_object <- function(object) {
  if (!is(object, "XCMSnExp") && !is(object, "XcmsExperiment") && !is(object, "OnDiskMSnExp")) {
    stop("'object' must be an 'XCMSnExp', 'OnDiskMSnExp' or 'XcmsExperiment' object.",
         call. = FALSE)
  }
  invisible(TRUE)
}
