# S4 Methods Quick Reference Card

Quick syntax reference for implementing S4 methods following XCMS patterns.

---

## 1. Declaring a Generic Function

**File**: `R/AllGenerics.R`

```r
# Basic pattern
setGeneric("functionName", function(object, ...) standardGeneric("functionName"))

# With specific parameters
setGeneric("adjustRtime", function(object, param, ...) 
    standardGeneric("adjustRtime"))

# Accessor (getter)
setGeneric("chromPeaks", function(object, ...) 
    standardGeneric("chromPeaks"))

# Replacement (setter)
setGeneric("chromPeaks<-", function(object, value) 
    standardGeneric("chromPeaks<-"))
```

Key Rules:
- Function name must match string in `standardGeneric()`
- Use `...` for variable arguments
- Keep body simple - just call `standardGeneric()`
- Don't use braces around the function

---

## 2. Implementing Methods - Single Class

**File**: `R/methods-ClassName.R`

```r
# Simple accessor method
setMethod("methodName", "ClassName", function(object) {
    # Implementation here
    return(result)
})

# Method with parameters
setMethod("methodName", "ClassName", 
          function(object, param1, param2 = default) {
    # Implementation here
    return(result)
})

# Replacement method
setReplaceMethod("methodName", "ClassName", function(object, value) {
    # Validate input
    if (invalid) stop("error message")
    
    # Modify object
    object@slot <- value
    
    # Must return modified object
    object
})
```

---

## 3. Implementing Methods - Parameter Dispatch

```r
# Same generic, different method depending on param class
setMethod("adjustRtime",
          signature(object = "XCMSnExp", param = "PeakGroupsParam"),
          function(object, param, msLevel = 1L) {
    # Implementation for peak groups
})

setMethod("adjustRtime",
          signature(object = "XCMSnExp", param = "ObiwarpParam"),
          function(object, param, msLevel = 1L) {
    # Implementation for obiwarp
})

# Wildcard - matches any param class
setMethod("adjustRtime",
          signature(object = "XCMSnExp", param = "ANY"),
          function(object, param, ...) {
    # Default fallback
})
```

Key Rules:
- `signature()` specifies which classes trigger which method
- Can dispatch on multiple parameters
- More specific signatures take precedence
- Omit parameter in signature to match ANY class for that parameter

---

## 4. Implementing Methods - Dual Class Support

```r
# For legacy class XCMSnExp
setMethod("gplotAdjustedRtime", "XCMSnExp",
          function(object, ...) {
    rt <- rtime(object, bySample = TRUE)
    adj_rt <- adjustedRtime(object, bySample = TRUE)
    # XCMSnExp-specific visualization
})

# For modern class XcmsExperiment (extends MsExperiment)
setMethod("gplotAdjustedRtime", "XcmsExperiment",
          function(object, ...) {
    rt <- rtime(object, bySample = TRUE)
    adj_rt <- adjustedRtime(object, bySample = TRUE)
    # XcmsExperiment-specific visualization
})

# Verify both methods exist:
methods("gplotAdjustedRtime")  # Should list both implementations
```

---

## 5. Common Method Patterns

### Accessor Method
```r
setMethod("methodName", "ClassName", function(object) {
    object@slotName
})
```

### Validator Method
```r
setMethod("hasFeature", "ClassName", function(object) {
    !is.null(object@data) && nrow(object@data) > 0
})
```

### Transformation Method  
```r
setMethod("method", "ClassName", function(object, param) {
    # Validate
    if (!hasRequired(object)) stop("Missing prerequisite")
    
    # Compute
    result <- compute(object, param)
    
    # Update
    object@slot <- result
    
    # Validate
    validObject(object)
    
    # Return
    object
})
```

### Replacement Method
```r
setReplaceMethod("method", "ClassName", function(object, value) {
    # Validate value
    if (!valid(value)) stop("Invalid value")
    
    # Create copy of object for modification
    newObj <- new("ClassName")
    newObj@slot <- value
    
    # Return modified object
    newObj
})
```

### Delegation Method
```r
setMethod("method", "ClassName", function(object) {
    # Delegate to parent class or internal object
    method(object@parentSlot)
})
```

---

## 6. Roxygen Documentation

**Place in same file as generic/method**:

```r
#' @title Brief description
#'
#' @description
#' Longer description of what the generic does.
#'
#' @param object An object of class \code{\link{ClassName}}
#' @param param Parameter description
#' @param ... Additional arguments passed to methods
#'
#' @return Description of return value
#'
#' @details
#' More details about implementation
#'
#' @seealso \code{\link{relatedFunction}} for related operations
#'
#' @examples
#' # Example code here
#'
#' @rdname gplotAdjustedRtime
#' @aliases gplotAdjustedRtime,ClassName-method
#'
#' @export
setGeneric("gplotAdjustedRtime", 
           function(object, ...) standardGeneric("gplotAdjustedRtime"))

#' @rdname gplotAdjustedRtime
setMethod("gplotAdjustedRtime", "XCMSnExp",
          function(object, ...) {
    # Implementation
})

#' @rdname gplotAdjustedRtime
setMethod("gplotAdjustedRtime", "XcmsExperiment",
          function(object, ...) {
    # Implementation
})
```

