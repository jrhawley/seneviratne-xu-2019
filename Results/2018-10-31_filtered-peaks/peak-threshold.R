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
        "../../Data/Processed/atac_dnase/output_1stKD_TAZ/peak/macs2/rep1/967_1_S31_L007_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_1stKD_TAZ/peak/macs2/rep2/967_2_S35_L008_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/peak/macs2/rep1/1337_1_S37_L008_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/peak/macs2/rep2/1337_2_S32_L007_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/peak/macs2/rep3/1337_3_S36_L008_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_Control/peak/macs2/rep1/GFP_1_S38_L008_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_Control/peak/macs2/rep2/GFP_2_S33_L007_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_Control/peak/macs2/rep3/GFP_3_S34_L007_R1_001.nodup.tn5.pf.narrowPeak.gz"
    ),
    Condition = rep(c("1stKD", "2ndKD", "Ctrl"), c(2, 3, 3)),
    Replicate = c(1, 2, 1, 2, 3, 1, 2, 3)
)

peaks = rbindlist(lapply(
    1:length(peak_metadata$File),
    function(i) {
        dt = fread(
            paste("zcat", peak_metadata[i, File]),
            header = FALSE,
            sep = "\t",
            col.names = c("chr", "start", "end", "logp", "logq"),
            select = c(1:3, 8, 9)
        )
        dt[, Condition := peak_metadata[i, Condition]]
        dt[, Replicate := peak_metadata[i, Replicate]]
        return(dt)
    }
))

# ==============================================================================
# Analysis
# ==============================================================================
# use q-value cutoff to calculate peak counts
peaks[logq >= 1, .N, by = c("Condition", "Replicate")]
peaks[logq >= 2, .N, by = c("Condition", "Replicate")]
peaks[logq >= 2.5, .N, by = c("Condition", "Replicate")]
peaks[logq >= 3, .N, by = c("Condition", "Replicate")]
peaks[logq >= 4, .N, by = c("Condition", "Replicate")]
peaks[logq >= 5, .N, by = c("Condition", "Replicate")]

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
