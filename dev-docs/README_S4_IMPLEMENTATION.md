# S4 Method Implementation Guide for xcmsVis

This directory contains comprehensive guides for implementing S4 methods following XCMS patterns for your `gplotAdjustedRtime` function.

## Document Overview

### 1. XCMS_S4_METHODS_GUIDE.md (Main Reference)
**Comprehensive guide with all patterns and examples**

- Generic function declaration patterns
- Method signature specifications with parameter dispatch
- Complete implementation examples:
  - Simple accessor methods
  - Complex processing methods with validation and history tracking
  - Replacement methods with cascading updates
  - Show/display methods
- Namespace export configuration
- Dual-class support patterns (XCMSnExp + XcmsExperiment)
- Visualization function patterns
- Practical implementation guide for gplotAdjustedRtime
- Roxygen documentation patterns
- Summary of key takeaways

**Best for**: Understanding the philosophy and complete patterns

### 2. S4_QUICK_REFERENCE.md (Quick Lookup)
**Quick syntax reference card**

- Concise syntax examples for each pattern
- Generic declaration
- Single/multiple class implementations
- Parameter dispatch methods
- Common method patterns (accessor, validator, transformation, replacement, delegation)
- Roxygen documentation syntax
- NAMESPACE configuration
- Testing commands
- Common mistakes and how to fix them
- File organization best practices
- Implementation checklist

**Best for**: Quick copy-paste syntax and checking your implementation

### 3. XCMS_SOURCE_REFERENCES.md (Source Code Links)
**Direct links to XCMS source files**

- GitHub URLs to XCMS files demonstrating each pattern
- File descriptions and key functions
- Example locations in code
- adjustRtime pattern comparison (XCMSnExp vs XcmsExperiment)
- Method implementation checklist
- Two implementation approaches (regular function vs S4 methods)
- Testing verification steps
- Further reading resources

**Best for**: Finding actual working examples in the XCMS codebase

---

## Quick Start: Converting gplotAdjustedRtime to S4 Methods

### Current Approach (if/else type checking)
```r
gplotAdjustedRtime <- function(object, ...) {
    if (is(object, "XCMSnExp")) {
        # Handle XCMSnExp
    } else if (is(object, "XcmsExperiment")) {
        # Handle XcmsExperiment
    }
}
```

### New S4 Approach

#### Step 1: Declare Generic in R/AllGenerics.R
```r
setGeneric("gplotAdjustedRtime", 
           function(object, ...) standardGeneric("gplotAdjustedRtime"))
```

#### Step 2: Implement Method for XCMSnExp in R/methods-XCMSnExp.R
```r
#' @rdname gplotAdjustedRtime
setMethod("gplotAdjustedRtime", "XCMSnExp",
          function(object, ...) {
    # Extract data using S4 accessors
    rt <- rtime(object, bySample = TRUE)
    adj_rt <- adjustedRtime(object, bySample = TRUE)
    peaks <- chromPeaks(object)
    
    # XCMSnExp-specific visualization code
    # ...
})
```

#### Step 3: Implement Method for XcmsExperiment in R/XcmsExperiment.R
```r
#' @rdname gplotAdjustedRtime
setMethod("gplotAdjustedRtime", "XcmsExperiment",
          function(object, ...) {
    # Extract data using S4 accessors
    rt <- rtime(object, bySample = TRUE)
    adj_rt <- adjustedRtime(object, bySample = TRUE)
    peaks <- chromPeaks(object)
    
    # XcmsExperiment-specific visualization code
    # ...
})
```

#### Step 4: Add Roxygen Documentation
Place above the setGeneric() call:

```r
#' @title Visualize Adjusted Retention Times
#'
#' @description
#' Creates graphics to visualize retention time alignment results.
#'
#' @param object An XCMSnExp or XcmsExperiment object with alignment results
#' @param ... Additional arguments passed to methods
#'
#' @return Invisibly returns the plot object
#'
#' @seealso \code{\link{adjustRtime}} for performing alignment
#'
#' @rdname gplotAdjustedRtime
#' @aliases gplotAdjustedRtime,XCMSnExp-method
#' @aliases gplotAdjustedRtime,XcmsExperiment-method
#'
#' @examples
#' # Load data
#' data(faahko)
#' 
#' # Perform alignment (if not already done)
#' # xexp <- adjustRtime(xexp, param = PeakGroupsParam())
#' 
#' # Visualize results
#' # gplotAdjustedRtime(xexp)
#'
#' @export
```

#### Step 5: Update NAMESPACE
Add to existing `exportMethods()` call:
```r
exportMethods(
    # ... existing methods ...
    "gplotAdjustedRtime"
)
```

#### Step 6: Document and Test
```r
# Generate documentation from roxygen comments
devtools::document()

# Load package
devtools::load_all()

# Verify methods exist
methods("gplotAdjustedRtime")

# Test with both object types
data(faahko_sub)
gplotAdjustedRtime(faahko_sub)  # Automatically calls correct method
```

