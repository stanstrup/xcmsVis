# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

1) ✅ ~~Remove everything else than the "Current Tasks" section from this file~~
2) Remove eval=FALSE from the vignette. We want to see the plots! Also make sure it actually works!
3) Don't bother with XCMSnExp in the examples/vignettes, but make tests that make sure it works. In fact make sure all functions have tests.
4) Cleanup temporary files
5) Semantic versioning should be setup like in remoteUpdater. Also NEWS.md is not compatible with pkgdown. Look at remoteUpdater for the right setup of pkgdown and semantic release. Make the same setup, including GitHub Actions.
6) When this works, and only when it is confirmed to work, push to https://github.com/stanstrup