Key directives:
- `@rdname functionName` - Groups documentation of generic and methods
- `@aliases` - Lists method signatures
- `@export` - Exports generic and methods
- Place on generic and each method for complete docs

---

## 7. NAMESPACE Configuration

**File**: `NAMESPACE`

```r
# Export S4 methods
exportMethods(
    "methodName1",
    "methodName2",
    "methodName3<-"  # For replacements
)

# Export S4 classes
exportClasses(
    "ClassName1",
    "ClassName2",
    "ParameterClass"
)

# Export regular functions
export(
    "functionName1",
    "functionName2"
)

# Import from other packages
importFrom("methods", "as", "is", "new", "setClass", 
           "setGeneric", "setMethod", "setReplaceMethod")
importFrom("xcms", "chromPeaks", "adjustedRtime")
```

---

## 8. Testing Your Implementation

```r
# Load package with methods
devtools::load_all()

# Verify generic exists
getGeneric("gplotAdjustedRtime")

# List all methods
methods("gplotAdjustedRtime")
# Output should show:
# [1] gplotAdjustedRtime,XCMSnExp-method
# [2] gplotAdjustedRtime,XcmsExperiment-method

# Test with object
xexp <- XCMSnExp(...)  # Create test object
gplotAdjustedRtime(xexp)  # Should call XCMSnExp method automatically

# Inspect method source
getMethod("gplotAdjustedRtime", "XCMSnExp")
```

---

## 9. Common Mistakes to Avoid

### Mistake 1: Generic has wrong function name
```r
# WRONG
setGeneric("myFunction", function(object) standardGeneric("differentName"))

# RIGHT
setGeneric("myFunction", function(object) standardGeneric("myFunction"))
```

### Mistake 2: Using braces in generic
```r
# WRONG (expensive dispatch)
setGeneric("method", function(object) { standardGeneric("method") })

# RIGHT
setGeneric("method", function(object) standardGeneric("method"))
```

### Mistake 3: Replacement method doesn't return object
```r
# WRONG - missing return
setReplaceMethod("method", "Class", function(object, value) {
    object@slot <- value
    # Returns NULL implicitly!
})

# RIGHT
setReplaceMethod("method", "Class", function(object, value) {
    object@slot <- value
    object  # Explicit return
})
```

### Mistake 4: Not exporting method
```r
# In NAMESPACE, must include:
exportMethods("methodName")

# Otherwise method exists but isn't accessible
```

### Mistake 5: Wrong signature specification
```r
# WRONG - param is optional argument, not dispatch
setMethod("adjustRtime", "XCMSnExp", function(object, param = NULL) {
    # This only dispatches on object class
})

# RIGHT - use signature() to dispatch on param class too
setMethod("adjustRtime",
          signature(object = "XCMSnExp", param = "PeakGroupsParam"),
          function(object, param) {
    # Dispatches on both
})
```

---

## 10. File Organization

Typical XCMS package structure:

```
R/
├── AllGenerics.R           # All setGeneric() declarations
├── DataClasses.R           # S4 class definitions with setClass()
├── methods-XCMSnExp.R      # setMethod() for XCMSnExp class
├── methods-XcmsExperiment.R # setMethod() for XcmsExperiment class
├── XcmsExperiment.R        # XcmsExperiment-specific methods & docs
├── functions-XCMSnExp.R    # Regular functions for visualization, etc.
├── do_*-functions.R        # Computational helper functions
└── zzz.R                   # Package initialization

NAMESPACE                    # Method/class exports

man/
└── *.Rd                     # Generated Rd documentation from roxygen
```

---

## Quick Checklist for New S4 Method

1. Declare generic in `R/AllGenerics.R`
   ```r
   setGeneric("myMethod", function(object, ...) standardGeneric("myMethod"))
   ```

2. Implement method(s) in appropriate file
   ```r
   setMethod("myMethod", "ClassName", function(object, ...) { ... })
   ```

3. Add roxygen documentation above generic/method
   ```r
   #' @title Description
   #' @param object An object of class ClassName
   #' @rdname myMethod
   #' @export
   ```

4. Add to NAMESPACE
   ```r
   exportMethods("myMethod")
   ```

5. Document with roxygen
   ```r
   devtools::document()
   ```

6. Test
   ```r
   devtools::load_all()
   methods("myMethod")
   ```

