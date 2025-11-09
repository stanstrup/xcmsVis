# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

N  checking for hidden files and directories ... 
   Found the following hidden files and directories:
     xcms-reference/.BBSoptions
     xcms-reference/.Rbuildignore
     xcms-reference/.editorconfig
     xcms-reference/.github
     
     
N  checking top-level files ...
   Non-standard files/directories found at top level:
     'Rplots.pdf' 'xcms-reference'
     
N  checking package subdirectories (1.9s)
   Found the following CITATION file in a non-standard place:
     xcms-reference/inst/CITATION
   Most likely 'inst/CITATION' should be used instead.
   
   
   .gplotFeatureGroups_impl: no visible binding for global variable
     'feature_group'
   .gplotFeatureGroups_impl: no visible binding for global variable
     'Retention Time'
   .gplotFeatureGroups_impl: no visible binding for global variable 'm/z'
   .gplotFeatureGroups_impl: no visible binding for global variable
     'group'
   Undefined global functions or variables:
     Retention Time feature_group group m/z
     
from the example:
   > gplotFeatureGroups(xdata, featureGroups = c("FG.001", "FG.002"))
   Error: None of the specified feature groups found
   
   I think it needs to be 0001 and not 001.
   
   
❯ checking top-level files ... NOTE
  Non-standard files/directories found at top level:
    'Rplots.pdf' 'xcms-reference'
    
    
