#' Internal XCMS utility functions
#'
#' These functions are copied from the xcms package to avoid using `:::` calls.
#' They are pure R implementations and are reproduced here with attribution.
#'
#' @source https://github.com/sneumann/xcms
#' @author Original XCMS authors
#' @keywords internal
#' @name xcms-utils
NULL

#' Apply retention time adjustment to a vector of retention times
#'
#' Copied from xcms (do_adjustRtime-functions.R) to avoid `:::` usage.
#'
#' @param x numeric vector of retention times to adjust
#' @param rtraw numeric vector of raw retention times (from adjustment)
#' @param rtadj numeric vector of adjusted retention times (from adjustment)
#'
#' @return numeric vector of adjusted retention times
#'
#' @source https://github.com/sneumann/xcms/blob/devel/R/do_adjustRtime-functions.R
#' @keywords internal
#' @noRd
.applyRtAdjustment <- function(x, rtraw, rtadj) {
    ## re-order everything if rtraw is not sorted; issue #146
    if (is.unsorted(rtraw)) {
        idx <- order(rtraw)
        rtraw <- rtraw[idx]
        rtadj <- rtadj[idx]
    }
    adjFun <- stepfun(rtraw[-1] - diff(rtraw) / 2, rtadj)
    res <- adjFun(x)
    ## Fix margins.
    idx_low <- which(x < rtraw[1])
    if (length(idx_low)) {
        first_adj <- idx_low[length(idx_low)] + 1
        res[idx_low] <- x[idx_low] + res[first_adj] - x[first_adj]
    }
    idx_high <- which(x > rtraw[length(rtraw)])
    if (length(idx_high)) {
        last_adj <- idx_high[1] - 1
        res[idx_high] <- x[idx_high] + res[last_adj] - x[last_adj]
    }
    if (is.null(dim(res)))
        names(res) <- names(x)
    res
}

#' Build retention time model for LamaParama alignment
#'
#' Copied from xcms (do_adjustRtime-functions.R) to avoid `:::` usage.
#'
#' @param method character, "loess" or "gam"
#' @param rt_map data.frame with 'ref' and 'obs' columns
#' @param span numeric, span parameter for loess
#' @param resid_ratio numeric, residual ratio threshold for outlier detection
#' @param zero_weight numeric, weight for the (0,0) anchor point
#' @param bs character, basis for GAM spline
#'
#' @return fitted model object (loess or gam)
#'
#' @source https://github.com/sneumann/xcms/blob/devel/R/do_adjustRtime-functions.R
#' @keywords internal
#' @noRd
.rt_model <- function(method = c("loess", "gam"),
                      rt_map, span = 0.5,
                      resid_ratio = 3,
                      zero_weight = 10,
                      bs = "tp"){
    rt_map <- rt_map[order(rt_map$obs), c("ref", "obs")]
    # add first row of c(0,0) to set a fix timepoint.
    rt_map <- rbind(c(0,0), rt_map)
    weights <- rep(1, nrow(rt_map))
    weights[1L] <- zero_weight

    if (method == "gam") {
        .check_gam_library()
        model <- mgcv::gam(ref ~ s(obs, bs = bs), weights = weights,
                           data = rt_map)
    } else
        model <- loess(ref ~ obs, data = rt_map, span = span,
                       weights = weights)
    ## compute outliers
    SSq <- resid(model)^2
    meanSSq <- mean(SSq)
    not_outlier <- (SSq / meanSSq) < resid_ratio

    ## re-run only if there is outliers and keep the zero.
    if (any(!not_outlier)){
        not_outlier[1] <- TRUE
        rt_map <- rt_map[not_outlier, , drop = FALSE]
        weights <- weights[not_outlier]
        if (method == "gam") {
            model <- mgcv::gam(ref ~ s(obs, bs = "tp"), weights = weights,
                               data = rt_map)
        } else {
            model <- loess(ref ~ obs, data = rt_map, span = span,
                           weights = weights)
        }
    }
    model
}

#' Check if mgcv package is available
#'
#' Helper function for .rt_model
#'
#' @keywords internal
#' @noRd
.check_gam_library <- function() {
    if (!requireNamespace("mgcv", quietly = TRUE))
        stop("Package 'mgcv' is required for method = 'gam'")
}