---

## Why S4 Methods Over Regular Functions?

### Benefits of S4 Methods (Recommended)
1. **Type Safety**: R dispatches automatically, no if/else needed
2. **Extensibility**: Third-party packages can add new methods
3. **Discoverability**: `methods("gplotAdjustedRtime")` shows all implementations
4. **Documentation**: roxygen generates proper method documentation
5. **Consistency**: Follows XCMS package conventions
6. **Maintainability**: Clear separation of class-specific logic

### When to Use Regular Functions
- Simple utility functions that don't change behavior by class
- Plotting functions that use generic accessors only
- Wrapper functions that call S4 methods

---

## Key XCMS Patterns

### 1. State Management Pattern
Every processing method follows this structure:
- **Validate**: Check prerequisites
- **Prepare**: Drop conflicting results
- **Compute**: Call helper functions
- **Update**: Modify object slots
- **History**: Track in process history
- **Validate**: Check object consistency
- **Return**: Return modified object

### 2. Data Extraction Pattern
Use S4 accessor methods to extract data:
```r
rt <- rtime(object, bySample = TRUE)
adj_rt <- adjustedRtime(object, bySample = TRUE)
peaks <- chromPeaks(object)
```

This works transparently with both XCMSnExp and XcmsExperiment.

### 3. Signature Dispatch Pattern
Distinguish between different algorithms:
```r
# Same generic, different methods for different param classes
setMethod("adjustRtime", signature(object = "XCMSnExp", param = "PeakGroupsParam"), ...)
setMethod("adjustRtime", signature(object = "XCMSnExp", param = "ObiwarpParam"), ...)
```

---

## File Organization in xcmsVis

Recommended structure following XCMS patterns:

```
R/
├── AllGenerics.R              # Declare gplotAdjustedRtime generic here
├── methods-XCMSnExp.R         # Implement method for XCMSnExp
├── methods-XcmsExperiment.R   # Implement method for XcmsExperiment
└── ... (other files)

man/
├── gplotAdjustedRtime.Rd      # Auto-generated from roxygen

NAMESPACE                        # Add exportMethods("gplotAdjustedRtime")
```

---

## Testing Checklist

After implementation, verify:

```r
# 1. Generic exists
getGeneric("gplotAdjustedRtime")

# 2. Both methods are defined
methods("gplotAdjustedRtime")
# Should show:
# [1] gplotAdjustedRtime,XCMSnExp-method
# [2] gplotAdjustedRtime,XcmsExperiment-method

# 3. Roxygen documentation is generated
?gplotAdjustedRtime

# 4. Methods can be called
data(faahko_sub)
gplotAdjustedRtime(faahko_sub)

# 5. Correct method is dispatched
class(faahko_sub)  # Check class
# Then call and verify correct implementation runs
```

---

## Common Issues and Solutions

### Issue: "no applicable method for 'gplotAdjustedRtime' applied to..."
**Solution**: Method not exported in NAMESPACE. Check that `exportMethods("gplotAdjustedRtime")` is present.

### Issue: Method defined but methods() doesn't show it
**Solution**: Run `devtools::document()` and reload with `devtools::load_all()`.

### Issue: Both XCMSnExp and XcmsExperiment call same method
**Solution**: Make sure both methods are implemented separately, not just inheriting from a parent class.

### Issue: "Error: attempt to redefine class"
**Solution**: This happens if generic already defined. Use `setGeneric(..., where = asNamespace("xcmsVis"))` if needed.

---

## Next Steps

1. Read **XCMS_S4_METHODS_GUIDE.md** for detailed explanation
2. Use **S4_QUICK_REFERENCE.md** for syntax lookup during implementation
3. Refer to **XCMS_SOURCE_REFERENCES.md** to see working examples in XCMS code
4. Follow the implementation steps above
5. Run the testing checklist
6. Commit changes with clear message explaining S4 migration

---

## References

- XCMS GitHub: https://github.com/sneumann/xcms
- XCMS Methods Files:
  - AllGenerics: https://raw.githubusercontent.com/sneumann/xcms/master/R/AllGenerics.R
  - XCMSnExp Methods: https://raw.githubusercontent.com/sneumann/xcms/master/R/methods-XCMSnExp.R
- Advanced R S4: https://adv-r.hadley.nz/s4.html
- R Methods Package: https://stat.ethz.ch/R-manual/R-devel/library/methods/html/Methods.html

---

## Questions?

Refer to the appropriate guide:
- **"What's the syntax for..."** → S4_QUICK_REFERENCE.md
- **"How do I implement..."** → XCMS_S4_METHODS_GUIDE.md
- **"Where can I see an example..."** → XCMS_SOURCE_REFERENCES.md

