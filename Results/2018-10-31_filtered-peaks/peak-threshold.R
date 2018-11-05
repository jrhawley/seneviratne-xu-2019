# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("ggplot2"))

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

peaks = rbindlist(lapply(
    1:peak_metadata[, .N],
    function(i) {
        dt = fread(
            peak_metadata[i, File],
            header = FALSE,
            sep = "\t",
            col.names = c("chr", "start", "end", "logq"),
        )
        dt[, Condition := peak_metadata[i, Condition]]
        dt[, Replicate := peak_metadata[i, Replicate]]
        return(dt)
    }
))

# ==============================================================================
# Analysis
# ==============================================================================
# use q-value cutoff to calculate peak counts and save data
fwrite(
    peaks[logq >= 1, .N, by = c("Condition", "Replicate")],
    "Filter/logq_1/peak-counts.tsv",
    col.names = TRUE,
    sep = "\t"
)
fwrite(
    peaks[logq >= 2, .N, by = c("Condition", "Replicate")],
    "Filter/logq_2/peak-counts.tsv",
    col.names = TRUE,
    sep = "\t"
)
fwrite(
    peaks[logq >= 2.5, .N, by = c("Condition", "Replicate")],
    "Filter/logq_2.5/peak-counts.tsv",
    col.names = TRUE,
    sep = "\t"
)
fwrite(
    peaks[logq >= 3, .N, by = c("Condition", "Replicate")],
    "Filter/logq_3/peak-counts.tsv",
    col.names = TRUE,
    sep = "\t"
)
fwrite(
    peaks[logq >= 4, .N, by = c("Condition", "Replicate")],
    "Filter/logq_4/peak-counts.tsv",
    col.names = TRUE,
    sep = "\t"
)
fwrite(
    peaks[logq >= 5, .N, by = c("Condition", "Replicate")],
    "Filter/logq_5/peak-counts.tsv",
    col.names = TRUE,
    sep = "\t"
)

# ==============================================================================
# Plots
# ==============================================================================
# plot CDF of peak counts vs thresholds
gg <- (
    ggplot(data = peaks)
    + stat_ecdf(
        aes(x = -logq),
        geom = "step"
    )
    + labs(
        x = "log10(q)",
        y = "log10(Peak Count)",
        title = "q-value Threshold vs Peak Counts"
    )
    + lims(
        x = c(-15, 0)
    )
    + geom_vline(
        aes(xintercept = -2.5),
        colour = "royalblue",
        linetype = "dashed"
    )
    + facet_grid(Condition ~ Replicate)
)
ggsave(
    "q-threshold_vs_peak-counts.png",
    height = 12,
    width = 20,
    units = "cm"
)
