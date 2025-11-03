# XCMS Source Code References

This document provides quick reference to the XCMS GitHub repository files that demonstrate the S4 method patterns used in the package.

## Key Files in XCMS Repository

All files are available at: https://github.com/sneumann/xcms

### 1. Generic Function Declarations

**File**: `R/AllGenerics.R`
- **URL**: https://raw.githubusercontent.com/sneumann/xcms/master/R/AllGenerics.R
- **Content**: Contains all setGeneric() declarations for XCMS functions
- **Key Functions**:
  - `adjustRtime()` - Retention time alignment
  - `chromPeaks()` / `chromPeaks<-()` - Peak data access/assignment
  - `findChromPeaks()` - Peak detection
  - `groupChromPeaks()` - Peak correspondence
  - `hasChromPeaks()`, `hasAdjustedRtime()`, `hasFeatures()` - State queries
  - `adjustedRtime()` / `adjustedRtime<-()` - Adjusted RT access/assignment

### 2. XCMSnExp Method Implementations

**File**: `R/methods-XCMSnExp.R`
- **URL**: https://raw.githubusercontent.com/sneumann/xcms/master/R/methods-XCMSnExp.R
- **Content**: All setMethod() implementations for XCMSnExp class
- **Key Methods**:
  - `setMethod("initialize", "XCMSnExp")` - Object initialization
  - `setMethod("show", "XCMSnExp")` - Display representation
  - `setMethod("adjustRtime", signature(object="XCMSnExp", param="PeakGroupsParam"))`
  - `setMethod("adjustRtime", signature(object="XCMSnExp", param="ObiwarpParam"))`
  - `setMethod("adjustedRtime", "XCMSnExp")` - RT getter
  - `setReplaceMethod("adjustedRtime", "XCMSnExp")` - RT setter
  - `setMethod("chromPeaks", "XCMSnExp")`
  - `setReplaceMethod("chromPeaks", "XCMSnExp")`
  - `setMethod("featureDefinitions", "XCMSnExp")`
  - `setReplaceMethod("featureDefinitions", "XCMSnExp")`

### 3. XcmsExperiment Method Implementations

**File**: `R/XcmsExperiment.R` (or look for methods-XcmsExperiment.R)
- **URL**: https://github.com/sneumann/xcms/blob/devel/R/XcmsExperiment.R
- **Content**: Implementation for the modern XcmsExperiment class
- **Key Methods**:
  - `setMethod("adjustRtime", signature(object="MsExperiment", param="PeakGroupsParam"))`
  - `setMethod("adjustRtime", signature(object="MsExperiment", param="ObiwarpParam"))`
  - `setMethod("adjustRtime", signature(object="XcmsExperiment", param="LamaParama"))`
  - Methods delegating to MsExperiment parent class

### 4. Visualization Functions

**File**: `R/functions-XCMSnExp.R`
- **URL**: https://raw.githubusercontent.com/sneumann/xcms/master/R/functions-XCMSnExp.R
- **Content**: Regular plotting functions (not S4 methods) that work with both object types
- **Key Functions**:
  - `plotAdjustedRtime()` - Plot RT alignment results
  - `plotChromPeaks()` - Plot detected peaks in RT-mz space
  - `plotChromPeakImage()` - Heatmap of peak density
  - `highlightChromPeaks()` - Add peak overlays to existing plots

### 5. NAMESPACE Configuration

**File**: `NAMESPACE`
- **URL**: https://raw.githubusercontent.com/sneumann/xcms/master/NAMESPACE
- **Content**: Package namespace declarations
- **Key Directives**:
  - `exportMethods()` - Export S4 methods
  - `exportClasses()` - Export S4 classes
  - `importFrom()` / `importMethodsFrom()` - Import from dependencies

### 6. Data Classes

