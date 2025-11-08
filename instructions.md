# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and
resources.**

## Fixed Issues (2025-11-08)

All issues from the previous R CMD check have been resolved:

### 1. ✅ Fixed Rd cross-reference warning

- **Issue**:
  `Missing link(s) in Rd file 'gplotFeatureGroups.Rd': '[xcms]{groupFeatures}'`
- **Solution**: Updated seealso section to use correct link format and
  reference
  [`MsFeatures::groupFeatures()`](https://rdrr.io/pkg/MsFeatures/man/groupFeatures.html)
- **Files modified**: `R/AllGenerics.R`

### 2. ✅ Fixed ‘package:stats’ warnings during adjustRtime()

- **Issue**:
  `Warning in serialize(data, node$con): 'package:stats' may not be available when loading`
- **Solution**: Added `register(SerialParam())` before
  [`adjustRtime()`](https://rdrr.io/pkg/xcms/man/adjustRtime.html) call
  to disable parallel processing
- **Files modified**: `R/AllGenerics.R`

### 3. ✅ Fixed “could not find function ‘groupFeatures’” error

- **Issue**:
  `Error in groupFeatures(xdata, param = SimilarRtimeParam()): could not find function "groupFeatures"`
- **Solution**:
  - Added
    [`library(MsFeatures)`](https://github.com/RforMassSpectrometry/MsFeatures)
    to example code (groupFeatures is from MsFeatures, not xcms)
  - MsFeatures was already in Suggests section of DESCRIPTION
- **Files modified**: `R/AllGenerics.R`

### Verification

Example code now runs successfully without errors or warnings: - ✅ No
“could not find function ‘groupFeatures’” error - ✅ No ‘package:stats’
warnings - ✅ Plot created successfully - ✅ Documentation regenerated
with roxygen2

## Next Steps

Run full R CMD check when WSL file system issues are resolved, or test
on a different system.
