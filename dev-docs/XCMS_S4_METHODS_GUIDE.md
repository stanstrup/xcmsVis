# XCMS S4 Method Pattern Guide

## Overview

XCMS uses a sophisticated S4 method dispatch system to provide the same functionality across different object types (primarily `XCMSnExp` for legacy compatibility and `XcmsExperiment` for modern workflows). This document provides concrete examples of the patterns used.

---

## 1. GENERIC FUNCTION DECLARATION

### Location
File: `R/AllGenerics.R`

### Pattern

All generic functions follow this basic structure:

```r
setGeneric("functionName", function(object, param, ...) 
    standardGeneric("functionName"))
```

### Core Examples

```r
# Retention time adjustment
setGeneric("adjustRtime", function(object, param, ...) 
    standardGeneric("adjustRtime"))

# Chromatographic peak operations
setGeneric("findChromPeaks", function(object, param, ...) 
    standardGeneric("findChromPeaks"))

setGeneric("groupChromPeaks", function(object, param, ...) 
    standardGeneric("groupChromPeaks"))

setGeneric("fillChromPeaks", function(object, param, ...) 
    standardGeneric("fillChromPeaks"))

setGeneric("refineChromPeaks", function(object, param, ...) 
    standardGeneric("refineChromPeaks"))

# Accessor generics
setGeneric("chromPeaks", function(object, ...) 
    standardGeneric("chromPeaks"))

setGeneric("chromPeaks<-", function(object, value) 
    standardGeneric("chromPeaks<-"))

setGeneric("adjustedRtime", function(object, bySample = FALSE) 
    standardGeneric("adjustedRtime"))

setGeneric("adjustedRtime<-", function(object, value) 
    standardGeneric("adjustedRtime<-"))

# State query methods
setGeneric("hasChromPeaks", function(object, msLevel = integer()) 
    standardGeneric("hasChromPeaks"))

setGeneric("hasAdjustedRtime", function(object) 
    standardGeneric("hasAdjustedRtime"))

setGeneric("hasFeatures", function(object, msLevel = integer()) 
    standardGeneric("hasFeatures"))
```

### Key Design Principles

1. **Simple function wrapper**: Use minimal code, just call `standardGeneric()`
2. **Avoid braces**: Don't use `{}` around the `standardGeneric()` call
3. **Match naming**: Function name and string argument to `standardGeneric()` must be identical
4. **Parameter order**: Usually `object` first, then parameters

---

## 2. SETTING UP METHOD SIGNATURES WITH PARAMETER DISPATCH

XCMS uses parameter classes to distinguish between different algorithms for the same generic function.

### Example: adjustRtime with Different Algorithms

```r
# Generic function (declared once in AllGenerics.R)
setGeneric("adjustRtime", function(object, param, ...) 
    standardGeneric("adjustRtime"))

# Method 1: PeakGroupsParam-based alignment
setMethod("adjustRtime",
          signature(object = "XCMSnExp", param = "PeakGroupsParam"),
          function(object, param, msLevel = 1L) {
              # Implementation for peak groups method
          })

# Method 2: ObiwarpParam-based alignment  
setMethod("adjustRtime",
          signature(object = "XCMSnExp", param = "ObiwarpParam"),
          function(object, param, msLevel = 1L) {
              # Implementation for obiwarp method
          })

# Method 3: For XcmsExperiment (parent class MsExperiment)
setMethod("adjustRtime",
          signature(object = "MsExperiment", param = "PeakGroupsParam"),
          function(object, param, msLevel = 1L, ...) {
              # Implementation for modern approach
          })
```

### Key Pattern: Signature-Based Dispatch

The `signature()` argument specifies which classes trigger which method:
- If any signature parameter is omitted, it matches ANY class for that position
- The most specific signature wins (most explicit class matches first)
- This enables multiple algorithms to coexist as separate methods

---

## 3. METHOD IMPLEMENTATION EXAMPLES

### Example 1: Simple Accessor Method

```r
# Generic (in AllGenerics.R)
setGeneric("hasChromPeaks", function(object, msLevel = integer()) 
    standardGeneric("hasChromPeaks"))

# Method for XCMSnExp
setMethod("hasChromPeaks", "XCMSnExp", function(object, msLevel = integer()) {
    hasChromPeaks(object@msFeatureData, msLevel = msLevel)
})

# Method for MsFeatureData (delegates to the actual data storage)
setMethod("hasChromPeaks", "MsFeatureData", function(object, msLevel = integer()) {
    if (length(msLevel)) {
        # Return only for specified MS levels
        result <- hasChromPeaks(object)
        if (!result) return(FALSE)
        # Additional filtering logic...
    }
    # Return TRUE/FALSE based on data presence
})
```

