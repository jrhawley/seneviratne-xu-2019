# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("ggplot2"))

# ==============================================================================
# Functions
# ==============================================================================

# ==============================================================================
# Data
# ==============================================================================
peak_metadata = data.table(
    File = c(
        "BedGraphs/1stKD_Rep1.filtered.sorted.unique.bedGraph",
        "BedGraphs/1stKD_Rep2.filtered.sorted.unique.bedGraph",
        "BedGraphs/2ndKD_Rep1.filtered.sorted.unique.bedGraph",
        "BedGraphs/2ndKD_Rep2.filtered.sorted.unique.bedGraph",
        "BedGraphs/2ndKD_Rep3.filtered.sorted.unique.bedGraph",
        "BedGraphs/Ctrl_Rep1.filtered.sorted.unique.bedGraph",
        "BedGraphs/Ctrl_Rep2.filtered.sorted.unique.bedGraph",
        "BedGraphs/Ctrl_Rep3.filtered.sorted.unique.bedGraph"
    ),
    Condition = rep(c("1stKD", "2ndKD", "Ctrl"), c(2, 3, 3)),
    Replicate = c(1, 2, 1, 2, 3, 1, 2, 3)
)

for (i in 1:peak_metadata[, .N]) {
    print(paste(peak_metadata[i, Condition], peak_metadata[i, Replicate]))
    peaks = fread(
        peak_metadata[i, File],
        header = FALSE,
        sep = "\t",
        col.names = c("chr", "start", "end", "logq")
    )

    for (threshold in c(1, 2, 2.5, 3, 4, 5)) {
        fwrite(
            # filter by threshold
            peaks[logq >= threshold, .SD],
            paste0("Filter/logq_", threshold, "/", peak_metadata[i, Condition], "_Rep", peak_metadata[i, Replicate], ".bedGraph"),
            col.names = FALSE,
            sep = "\t"
        )
    }
}
