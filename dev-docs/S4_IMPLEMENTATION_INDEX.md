# S4 Method Implementation - Complete Index

This index helps you navigate the comprehensive S4 method implementation guides created to help refactor `gplotAdjustedRtime` to use proper S4 method dispatch for both XCMSnExp and XcmsExperiment objects.

---

## Documents Created

### 1. README_S4_IMPLEMENTATION.md
**START HERE** - Overview of all documents with quick-start instructions

**Contents:**
- Document overview and when to use each
- Quick-start: Converting gplotAdjustedRtime to S4 methods (6-step process)
- Benefits of S4 methods vs regular functions
- Key XCMS patterns (state management, data extraction, signature dispatch)
- File organization recommendations
- Testing checklist
- Common issues and solutions
- Next steps

**Use when:** You want a high-level overview or quick implementation steps

---

### 2. XCMS_S4_METHODS_GUIDE.md  
**COMPREHENSIVE REFERENCE** - In-depth guide with all patterns and philosophy

**Contents (548 lines):**

1. **Generic Function Declaration**
   - Core examples from XCMS
   - Design principles
   - setGeneric() syntax

2. **Parameter Dispatch Patterns**
   - How XCMS uses different param classes for algorithm selection
   - signature() specification
   - Multiple implementations for same generic

3. **Method Implementation Examples** (4 complete examples)
   - Simple accessor methods
   - Complex processing methods (full validation → computation → update → history)
   - Replacement methods with cascading updates
   - Show/display methods

4. **NAMESPACE Export Configuration**
   - exportMethods() for S4 methods
   - exportClasses() for S4 classes
   - Import configuration

5. **Dual-Class Support Pattern**
   - Implementation Pattern A: Separate methods per class
   - Implementation Pattern B: Inheritance via parent classes

6. **Visualization Function Pattern**
   - How plotAdjustedRtime works with multiple types

7. **Implementation Guide for gplotAdjustedRtime**
   - Current approach vs recommended approach
   - 4-step implementation process
   - Benefits summary

8. **Roxygen Documentation Pattern**
   - Complete example with generic + both methods
   - rdname, aliases, export directives

9. **Summary of Key Takeaways**

**Use when:** You want detailed explanation, examples, and understanding of the philosophy

---

### 3. S4_QUICK_REFERENCE.md
**SYNTAX CARD** - Quick copy-paste reference for all patterns

**Contents (415 lines):**

1. Declaring generic functions
2. Implementing methods (single class)
3. Parameter dispatch (multiple implementations)
4. Dual class support
5. Common patterns:
   - Accessor methods
   - Validator methods
   - Transformation methods
   - Replacement methods
   - Delegation methods
6. Roxygen documentation syntax
7. NAMESPACE configuration
8. Testing/verification commands
9. Common mistakes and fixes
10. File organization template
11. Implementation checklist

**Use when:** You need syntax examples, debugging your code, or checking implementation steps

---

### 4. XCMS_SOURCE_REFERENCES.md
**EXTERNAL REFERENCES** - Links to actual XCMS source code demonstrating patterns

**Contents (199 lines):**

1. **Key XCMS Files with GitHub URLs:**
   - AllGenerics.R - Where generics are declared
   - methods-XCMSnExp.R - Legacy object methods
   - XcmsExperiment.R - Modern object methods
   - functions-XCMSnExp.R - Visualization functions
   - NAMESPACE - Export configuration
   - DataClasses.R - Class definitions

2. **Pattern Examples**
   - adjustRtime for XCMSnExp vs XcmsExperiment comparison
   - Method implementation pattern (6-step checklist)
   - Computational pipeline files

3. **Two Implementation Approaches**
   - Approach 1: Regular function (plotAdjustedRtime example)
   - Approach 2: S4 methods (adjustRtime example)

4. **Testing Verification**
5. **Further Reading**

**Use when:** You want to see actual working examples in the XCMS codebase, or verify your understanding against real code

---

## Recommended Reading Order

### For Quick Implementation
1. README_S4_IMPLEMENTATION.md - Quick-start (5 min)
2. S4_QUICK_REFERENCE.md - Syntax lookup (10 min)
3. Implement following the 6-step process

### For Deep Understanding
1. README_S4_IMPLEMENTATION.md - Overview (5 min)
2. XCMS_S4_METHODS_GUIDE.md - Full reference (20 min)
3. S4_QUICK_REFERENCE.md - Syntax verification (10 min)
4. XCMS_SOURCE_REFERENCES.md - See examples (10 min)
5. Implement with full understanding

### For Debugging
1. S4_QUICK_REFERENCE.md - Common mistakes section
2. README_S4_IMPLEMENTATION.md - Issues and solutions
3. XCMS_SOURCE_REFERENCES.md - Compare with working examples

---

## Quick Navigation by Task

### "I need syntax for..."
→ S4_QUICK_REFERENCE.md (Use Ctrl+F to find)

### "I don't understand why..."
→ XCMS_S4_METHODS_GUIDE.md (Detailed explanations)

