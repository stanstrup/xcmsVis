# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and
resources.**

1.  index.md is outdated. please update.
2.  update the XCMS Workflow Context in teh vignettes to have the arrow
    outside the box and the box porperly aligned. I fixed it in the
    first vignette. fix the otehrs in the same way.
3.  replace plaste with glue in the vignettes. remember to update
    description file.
4.  in the interactive section of vignette 1 explain that you can get
    each part of teh plot by ggplotly(p\[\[1\]\]) and
    ggplotly(p\[\[2\]\])
5.  xlab and ylab are parameters for gplotPrecursorIons. change like in
    the other functions to use ggplot functions “added” to the plot
    instead.
6.  find other parameter across all functions that could be changed to
    native ggplot2 functions that change colors/title etc
