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

for (i in 1:length(peak_metadata$File)) {
    print(paste(peak_metadata[i, Condition], peak_metadata[i, Replicate]))
    peaks = fread(
        paste("zcat", peak_metadata[i, File]),
        header = FALSE,
        sep = "\t",
        col.names = c("chr", "start", "end", "name", "score", "strand", "signalValue", "logp", "logq", "peak"),
    )

    for (threshold in c(1, 2, 2.5, 3, 4)) {
        fwrite(
            # filter by threshold
            peaks[logq >= threshold, .SD],
            paste0("Filter/logq_", threshold, "/", peak_metadata[i, Condition], "_Rep", peak_metadata[i, Replicate], ".narrowPeak"),
            col.names = FALSE,
            sep = "\t"
        )
    }
}
