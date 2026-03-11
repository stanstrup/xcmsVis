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
  "maxo",
  "i",
  "rtmed",
  "Retention time",
  "Peak density",
  "peak_id",
  "obs",
  "ref",
  "sample_label"
))

#' Get sample data from XCMS object
#'
#' Internal helper to handle both XCMSnExp and XcmsExperiment objects
#'
#' @param object XCMSnExp or XcmsExperiment object
#'
#' @return data.frame with sample metadata
#'
#' @keywords internal
#' @importFrom MsExperiment sampleData
#' @importFrom Biobase pData
#' @importFrom MSnbase fileNames
#' @importFrom methods is
#'
#' @noRd
.get_sample_data <- function(object) {
    .validate_xcms_object(object)
    if (inherits(object, "MsExperiment")) {
        out <- as.data.frame(sampleData(object))
    } else if (inherits(object, "OnDiskMSnExp")) {
        out <- pData(object)
    }
    if(is.null(out$spectraOrigin) && !(length(fileNames(object)) > 0) )
        stop("No files defined in object!", call. = FALSE)
    if(is.null(out$spectraOrigin))
        out$spectraOrigin <- fileNames(object)
    out$spectraOrigin_base <- basename(out$spectraOrigin)
    return(out)
}

#' Get spectra data from XCMS object
#'
#' Internal helper to extract spectra/feature data from both XCMSnExp
#' and XcmsExperiment objects
#'
#' @param object XCMSnExp or XcmsExperiment object
#'
#' @return data.frame with spectra data including retention times
#'
#' @keywords internal
#'
#' @importFrom MsExperiment spectra
#' @importFrom Spectra spectraData
#' @importFrom MSnbase fData
#' @importFrom dplyr mutate rename left_join n select
#' @importFrom methods is
#'
#' @noRd
.get_spectra_data <- function(object) {
  .validate_xcms_object(object)
  if (inherits(object, "MsExperiment")) {
      spec_data <- object %>%
          spectra() %>%
          spectraData() %>%
          as.data.frame() %>%
          mutate(spectraOrigin_base = basename(dataOrigin))
      if ("rtime_adjusted" %in% names(spec_data)) {
          out <- spec_data %>%
              select(dataOrigin, spectraOrigin_base, rtime, rtime_adjusted)
      } else {
          out <- spec_data %>%
              select(dataOrigin, spectraOrigin_base, rtime) %>%
              mutate(rtime_adjusted = rtime)
      }
  } else if (inherits(object, "OnDiskMSnExp")) {
      sample_data <- .get_sample_data(object) %>%
          mutate(fileIdx = 1:n())
      out <- fData(object)
      if(!("retentionTime_adjusted" %in% names(object))){
          out <- out %>%
              mutate(retentionTime_adjusted = rtime(object, adjusted = TRUE))
      }
      out <- out %>%
          left_join(sample_data, by = "fileIdx") %>%
          rename(rtime = retentionTime,
                 rtime_adjusted = retentionTime_adjusted,
                 dataOrigin = "spectraOrigin") %>%
          select(dataOrigin, spectraOrigin_base, rtime, rtime_adjusted)
  }
  return(out)
}

#' Validate XCMS object type
#'
#' @param object Object to validate
#'
#' @return TRUE if valid, stops with error otherwise
#'
#' @importFrom methods is
#'
#' @keywords internal
#'
#' @noRd
.validate_xcms_object <- function(object) {
    if (!(inherits(object, "OnDiskMSnExp") |
          inherits(object, "MsExperiment"))) {
        stop("'object' must be an 'XCMSnExp', 'OnDiskMSnExp' or ",
             "'XcmsExperiment' object.", call. = FALSE)
    }
    invisible(TRUE)
}

