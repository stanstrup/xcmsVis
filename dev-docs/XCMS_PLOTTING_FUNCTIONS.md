# XCMS Plotting Functions Inventory

Comprehensive list of all plotting functions available in XCMS (version 4.8.0+).

## Summary Statistics

- **Total plotting functions**: 24
- **Modern functions** (XCMSnExp/XcmsExperiment): 9
- **Legacy functions** (xcmsRaw/xcmsSet): 12
- **S4 plot methods**: 3 generics with multiple signatures

---

## Modern Functions (Recommended)

Functions that work with modern XCMS objects (XCMSnExp, XcmsExperiment).

| Function | What it Plots | Input Object(s) | Status | Priority for Replication |
|----------|---------------|-----------------|--------|-------------------------|
| `plotAdjustedRtime` | RT adjustment results: difference between adjusted and raw RT vs RT | XCMSnExp, XcmsExperiment | ✅ Active | ⭐⭐⭐ **DONE** |
| `plotChromPeaks` | Detected chromatographic peaks as rectangles in RT-m/z space | XCMSnExp, XcmsExperiment | ✅ Active | ⭐⭐⭐ High |
| `plotChromPeakImage` | Heatmap/image of peak density across samples and retention time | XCMSnExp, XcmsExperiment | ✅ Active | ⭐⭐ Medium |
| `plotChromPeakDensity` | Peak density along RT with feature grouping visualization | XCMSnExp (with PeakDensityParam) | ✅ Active | ⭐⭐ Medium |
| `plotFeatureGroups` | Feature groups in m/z-RT space with connecting lines | XCMSnExp, XcmsExperiment (with feature groups) | ✅ Active | ⭐⭐ Medium |
| `highlightChromPeaks` | Adds peak annotations to existing chromatogram plots | XCMSnExp | ✅ Active | ⭐ Low (utility) |
| `plotPrecursorIons` | MS/MS precursor ions in RT-m/z space | MsExperiment (LC-MS/MS) | ✅ Active | ⭐ Low (MS/MS only) |
| `plotChromatogramsOverlay` | Multiple chromatograms overlaid in one plot | MChromatograms, XChromatograms | ✅ Active | ⭐⭐ Medium |
| `plot` (S4 method) | Standard plot interface for spectra/XIC with peaks | XCMSnExp, XChromatogram(s) | ✅ Active | ⭐⭐⭐ High |

---

## Legacy Functions (xcmsRaw/xcmsSet)

Functions designed for older XCMS objects. Many have modern equivalents.

### Quality Control & Alignment

| Function | What it Plots | Input Object(s) | Status | Notes |
|----------|---------------|-----------------|--------|-------|
| `plotQC` | QC diagnostics: m/z deviations, RT deviations, histograms | xcmsSet (grouped) | ⚠️ Legacy | 6 plot types; superseded by modern QC methods |
| `plotrt` | RT deviation profiles for each sample after alignment | xcmsSet | ⚠️ Legacy | Similar to plotAdjustedRtime |

### Raw Data Visualization

| Function | What it Plots | Input Object(s) | Status | Notes |
|----------|---------------|-----------------|--------|-------|
| `plotTIC` | Total ion chromatogram (TIC vs RT) | xcmsRaw | ⚠️ Legacy | Interactive identification available |
| `plotRaw` | Raw data points in RT-m/z scatter | xcmsRaw | ⚠️ Legacy | Best for centroided data |
| `plotEIC` | Extracted ion chromatogram from raw data | xcmsRaw | ⚠️ Legacy | Uses raw data, not profile |
| `plotChrom` | EIC from profile matrix with optional Gaussian fit | xcmsRaw | ⚠️ Legacy | Interactive; uses profile matrix |
| `plotScan` | Single mass scan (impulse representation) | xcmsRaw | ⚠️ Legacy | Interactive m/z identification |
| `plotSpec` | Averaged mass spectrum over RT range | xcmsRaw | ⚠️ Legacy | Uses profile matrix |
| `plotPeaks` | Grid of multiple EICs with integration bounds | xcmsRaw + peaks matrix | ⚠️ Legacy | Useful for peak picking QC |
| `plotSurf` | Interactive 3D surface plot using OpenGL | xcmsRaw | ⚠️ Legacy | Requires rgl package |
| `image` (S4) | False-color log intensity image | xcmsRaw | ⚠️ Legacy | Base R image function |
| `levelplot` (S4) | Lattice-based intensity heatmap | xcmsRaw, xcmsSet | ⚠️ Legacy | Can show RT correction |

### Specialized Functions

| Function | What it Plots | Input Object(s) | Status | Notes |
|----------|---------------|-----------------|--------|-------|
| `plot.xcmsEIC` (S3) | Batch plot of multiple EICs from multiple files | xcmsEIC | ⚠️ Legacy | Can overlay peak areas |
| `plotTree` | Text-based MS/MS fragmentation hierarchy tree | xcmsFragments | ⚠️ Legacy | Shows parent-fragment relationships |
| `plotMsData` | Combined XIC + RT-m/z scatter | data.frame from extractMsData() | ❌ Deprecated | Use MsExperiment plot() instead |

---

## Function Details

### Modern Functions

#### plotAdjustedRtime ✅ IMPLEMENTED
**Purpose**: Visualize retention time alignment results
**Input**: XCMSnExp, XcmsExperiment
**Output**: Scatter plot showing RT adjustment (adjusted - raw) vs retention time
**Special features**:
- Shows which peak groups were used for alignment (if applicable)
- Color-coded by sample or sample group
- Helps evaluate alignment quality