### "Show me how XCMS does it"
→ XCMS_SOURCE_REFERENCES.md (Links to actual code)

### "What are the steps?"
→ README_S4_IMPLEMENTATION.md (Quick-start section)

### "I have an error, how do I fix it?"
→ README_S4_IMPLEMENTATION.md (Issues and solutions section)

### "What's the complete pattern?"
→ XCMS_S4_METHODS_GUIDE.md (Full examples with explanation)

---

## Key Concepts Summary

### Generic Function
Single declaration of what a function does, without implementation
```r
setGeneric("functionName", function(object, ...) standardGeneric("functionName"))
```

### Method
Implementation for a specific class
```r
setMethod("functionName", "ClassName", function(object, ...) { ... })
```

### Signature
Specifies which classes trigger which method
```r
setMethod("method", signature(object = "Class1", param = "Class2"), ...)
```

### Dispatch
R automatically calls the right method based on object class
```r
obj <- XCMSnExp(...)
gplotAdjustedRtime(obj)  # Automatically calls XCMSnExp method
```

---

## File Structure for Implementation

After implementing S4 methods, your project will have:

```
R/
├── AllGenerics.R              ← Declare generic here
│   └── setGeneric("gplotAdjustedRtime", ...)
│
├── methods-XCMSnExp.R         ← XCMSnExp method
│   └── setMethod("gplotAdjustedRtime", "XCMSnExp", ...)
│
├── methods-XcmsExperiment.R   ← XcmsExperiment method (or in XcmsExperiment.R)
│   └── setMethod("gplotAdjustedRtime", "XcmsExperiment", ...)
│
└── other_files.R

NAMESPACE
└── exportMethods("gplotAdjustedRtime")  ← Export here

man/
└── gplotAdjustedRtime.Rd     ← Auto-generated from roxygen
```

---

## Implementation Checklist

- [ ] Read README_S4_IMPLEMENTATION.md for overview
- [ ] Review XCMS_S4_METHODS_GUIDE.md example implementations
- [ ] Declare generic in R/AllGenerics.R using S4_QUICK_REFERENCE.md
- [ ] Implement method for XCMSnExp in R/methods-XCMSnExp.R
- [ ] Implement method for XcmsExperiment in R/methods-XcmsExperiment.R
- [ ] Add roxygen documentation to generic declaration
- [ ] Update NAMESPACE with exportMethods("gplotAdjustedRtime")
- [ ] Run `devtools::document()` to generate .Rd file
- [ ] Run `devtools::load_all()` to load package
- [ ] Test with `methods("gplotAdjustedRtime")` - should show 2 methods
- [ ] Test with both object types to verify dispatch works
- [ ] Check `?gplotAdjustedRtime` for documentation
- [ ] Verify no errors and correct method is called

---

## Common Questions

**Q: Do I need to change my visualization code?**
A: No, only the dispatch mechanism. Use same data extraction within each method.

**Q: What if I want to keep a regular function version?**
A: You can have both - S4 methods for the package, plus a simpler function for users.

**Q: How do I test which method gets called?**
A: Add debug statements, or use `methods("gplotAdjustedRtime")` and `class(object)` to verify.

**Q: Can I have different parameter names in different methods?**
A: The signature parameters must match, but additional parameters can differ.

**Q: Why does XCMS use this pattern?**
A: Enables clean separation of concerns, extensibility, backward compatibility, and type safety.

---

## Additional Resources

### In These Documents
- XCMS_S4_METHODS_GUIDE.md: Section 8 (Roxygen documentation)
- S4_QUICK_REFERENCE.md: Section 6 (Roxygen documentation syntax)
- S4_QUICK_REFERENCE.md: Section 9 (Common mistakes)

### External
- Advanced R S4: https://adv-r.hadley.nz/s4.html
- R Methods Package: https://stat.ethz.ch/R-manual/R-devel/library/methods/html/Methods.html
- XCMS GitHub: https://github.com/sneumann/xcms

---

## Document Statistics

| Document | Lines | Focus | Read Time |
|----------|-------|-------|-----------|
| README_S4_IMPLEMENTATION.md | 310 | Overview & Quick Start | 10 min |
| XCMS_S4_METHODS_GUIDE.md | 548 | Detailed Examples & Philosophy | 30 min |
| S4_QUICK_REFERENCE.md | 415 | Syntax & Quick Lookup | 15 min |
| XCMS_SOURCE_REFERENCES.md | 199 | External Examples & Links | 15 min |
| **Total** | **~1,470** | **Complete Reference** | **70 min** |

---

## Notes

- All guides use actual XCMS code patterns as examples
- Code examples are copy-paste ready
- Each guide stands alone but references the others
- Includes both simple and complex examples
- Common mistakes section helps avoid issues
- Testing procedures ensure correct implementation

---

**Last Updated**: November 3, 2025
**Purpose**: S4 method implementation guide for xcmsVis package
**Related To**: gplotAdjustedRtime refactoring to support both XCMSnExp and XcmsExperiment objects