#' Selectively suppress warnings matching a pattern
#'
#' Higher-order function that wraps another function to suppress only warnings
#' that match a specific regex pattern. Other warnings are allowed through.
#'
#' @param .f Function to wrap
#'
#' @param pattern Regex pattern for warnings to suppress
#'
#' @return Modified function that selectively suppresses warnings
#'
#' @keywords internal
#'
#' @noRd
.selectively_suppress_warnings <- function(.f, pattern) {
    force(.f)  # ensure .f is evaluated once
    function(...) {
        withCallingHandlers(
            .f(...),
            warning = function(w) {
                if (grepl(pattern, conditionMessage(w))) {
                    invokeRestart("muffleWarning")
                }
            }
        )
    }
}

#' Create ggplot2 geom wrappers that suppress plotly 'text' aesthetic warnings
#'
#' These wrapper functions suppress the "Ignoring unknown aesthetics: text"
#' warning that occurs when using the 'text' aesthetic for plotly tooltips.
#' The 'text' aesthetic is not recognized by ggplot2 but is used by
#' plotly::ggplotly()
#'
#' @importFrom ggplot2 geom_point geom_rect geom_polygon geom_path
#'
#' @keywords internal
#'
#' @noRd
NULL

.geom_point_text <- .selectively_suppress_warnings(
    geom_point, "Ignoring unknown aesthetics: text"
)

.geom_rect_text <- .selectively_suppress_warnings(
    geom_rect, "Ignoring unknown aesthetics: text"
)

.geom_polygon_text <- .selectively_suppress_warnings(
    geom_polygon, "Ignoring unknown aesthetics: text"
)

.geom_path_text <- .selectively_suppress_warnings(
    geom_path, "Ignoring unknown aesthetics: text"
)

#' @importFrom ggplot2 geom_line
#' @noRd
.geom_line_text <- .selectively_suppress_warnings(
    geom_line, "Ignoring unknown aesthetics: text"
)

#' Build tooltip text column from pData columns
#'
#' Constructs an HTML tooltip string (with \code{<br>} separators) for plotly
#' from selected columns of a data frame.
#'
#' @param df A data frame that already contains the pData columns (e.g., after
#'   a merge with pData).
#' @param include_columns \code{TRUE} to include all pData columns,
#'   a character vector to include specific columns, or \code{NULL} to skip.
#' @param pdata_cols Character vector of all available pData column names
#'   (used when \code{include_columns = TRUE}).
#' @param extra A character vector of the same length as \code{nrow(df)} with
#'   additional text to prepend (e.g., peak IDs).  \code{NULL} to skip.
#'
#' @return A character vector of tooltip strings, or \code{NULL} if
#'   \code{include_columns} is \code{NULL}.
#'
#' @keywords internal
#' @noRd
.build_tooltip <- function(df, include_columns, pdata_cols,
                           extra = NULL) {
    if (is.null(include_columns)) return(NULL)
    cols <- if (isTRUE(include_columns)) pdata_cols else include_columns
    ## Keep only columns that exist in df
    cols <- intersect(cols, colnames(df))
    if (length(cols) == 0L) return(NULL)
    ## Build "name: value" pairs per row
    parts <- lapply(cols, function(cn) paste0(cn, ": ", df[[cn]]))
    tooltip <- do.call(function(...) paste(..., sep = "<br>"), parts)
    if (!is.null(extra)) {
        tooltip <- paste0(extra, "<br>", tooltip)
    }
    tooltip
}

#' Resolve a color argument as either a static color or a pData column mapping
#'
#' Checks whether a string value matches a column name in pData, in which
#' case it is treated as an aesthetic mapping.  Otherwise the value is used
#' as a static colour.
#'
#' @param value The evaluated value of the colour argument (a character
#'   string).
#' @param pdata_cols Character vector of column names available in pData.
#'
#' @return A list with two elements:
#'   \describe{
#'     \item{type}{\code{"mapping"} if \code{value} is a length-1 string
#'       found in \code{pdata_cols}, or \code{"static"} otherwise.}
#'     \item{value}{The original \code{value}, unchanged.}
#'   }
#'
#' @keywords internal
#' @noRd
.resolve_color <- function(value, pdata_cols) {
    if (is.character(value) && length(value) == 1L &&
        value %in% pdata_cols) {
        list(type = "mapping", value = value)
    } else {
        list(type = "static", value = value)
    }
}