**Implementation status**: ✅ Available as `gplotAdjustedRtime()` in xcmsVis

---

#### plotChromPeaks
**Purpose**: Visualize all detected chromatographic peaks
**Input**: XCMSnExp, XcmsExperiment
**Output**: Scatter plot with peaks as rectangles in RT-m/z space
**Special features**:
- Each peak shown as rectangle (RT width × m/z width)
- Can filter by sample, m/z range, RT range
- Color-coded by sample or other metadata

**Use cases**:
- Assess peak detection quality
- Identify m/z regions with many peaks
- Check for systematic issues

---

#### plotChromPeakImage
**Purpose**: Heatmap showing peak density across samples
**Input**: XCMSnExp, XcmsExperiment
**Output**: Image/heatmap with samples (rows) vs RT bins (columns)
**Special features**:
- Color intensity shows number of peaks in each bin
- Reveals patterns in peak detection across samples
- Can highlight missing peaks or batch effects

**Use cases**:
- Quality control across sample batches
- Identify systematic missing peaks
- Detect RT drift before alignment

---

#### plotChromPeakDensity
**Purpose**: Evaluate peak grouping parameters
**Input**: XCMSnExp with PeakDensityParam
**Output**: Peak density plot along RT with grouping visualization
**Special features**:
- Shows which peaks would be grouped together
- Displays bandwidth and minFraction thresholds
- Interactive parameter optimization

**Use cases**:
- Optimize PeakDensityParam settings
- Understand why peaks are/aren't grouped
- QC correspondence analysis

---

#### plotFeatureGroups
**Purpose**: Visualize feature relationships after groupFeatures()
**Input**: XCMSnExp, XcmsExperiment (with feature groups)
**Output**: Features in m/z-RT space with connecting lines
**Special features**:
- Lines connect features in same group
- Shows isotope, adduct, and fragment relationships
- Color-coded by group type

**Use cases**:
- Understand feature annotation results
- Identify isotope patterns
- QC adduct and fragment assignments

---

#### plotChromatogramsOverlay
**Purpose**: Overlay multiple chromatograms
**Input**: MChromatograms, XChromatograms
**Output**: Multiple EICs overlaid in single plot
**Special features**:
- Supports stacking mode (separate panels)
- Highlights detected peaks for XChromatograms
- Color-coded by sample/group

**Use cases**:
- Compare same m/z across samples
- Visual QC of peak detection
- Compare before/after RT alignment

---

#### plot (S4 methods)
**Purpose**: Standard plot interface for XCMS objects
**Input**: XCMSnExp, XChromatogram, XChromatograms
**Output**: Varies by object type
**Signatures**:
- `plot(XCMSnExp, missing)` - Plots spectra or XIC
- `plot(XChromatogram, ANY)` - Single chromatogram with peaks
- `plot(XChromatograms, ANY)` - Grid of chromatograms

**Use cases**:
- Quick visualization using standard R syntax
- Integrate with base R plotting workflows

---

### Legacy Functions

#### plotQC
**Purpose**: Comprehensive QC diagnostics
**Input**: xcmsSet (grouped)
**Output**: One of 6 QC plot types
**Plot types**:
1. `mzdevhist` - Histogram of m/z deviations
2. `rtdevhist` - Histogram of RT deviations
3. `mzdevmass` - m/z deviation vs m/z
4. `mzdevtime` - m/z deviation vs RT
5. `mzdevsample` - m/z deviation by sample
6. `rtdevsample` - RT deviation by sample

**Use cases**:
- Assess alignment quality
- Identify systematic m/z or RT biases
- Compare sample quality

---

#### plotrt
**Purpose**: RT deviation profiles
**Input**: xcmsSet
**Output**: RT deviation for each sample
**Special features**:
- Can overlay peak density
- Shows how RT correction was applied

**Use cases**:
- Similar to plotAdjustedRtime
- Legacy alternative for xcmsSet objects

---

## Prioritization for xcmsVis Implementation

### Priority 1: High Value ⭐⭐⭐
1. ✅ `plotAdjustedRtime` - DONE
2. `plotChromPeaks` - Core functionality, high usage
3. `plot` (S4 methods) - Standard interface

### Priority 2: Medium Value ⭐⭐
4. `plotChromPeakImage` - Useful QC
5. `plotChromPeakDensity` - Parameter optimization
6. `plotFeatureGroups` - Feature annotation QC
7. `plotChromatogramsOverlay` - Common use case

### Priority 3: Lower Priority ⭐
8. `highlightChromPeaks` - Utility function
9. `plotPrecursorIons` - MS/MS specific
10. Legacy functions - Lower priority as they're being phased out

---

## Design Considerations for xcmsVis

### Consistent API Design
All xcmsVis functions should follow this pattern:
```r
gplot<FunctionName>(object,
                    color_by,           # NSE column name
                    include_columns,    # Additional metadata
                    ...)                # Function-specific args
```

### Plotly Support
All plots should be ggplot2-based with:
- Informative hover tooltips
- Interactive legends
- Easy conversion to plotly via `ggplotly()`

### Dual Object Support
All functions should handle both:
- XCMSnExp (legacy but still used)
- XcmsExperiment (modern)

Use internal helpers like `.get_sample_data()` and `.validate_xcms_object()` for consistency.

### Documentation
Each function should include:
- Comprehensive examples using faahKO data
- Side-by-side comparison with XCMS original
- Vignette demonstrating usage
- Alt-text for accessibility

---

## Notes

- This inventory is based on XCMS version 4.8.0
- Focus on modern functions for new implementations
- Legacy functions may be useful for users migrating old workflows
- Some functions have overlapping functionality - prioritize based on user needs
