# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**


1) in some tests e.g. ".get_sample_data works with XcmsExperiment" you have an object without any files. That won't work. reod that.
2) in utils.R instead of separate check for "Object must be XcmsExperiment or XCMSnExp" you can use .validate_xcms_object and put it as the first check in the function.
