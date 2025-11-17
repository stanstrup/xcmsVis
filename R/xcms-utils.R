#' Internal XCMS utility functions
#'
#' @description
#' These functions are copied from the XCMS package to avoid using `:::` calls,
#' which would generate R CMD check NOTEs and fail Bioconductor standards.
#'
#' @section Why Copy Instead of Import:
#' R packages cannot use `package:::function()` to access internal functions
#' without generating a NOTE in R CMD check. Since Bioconductor requires
#' 0 errors, 0 warnings, and 0 notes, we copy these stable utility functions
#' rather than depending on XCMS internals.
#'
#' @section Maintenance:
#' **Last synchronized:** 2024-11-17
#'
#' **XCMS source version:** devel branch (accessed 2024-11-17)
#'
#' **XCMS GitHub:** https://github.com/sneumann/xcms
#'
#' **Functions copied:**
#' \itemize{
#'   \item `.descendMin()` - C + R wrapper from `R/c.R` and `src/util.c`
#'   \item `.applyRtAdjustment()` - Pure R from `R/do_adjustRtime-functions.R`
#'   \item `.rt_model()` - Pure R from `R/do_adjustRtime-functions.R`
#'   \item `.check_gam_library()` - Helper for `.rt_model()`
#' }
#'
#' @section Update Process:
#' To update these functions:
#'
#' 1. Check XCMS source at https://github.com/sneumann/xcms/tree/devel
#' 2. Compare with current implementation in this file
#' 3. Update both R wrapper and C code (if changed)
#' 4. Run tests in `tests/testthat/test-xcms-utils.R`
#' 5. Update "Last synchronized" date above
#'
#' @section Stability:
#' These are low-level utility functions that have remained stable in XCMS
#' for many years. Breaking changes are unlikely but should be monitored.
#'
#' @section Alternative Approach:
#' If these functions are needed by multiple packages, consider requesting
#' that XCMS maintainers export them officially. Open an issue at:
#' https://github.com/sneumann/xcms/issues
#'
#' @source https://github.com/sneumann/xcms/blob/devel/R/c.R
#' @source https://github.com/sneumann/xcms/blob/devel/R/do_adjustRtime-functions.R
#' @source https://github.com/sneumann/xcms/blob/devel/src/util.c
#' @author Original XCMS authors (Colin A. Smith, Ralf Tautenhahn, Steffen Neumann,
#'   Johannes Rainer, et al.)
#' @keywords internal
#' @name xcms-utils
#' @importFrom stats loess resid stepfun
#' @useDynLib xcmsVis, .registration = TRUE
NULL

#' Find local minima by descending from a peak
#'
#' @description
#' Copied from XCMS (R/c.R and src/util.c) to avoid `:::` usage.
#'
#' This function wraps the C function `DescendMin` (in src/util.c) that finds
#' the boundaries of a local minimum region by descending in both directions
#' from a starting position. It's used in peak density calculations to identify
#' feature boundaries.
#'
#' @details
#' **Algorithm:** Starting from `istart`, descend left until values stop decreasing,
#' then descend right until values stop decreasing. Returns the indices defining
#' this minimum region.
#'
#' **C Implementation:** See `src/util.c` for the C code (also copied from XCMS).
#'
#' **Original XCMS location:** `R/c.R` (wrapper) and `src/util.c` (C function)
#'
#' **Used by:** `.simulate_feature_groups()` in gplotChromPeakDensity
#'
#' @param y numeric vector of signal/intensity values
#' @param istart integer starting position (defaults to position of maximum value)
#'
#' @return integer vector of length 2 with `c(ilower, iupper)` defining
#'   the indices of the minimum region boundaries
#'
#' @section Maintenance Note:
#' Both this R wrapper and the C code in `src/util.c` must be kept in sync
#' with XCMS. The C implementation has been stable for years.
#'
#' @source https://github.com/sneumann/xcms/blob/devel/R/c.R
#' @source https://github.com/sneumann/xcms/blob/devel/src/util.c
#' @seealso `.simulate_feature_groups()` which uses this function
#' @keywords internal
#' @noRd
.descendMin <- function(y, istart = which.max(y)) {
    if (!is.double(y)) y <- as.double(y)
    unlist(.C("DescendMin",
              y,
              length(y),
              as.integer(istart-1),
              ilower = integer(1),
              iupper = integer(1),
              PACKAGE = "xcmsVis")[4:5]) + 1
}

#' Apply retention time adjustment to a vector of retention times
#'
#' @description
#' Copied from XCMS (do_adjustRtime-functions.R) to avoid `:::` usage.
#'
#' Applies retention time adjustment using a step function based on raw and
#' adjusted RT pairs. Handles edge cases at the margins of the RT range.
#'
#' @details
#' **Algorithm:** Creates a step function from raw/adjusted RT pairs, then
#' applies it to input retention times. Special handling for times outside
#' the calibration range (margins).
#'
#' **Pure R:** This implementation is pure R (no C code).
#'
#' **Original XCMS location:** `R/do_adjustRtime-functions.R`
#'
#' **Used by:** LamaParama alignment visualization
#'
#' @param x numeric vector of retention times to adjust
#' @param rtraw numeric vector of raw retention times (from adjustment)
#' @param rtadj numeric vector of adjusted retention times (from adjustment)
#'
#' @return numeric vector of adjusted retention times with same length as `x`
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
#' @description
#' Copied from XCMS (do_adjustRtime-functions.R) to avoid `:::` usage.
#'
#' Builds a retention time correction model (loess or GAM) with automatic
#' outlier detection and a fixed anchor point at (0,0).
#'
#' @details
#' **Algorithm:**
#' 1. Adds (0,0) anchor point with high weight
#' 2. Fits loess or GAM model
#' 3. Detects outliers based on residual ratio
#' 4. Refits model excluding outliers (keeping anchor)
#'
#' **Pure R:** This implementation is pure R (no C code).
#'
#' **Original XCMS location:** `R/do_adjustRtime-functions.R`
#'
#' **Used by:** LamaParama alignment visualization
#'
#' @param method character, "loess" or "gam"
#' @param rt_map data.frame with 'ref' and 'obs' columns (retention time pairs)
#' @param span numeric, span parameter for loess (default: 0.5)
#' @param resid_ratio numeric, residual ratio threshold for outlier detection (default: 3)
#' @param zero_weight numeric, weight for the (0,0) anchor point (default: 10)
#' @param bs character, basis for GAM spline (default: "tp")
#'
#' @return fitted model object (loess or gam class)
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