**Pattern**: Accessors often delegate to underlying data slots or parent class implementations.

---

### Example 2: Complex Processing Method with Parameter Dispatch

Location: `R/methods-XCMSnExp.R`

```r
setMethod("adjustRtime",
          signature(object = "XCMSnExp", param = "PeakGroupsParam"),
          function(object, param, msLevel = 1L) {
              # 1. VALIDATION: Check prerequisites
              if (hasAdjustedRtime(object)) {
                  message("Removing previous alignment results")
                  object <- dropAdjustedRtime(object)
              }
              if (any(msLevel != 1))
                  stop("Alignment is currently only supported for MS level 1")
              if (!hasChromPeaks(object))
                  stop("No chromatographic peak detection results...")
              
              # 2. PREPARE DATA
              pkGrpMat <- peakGroupsMatrix(param)
              if (!nrow(pkGrpMat)) {
                  if (!hasFeatures(object))
                      stop("No feature definitions found in 'object'...")
                  pkGrpMat <- adjustRtimePeakGroups(object, param = param)
              }
              
              # 3. RECORD START TIME for process history
              startDate <- date()
              
              # 4. PERFORM COMPUTATION
              res <- .adjustRtime_peakGroupsMatrix(
                  rtime(object, bySample = TRUE), 
                  pkGrpMat,
                  smooth = smooth(param), 
                  span = span(param),
                  family = family(param), 
                  subset = subset(param),
                  subsetAdjust = subsetAdjust(param))
              
              # 5. UPDATE OBJECT STATE
              peakGroupsMatrix(param) <- pkGrpMat
              object <- dropFeatureDefinitions(object)
              adjustedRtime(object) <- res
              
              # 6. RECORD PROCESS HISTORY
              xph <- XProcessHistory(
                  param = param, 
                  date. = startDate,
                  type. = .PROCSTEP.RTIME.CORRECTION,
                  fileIndex = 1:length(fileNames(object)),
                  msLevel = msLevel)
              object <- addProcessHistory(object, xph)
              
              # 7. VALIDATE and RETURN
              validObject(object)
              object
          })
```

**Pattern Breakdown**:
1. **Validation**: Ensure prerequisites met
2. **State management**: Drop conflicting results
3. **Computation**: Call helper functions
4. **Update**: Modify object slots with new results
5. **History**: Track all changes for reproducibility
6. **Validation**: Check object consistency before return

---

### Example 3: Replacement Method

```r
setReplaceMethod("adjustedRtime", "XCMSnExp", function(object, value) {
    # VALIDATION
    if (!is.list(value))
        stop("'value' is supposed to be a list of retention time values!")
    if (hasAdjustedRtime(object))
        object <- dropAdjustedRtime(object)
    
    # CHECK DATA INTEGRITY
    unsorted <- unlist(lapply(value, is.unsorted), use.names = FALSE)
    if (any(unsorted))
        warning("Adjusted retention times for file(s) ",
                paste(basename(fileNames(object)[unsorted]), collapse = ", "),
                " not sorted increasingly.")
    
    # CREATE NEW DATA CONTAINER
    newFd <- new("MsFeatureData")
    newFd@.xData <- .copy_env(object@msFeatureData)
    adjustedRtime(newFd) <- value
    
    # CASCADE UPDATES: Apply RT adjustment to chromatographic peaks
    if (hasChromPeaks(newFd)) {
        if (length(value) != length(rtime(object, bySample = TRUE)))
            stop("The length of 'value' has to match the number of samples!")
        message("Applying retention time adjustment to chromatographic peaks...")
        fts <- .applyRtAdjToChromPeaks(chromPeaks(newFd),
                                       rtraw = rtime(object, bySample = TRUE),
                                       rtadj = value)
        chromPeaks(newFd) <- fts
        message("OK")
    }
    
    # FINALIZE: Lock environment and assign
    lockEnvironment(newFd, bindings = TRUE)
    object@msFeatureData <- newFd
    validObject(object)
    object
})
```

**Key Pattern Elements**:
- Replacement methods must return the modified object
- Perform cascading updates to maintain consistency
- Lock environments to prevent external modifications
- Validate before and after modifications

---

### Example 4: Show Method (Display/Representation)