**File**: `R/DataClasses.R`
- **URL**: https://github.com/sneumann/xcms/blob/master/R/DataClasses.R
- **Content**: S4 class definitions
- **Key Classes**:
  - `XCMSnExp` - Legacy result container
  - `XcmsExperiment` - Modern result container
  - `MsFeatureData` - Internal data storage
  - Parameter classes: `PeakGroupsParam`, `ObiwarpParam`, `LamaParama`, etc.

---

## Example Pattern: adjustRtime Implementation

To understand how XCMS handles dual method dispatch, compare these two implementations:

### For XCMSnExp (Legacy)
Location: `R/methods-XCMSnExp.R`, lines ~100-200
- Method signature: `signature(object = "XCMSnExp", param = "PeakGroupsParam")`
- Uses internal `@msFeatureData` slot
- Returns XCMSnExp object with `@msFeatureData` updated

### For XcmsExperiment (Modern)
Location: `R/XcmsExperiment.R`, lines ~200-300
- Method signature: `signature(object = "MsExperiment", param = "PeakGroupsParam")`
- Uses Spectra infrastructure from parent class
- Returns XcmsExperiment with `rtime_adjusted` spectra variable

Both implement the same conceptual functionality but use different internal representations.

---

## Method Implementation Pattern Summary

Every XCMS processing method follows this structure:

```
1. VALIDATION
   - Check if object has required preprocessing results
   - Validate parameters
   
2. STATE MANAGEMENT  
   - Drop conflicting results from previous runs
   - Ensure clean slate for new results

3. COMPUTATION
   - Call specialized helper function (usually in do_*-functions.R)
   - Pass extracted data and parameters

4. UPDATE
   - Assign computed results back to object
   - Update related slots (e.g., RT adjustment affects peaks)

5. HISTORY
   - Create XProcessHistory object
   - Record analysis step with parameters and timestamp

6. VALIDATION & RETURN
   - Call validObject() to ensure consistency
   - Return modified object
```

Example files showing complete computation pipelines:
- `do_adjustRtime-functions.R` - Computational core for RT adjustment
- `do_findChromPeaks-functions.R` - Peak detection algorithms
- `do_groupChromPeaks-functions.R` - Peak correspondence analysis

---

## Key Insight for Your gplotAdjustedRtime Implementation

XCMS provides two approaches you can use:

### Approach 1: Regular Function (Simple)
Use `plotAdjustedRtime()` as example - regular function that:
1. Accepts object of any type
2. Uses S4 accessor methods to extract data (works with any class implementing those accessors)
3. Performs visualization using extracted data
4. Works transparently with both XCMSnExp and XcmsExperiment

**Pros**: Simple, flexible
**Cons**: No type checking, less discoverable

### Approach 2: S4 Methods (Recommended for XCMS Package)
Like `adjustRtime()`, `findChromPeaks()`, etc.:
1. Declare generic with `setGeneric()`
2. Implement separate methods for each class
3. R automatically dispatches to correct implementation
4. Each method can have class-specific optimizations

**Pros**: Type-safe, extensible, discoverable, follows XCMS conventions
**Cons**: More boilerplate code

---

## Testing Your Implementation

After implementing S4 methods, you can verify they work correctly:

```r
# Load your package
devtools::load_all()

# Check what methods exist
methods("gplotAdjustedRtime")

# Test with both object types
data(faahko_sub)  # This will be XCMSnExp or XcmsExperiment depending on version

# Method dispatch should work automatically
gplotAdjustedRtime(faahko_sub)  # Calls correct method automatically

# You can also force a specific method:
gplotAdjustedRtime(faahko_sub)  # S4 dispatch happens here
```

---

## Further Reading

XCMS Bioconductor Package:
- Vignette: https://bioconductor.org/packages/xcms/
- GitHub: https://github.com/sneumann/xcms
- Reference Manual: https://www.bioconductor.org/packages/devel/bioc/manuals/xcms/man/xcms.pdf

Advanced R S4 Documentation:
- https://adv-r.hadley.nz/s4.html
- R Methods Package: https://stat.ethz.ch/R-manual/R-devel/library/methods/html/Methods.html
