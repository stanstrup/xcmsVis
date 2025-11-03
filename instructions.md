# Current Tasks

**See `CLAUDE.md` for development workflow, conventions, and resources.**

✅ implement a helper function that works with both XcmsExperiment and XCMSnExp to replace:

```
object %>%
            spectra %>%
            spectraData %>%
            as.data.frame
```

XCMSnExp needs:
fData(xdata) %>%
         mutate(rtime_adjusted = rtime(xdata, adjusted = TRUE)) %>%
         rownames_to_column("fromFile") %>%
         mutate(fromFile = as.integer(gsub("^F(.*?)\\.S.*", "\\1", fromFile))) %>%
         left_join(pData(xdata), by = c(fromFile = "sample_index")) %>%
         dplyr::rename(rtime = "retentionTime")

XcmsExperiment needs the current version:
spectraData(spectra(xdata2)) %>% as.data.frame


✅ convert to pipelines where I nested.
