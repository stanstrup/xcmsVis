# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**


1) always reinstall the package after finishing a list of instructions (add to CLAUDE.md)
2) always update the DESCRIPTION file when modifying functions in the package (add to CLAUDE.md)
3) after doing work, always make a commit (add to CLAUDE.md)
4) set PeakGroupsParam as a separate variable instead of inline
5) add test with and without filterFile.
6) add test with and without subset in PeakGroupsParam
7) Since the only way to really compare is visual I need examples of both (see 5 and 6) in the vignette also. Since this will get long arrange to have separete vignettes for each function we will create. For now that means a vignette dedicated to gplotAdjustedRtime.
8) fix these problems from "check" (add files to be ignored at build, don't delete them):
N  checking DESCRIPTION meta-information (364ms)
   License stub is invalid DCF.
N  checking top-level files
   Non-standard files/directories found at top level:
     'future_tasks.md' 'index.md' 'package.json' 'prepare-news.sh'
9) fix also these (some probably need dummy vars to be set since they are caused by dplyr's non standard evaluation):
  .get_sample_data: no visible binding for global variable 'sample_index'
   gplotAdjustedRtime: no visible binding for global variable
     'rtime_adjusted'
   gplotAdjustedRtime: no visible binding for global variable
     'sample_name'
   gplotAdjustedRtime: no visible global function definition for
     'setNames'
   gplotAdjustedRtime: no visible binding for global variable '.'
   gplotAdjustedRtime: no visible binding for global variable 'feature'
   gplotAdjustedRtime: no visible binding for global variable 'adjusted'
   gplotAdjustedRtime: no visible binding for global variable 'correction'
   gplotAdjustedRtime: no visible binding for global variable
     'feature_correct'
   gplotAdjustedRtime: no visible binding for global variable 'text'
   Undefined global functions or variables:
     . adjusted correction feature feature_correct rtime_adjusted
     sample_index sample_name setNames text
10) add  importFrom("stats", "setNames")

    
