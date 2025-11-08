#' @include AllGenerics.R
NULL

# Shared implementation function for gplotChromPeaks
#'
#' @importFrom xcms chromPeaks rtime mz fileNames hasChromPeaks filterFile
#' @importFrom ggplot2 ggplot aes geom_rect theme_bw labs xlim ylim
#' @importFrom tibble as_tibble
#' @importFrom methods is
#' @keywords internal
.gplotChromPeaks_impl <- function(object,
                                  file = 1,
                                  xlim = NULL,
                                  ylim = NULL,
                                  border = "#00000060",
                                  fill = NA,
                                  msLevel = 1L) {

    .validate_xcms_object(object)

    # Check that peaks exist
    if (!hasChromPeaks(object)) {
        stop("No chromatographic peaks found in object. ",
             "Run findChromPeaks() first.", call. = FALSE)
    }

    # Get file name for title
    file_names <- fileNames(object)
    if (file[1] > length(file_names)) {
        stop("'file' index ", file[1], " is out of range. Object has ",
             length(file_names), " files.", call. = FALSE)
    }
    main_title <- basename(file_names[file[1]])

    # Filter to specific file
    suppressMessages(
        object_file <- filterFile(object, file = file[1], keepAdjustedRtime = TRUE)
    )

    # Get retention time and m/z ranges if not specified
    if (is.null(xlim)) {
        xlim <- range(rtime(object_file))
    }
    if (is.null(ylim)) {
        # Get mz range from chromPeaks
        all_peaks <- chromPeaks(object_file, msLevel = msLevel)
        if (nrow(all_peaks) > 0) {
            ylim <- range(c(all_peaks[, "mzmin"], all_peaks[, "mzmax"]))
        } else {
            ylim <- c(0, 1000)  # Default range if no peaks
        }
    }

    # Extract peaks within specified ranges
    pks <- chromPeaks(object_file, mz = ylim, rt = xlim, msLevel = msLevel)

    # Convert to data frame for ggplot2
    if (nrow(pks) > 0) {
        pks_df <- as_tibble(pks)
    } else {
        # Create empty data frame with required columns if no peaks
        pks_df <- tibble(
            rtmin = numeric(0),
            rtmax = numeric(0),
            mzmin = numeric(0),
            mzmax = numeric(0)
        )
    }

    # Create the plot
    p <- ggplot(pks_df) +
        geom_rect(aes(xmin = rtmin, xmax = rtmax,
                     ymin = mzmin, ymax = mzmax),
                 color = border, fill = fill) +
        theme_bw() +
        labs(x = "retention time",
             y = "m/z",
             title = main_title) +
        coord_cartesian(xlim = xlim, ylim = ylim)

    return(p)
}

#' @rdname gplotChromPeaks
#' @export
setMethod("gplotChromPeaks", "XCMSnExp",
          function(object, file = 1, xlim = NULL, ylim = NULL,
                   border = "#00000060", fill = NA, msLevel = 1L) {
              .gplotChromPeaks_impl(object, file, xlim, ylim,
                                   border, fill, msLevel)
          })

#' @rdname gplotChromPeaks
#' @export
setMethod("gplotChromPeaks", "XcmsExperiment",
          function(object, file = 1, xlim = NULL, ylim = NULL,
                   border = "#00000060", fill = NA, msLevel = 1L) {
              .gplotChromPeaks_impl(object, file, xlim, ylim,
                                   border, fill, msLevel)
          })
