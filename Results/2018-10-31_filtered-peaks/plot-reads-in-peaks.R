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
    Condition = rep(rep(c("1stKD", "2ndKD", "Ctrl"), c(2, 3, 3)), 5),
    Replicate = rep(c(1, 2, 1, 2, 3, 1, 2, 3), 5),
    Threshold = rep(c("1", "2", "2.5", "3", "4"), each = 8),
    Count = 0L
)

mapped_reads = fread(
    "mapped-reads.tsv",
    header = TRUE,
    sep = "\t"
)

# combine total read counts with peak_metadata
peak_metadata = merge(peak_metadata, mapped_reads)

# ==============================================================================
# Analysis
# ==============================================================================
# count the number of reads that aligned to peaks for each filtered peak list
for (i in 1:length(peak_metadata$Condition)) {
    cond = peak_metadata[i, Condition]
    repl = peak_metadata[i, Replicate]
    thre = peak_metadata[i, Threshold]
    print(paste(cond, repl, thre))
    dt = fread(
        paste0("Counts/logq_", thre, "/", cond, "_Rep", repl, ".bed"),
        header = FALSE,
        sep = "\t",
        select = c(1:3, 11),
        col.names = c("chr", "start", "end", "count")
    )
    peak_metadata[i, Count := dt[, sum(count)]]
}

peak_metadata[, Fraction := (Count / MappedReads)]
peak_metadata[, Percentage := 100 * Fraction]

# ==============================================================================
# Plots
# ==============================================================================
gg <- (
    ggplot(
        data = peak_metadata,
        mapping = aes(x = Threshold, y = Percentage)
    )
    + geom_point()
    + labs(
        x = "-log10(q) Threshold",
        y = "Percentage of Mapped Reads",
        title = "Mapped Reads vs q-value Threshold"
    )
    + facet_grid(Condition ~ Replicate)
)
ggsave(
    "reads-within-peaks.png",
    height = 12,
    width = 20,
    units = "cm"
)
