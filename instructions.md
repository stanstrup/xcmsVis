# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**


fix these problems:

> roxygen2::roxygenize();remotes::install_local(".", force = TRUE, dependencies = FALSE)
✖ utils.R:54: @importFrom Excluding unknown export from xcms: `fData`.
Writing NAMESPACE
ℹ Loading xcmsVis
✖ utils.R:54: @importFrom Excluding unknown export from xcms: `fData`.
Writing NAMESPACE
Writing dot-get_spectra_data.Rd
Writing gplotAdjustedRtime.Rd
── R CMD build ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
✔  checking for file 'C:\Users\tmh331\AppData\Local\Temp\RtmpwxBKii\file887455e053a7\xcmsVis/DESCRIPTION' (687ms)
─  preparing 'xcmsVis': (3.3s)
✔  checking DESCRIPTION meta-information ... 
─  checking for LF line-endings in source and make files and shell scripts (1.9s)
─  checking for empty or unneeded directories
   Removed empty directory 'xcmsVis/data'
   Removed empty directory 'xcmsVis/inst/extdata'
   Removed empty directory 'xcmsVis/inst'
   Removed empty directory 'xcmsVis/vignettes/.quarto/idx'
   Omitted 'LazyData' from DESCRIPTION
─  building 'xcmsVis_0.2.0.tar.gz'
   Warning in utils::tar(filepath, pkgname, compression = compression, compression_level = 9L,  :
     storing paths of more than 100 bytes is not portable:
     'xcmsVis/vignettes/.quarto/_freeze/gplotAdjustedRtime/libs/bootstrap/bootstrap-32162a2fca7cb0439643f2faaab1edf3.min.css'
   Warning in utils::tar(filepath, pkgname, compression = compression, compression_level = 9L,  :
     storing paths of more than 100 bytes is not portable:
     'xcmsVis/vignettes/.quarto/_freeze/gplotAdjustedRtime/libs/plotly-htmlwidgets-css-2.11.1/plotly-htmlwidgets.css'
   Warning in utils::tar(filepath, pkgname, compression = compression, compression_level = 9L,  :
     storing paths of more than 100 bytes is not portable:
     'xcmsVis/vignettes/.quarto/_freeze/gplotAdjustedRtime/libs/quarto-html/quarto-syntax-highlighting-2f5df379a58b258e96c21c0638c20c03.css'