```r
setMethod("show", "XCMSnExp", function(object) {
    callNextMethod()  # Call parent class show method
    cat("- - - xcms preprocessing - - -\n")
    
    # Show peak detection results if present
    if (hasChromPeaks(object)) {
        cat("Chromatographic peak detection:\n")
        ph <- processHistory(object, type = .PROCSTEP.PEAK.DETECTION)
        if (length(ph))
            cat(" method:", .param2string(ph[[1]]@param), "\n")
        else cat(" unknown method.\n")
        cat(" ", nrow(chromPeaks(object)), " peaks identified in ",
            length(fileNames(object)), " samples.\n", sep = "")
    }
    
    # Show alignment results if present
    if (hasAdjustedRtime(object)) {
        cat("Alignment/retention time adjustment:\n")
        ph <- processHistory(object, type = .PROCSTEP.RTIME.CORRECTION)
        if (length(ph))
            cat(" method:", .param2string(ph[[1]]@param), "\n")
        else cat(" unknown method.\n")
    }
    
    # Show correspondence results if present
    if (hasFeatures(object)) {
        cat("Correspondence:\n")
        ph <- processHistory(object, type = .PROCSTEP.PEAK.GROUPING)
        if (length(ph))
            cat(" method:", .param2string(ph[[1]]@param), "\n")
        else cat(" unknown method.\n")
        cat(" ", nrow(featureDefinitions(object)), " features identified.\n",
            sep = "")
    }
})
```

**Pattern**: Show methods use `callNextMethod()` to include parent class info, then add class-specific details.

---

## 4. NAMESPACE EXPORT CONFIGURATION

Location: `NAMESPACE`

```r
# Export S4 methods
exportMethods(
    "adjustRtime",
    "chromPeaks",
    "chromPeaks<-",
    "findChromPeaks",
    "groupChromPeaks",
    "fillChromPeaks",
    "refineChromPeaks",
    "adjustedRtime",
    "adjustedRtime<-",
    "hasChromPeaks",
    "hasAdjustedRtime",
    "hasFeatures",
    "[",
    "$",
    "[["
)

# Export S4 classes
exportClasses(
    "XCMSnExp",
    "XcmsExperiment",
    "PeakGroupsParam",
    "ObiwarpParam",
    "MsFeatureData",
    "XProcessHistory"
)

# Import methods from parent packages
importMethodsFrom("MSnbase", "...")
importFrom("methods", "as", "is", "new", "setClass", "setGeneric", "setMethod")
```

**Key Pattern**: 
- Use `exportMethods()` for S4 method names
- Use `exportClasses()` for S4 class names
- Import parent methods and classes as needed

---

## 5. DUAL-CLASS SUPPORT PATTERN

XCMS supports both legacy (`XCMSnExp`) and modern (`XcmsExperiment`) object types by implementing methods for both:

### Implementation Pattern A: Separate Method per Class

```r
# For XCMSnExp (legacy)
setMethod("adjustRtime",
          signature(object = "XCMSnExp", param = "PeakGroupsParam"),
          function(object, param, msLevel = 1L) {
              # XCMSnExp-specific implementation
          })

# For XcmsExperiment (via parent class MsExperiment)
setMethod("adjustRtime",
          signature(object = "MsExperiment", param = "PeakGroupsParam"),
          function(object, param, msLevel = 1L, ...) {
              # MsExperiment-specific implementation
          })
```

### Implementation Pattern B: Inheritance via Parent Classes

Some methods are inherited from parent classes:

```r
# XCMSnExp extends OnDiskMSnExp
setMethod("adjustRtime",
          signature(object = "OnDiskMSnExp", param = "ObiwarpParam"),
          function(object, param, msLevel = 1L) {
              # Generic implementation
          })

# XCMSnExp automatically inherits this method
```

---

## 6. VISUALIZATION FUNCTION PATTERN

While plotting functions often remain as regular functions (not S4 methods), they demonstrate handling multiple object types:

```r
plotAdjustedRtime <- function(object, 
                              col = "#00000080", 
                              lty = 1, 
                              lwd = 1,
                              type = "l", 
                              adjustedRtime = TRUE,
                              xlab = ifelse(adjustedRtime, 
                                          expression(rt[adj]), 
                                          expression(rt[raw])),
                              ylab = expression(rt[adj] - rt[raw]),
                              peakGroupsCol = "#00000060",
                              peakGroupsPch = 16,
                              peakGroupsLty = 3, 
                              ylim, 
                              ...) {
    # Works with both XCMSnExp and XcmsExperiment
    # Uses S4 accessor methods to extract data:
    rt_data <- rtime(object, bySample = TRUE)
    adj_rt <- adjustedRtime(object, bySample = TRUE)
    peak_data <- chromPeaks(object)
    
    # Rest of visualization logic...
}
```

