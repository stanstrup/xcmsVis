#' @include AllGenerics.R
NULL

#' @rdname gplotPrecursorIons
#'
#' @importFrom ggplot2 ggplot aes geom_point labs theme_bw coord_cartesian
#' @importFrom Spectra rtime precursorMz filterEmptySpectra mz dataOrigin
#' @importFrom MsExperiment spectra
#' @importFrom methods is
#' @importClassesFrom MsExperiment MsExperiment
setMethod("gplotPrecursorIons", "MsExperiment", function(object,
                                                         pch = 21,
                                                         col = "#00000080",
                                                         bg = "#00000020", ...){
    n_files <- length(object)
    plots <- list()
    for (i in seq_along(object)) {
        x_sub <- object[i]
        spctra <- spectra(x_sub)
        rtr <- range(rtime(spctra))
        mzr <- range(range(mz(filterEmptySpectra(spctra))))
        pmz <- precursorMz(spctra)
        prt <- rtime(spctra[!is.na(pmz)])
        pmz <- pmz[!is.na(pmz)]
        plot_title <- basename(dataOrigin(spctra[1L]))
        if (length(pmz) > 0) {
            plot_data <- data.frame(rt = prt,mz = pmz)
            p <- ggplot(plot_data, aes(x = rt, y = mz)) +
                geom_point(shape = pch, color = col, fill = bg, size = 2) +
                coord_cartesian(xlim = rtr, ylim = mzr) +
                labs(x = "retention time", y = "m/z", title = plot_title) +
                theme_bw()
        } else {
            p <- ggplot() +
                labs(x = "retention time", y = "m/z",
                     title = paste0(plot_title, " (no MS2 data)")) +
                theme_bw()
        }
        plots[[i]] <- p
    }
    if (n_files == 1)
        return(plots[[1]])
    else
        return(plots)
})