**Pattern**: Uses S4 accessor methods to extract data, making the function work transparently with any class that implements those methods.

---

## 7. PRACTICAL IMPLEMENTATION GUIDE FOR YOUR gplotAdjustedRtime

Based on XCMS patterns, here's how to refactor your function to use S4 methods:

### Current Approach (Function with Type Checking)
```r
gplotAdjustedRtime <- function(object, ...) {
    if (is(object, "XCMSnExp")) {
        # Handle XCMSnExp
    } else if (is(object, "XcmsExperiment")) {
        # Handle XcmsExperiment
    }
}
```

### Recommended S4 Approach

**1. Declare Generic (R/AllGenerics.R)**
```r
setGeneric("gplotAdjustedRtime", 
           function(object, ...) standardGeneric("gplotAdjustedRtime"))
```

**2. Implement for XCMSnExp (R/methods-XCMSnExp.R)**
```r
setMethod("gplotAdjustedRtime", "XCMSnExp", 
          function(object, ...) {
              # Extract data using S4 accessors
              rt <- rtime(object, bySample = TRUE)
              adj_rt <- adjustedRtime(object, bySample = TRUE)
              peaks <- chromPeaks(object)
              
              # Implementation specific to XCMSnExp
          })
```

**3. Implement for XcmsExperiment (R/XcmsExperiment.R or methods file)**
```r
setMethod("gplotAdjustedRtime", "XcmsExperiment",
          function(object, ...) {
              # Extract data using S4 accessors
              rt <- rtime(object, bySample = TRUE)
              adj_rt <- adjustedRtime(object, bySample = TRUE)
              peaks <- chromPeaks(object)
              
              # Implementation specific to XcmsExperiment
          })
```

**4. Export in NAMESPACE**
```r
exportMethods("gplotAdjustedRtime")
```

### Benefits of S4 Approach

1. **Type Safety**: R dispatches automatically; no if/else needed
2. **Extensibility**: Third-party packages can define new methods
3. **Discoverability**: `methods("gplotAdjustedRtime")` shows all implementations
4. **Documentation**: roxygen can generate proper documentation with `@rdname`
5. **Consistency**: Follows XCMS conventions

---

## 8. ROXYGEN DOCUMENTATION PATTERN

```r
#' @title Adjusted Retention Time Visualization for XCMS Objects
#'
#' @description
#' Generic function to visualize retention time adjustment results
#' for XCMSnExp and XcmsExperiment objects.
#'
#' @param object An \code{\link{XCMSnExp}} or \code{\link{XcmsExperiment}} 
#'   object with alignment results
#' @param ... Additional arguments passed to methods
#'
#' @return Invisibly returns the plot object (ggplot or standard plot)
#'
#' @seealso \code{\link{adjustRtime}} for performing the alignment
#'
#' @rdname gplotAdjustedRtime
#' @aliases gplotAdjustedRtime,XCMSnExp-method
#' @aliases gplotAdjustedRtime,XcmsExperiment-method
#' 
#' @examples
#' # See method-specific documentation for examples
#' 
#' @export
setGeneric("gplotAdjustedRtime", 
           function(object, ...) standardGeneric("gplotAdjustedRtime"))

#' @rdname gplotAdjustedRtime
setMethod("gplotAdjustedRtime", "XCMSnExp",
          function(object, ...) {
              # implementation
          })

#' @rdname gplotAdjustedRtime  
setMethod("gplotAdjustedRtime", "XcmsExperiment",
          function(object, ...) {
              # implementation
          })
```

---

## Summary: Key Takeaways

1. **Generic function** = Single declaration with `setGeneric()`
2. **Methods** = Multiple implementations via `setMethod()` with different signatures
3. **Signature** = Specifies which classes trigger which method
4. **Dispatch** = R automatically calls the right method based on object class
5. **Namespace** = Must export methods and classes explicitly
6. **Pattern** = Validation → Processing → Update → History → Validate & Return
7. **Dual support** = Implement same method for both XCMSnExp and XcmsExperiment
8. **Extensibility** = Other packages can add methods without modifying XCMS

This approach is central to how XCMS achieves clean separation of concerns while maintaining backward compatibility with legacy XCMSnExp objects and forward compatibility with modern XcmsExperiment infrastructure.
