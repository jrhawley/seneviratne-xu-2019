# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("ggplot2"))
suppressMessages(library("DESeq2"))
suppressMessages(library("vsn"))

# ==============================================================================
# Data
# ==============================================================================
cases = c(
    "Control_Rep1",
    "Control_Rep2",
    "Control_Rep3",
    # "1stKD_Rep2", # only 1 replicate here, so ignoring
    "2ndKD_Rep1",
    "2ndKD_Rep2",
    "2ndKD_Rep3"
)

# read in loci
consensus = fread(
    "consensus.merged.filtered.bed",
    header = FALSE,
    sep = "\t",
    col.names = c("Chr", "Start", "End")
)
for (case in cases) {
    # read in counts for each case
    dt = fread(
        paste0("Counts/", case, ".sorted.bed"),
        header = FALSE,
        sep = "\t",
        col.names = c("Chr", "Start", "End", case)
    )
    # append columns of counts for each case to the consensus
    consensus = merge(
        consensus,
        dt,
        by = c("Chr", "Start", "End")
    )
}

# just the count matrix
count_mtx = as.matrix(consensus[, -(1:3)])
loci = consensus[, paste0(Chr, ":", Start, "-", End)]
rownames(count_mtx) = loci

# column data information with rownames in the same order as the counts' colnames
annotation = data.frame(
    Condition = factor(
        rep(c("Control", "2ndKD"), c(3, 3)),
        levels = c("Control", "2ndKD")
    ),
    Replicate = c(1, 2, 3, 1, 2, 3),
    row.names = cases
)

# create DESeqDataSet object
dds = DESeqDataSetFromMatrix(
    countData = count_mtx,
    colData = annotation,
    design = ~ Replicate + Condition
)

# ==============================================================================
# Analysis
# ==============================================================================
# pre-filter out peaks that contain < 10 reads across all samples
low_counts = which(rowSums(count_mtx) < 10)
loci = loci[-low_counts]
consensus_loci = consensus[-low_counts, .SD, .SDcols = c("Chr", "Start", "End")]
dds = dds[-low_counts, ]

# perform differential calculations
dds = DESeq(dds)

# save results with genomic coordinates
res2 = results(dds, contrast = c("Condition", "2ndKD", "Control"))
res2_dt = as.data.table(cbind(
    consensus_loci,
    as.data.frame(res2)
))

fwrite(
    res2_dt,
    "2ndKD-vs-Ctrl.results.tsv",
    sep = "\t",
    col.names = TRUE
)

res2_up = res2_dt[padj < 0.05 & log2FoldChange > log2(1.5), ]
res2_dn = res2_dt[padj < 0.05 & log2FoldChange < -log2(1.5), ]

# ==============================================================================
# Plots
# ==============================================================================
# estimates dispersion matrix
png("dispersion.png", width = 12, height = 12, units = "cm", res = 300)
plotDispEsts(dds)
dev.off()

# RLD Plot
png("RLD.png", width = 12, height = 12, units = "cm", res = 300)
rld = rlog(dds, blind = FALSE)
vsn::meanSdPlot(assay(rld))
dev.off()

# read count density plot
counts_melt <- melt(

)
gg <- (
    ggplot(data = data)
    + plottype(aes(x = x))
    + labs(x = "X Label", y = "Y Label", title = "Title")
)

# histogram of p-values
gg <- (
    ggplot(data = res2_dt)
    + geom_histogram(aes(x = pvalue))
    + labs(
        title = "2ndKD vs Control Differential Accessibility",
        subtitle = "Histogram of p-values",
        x = "p-value",
        y = "Frequency"
    )
)
ggsave(
    "2ndKD-vs-Ctrl.pvalues.png",
    height = 12,
    width = 20,
    units = "cm"
)

png("2ndKD-vs-Ctrl.MA.png", width = 12, height = 12, units = "cm", res = 300)
plotMA(res2, ylim = c(-5, 5))
dev.off()

# volcano plot
gg <- (
    ggplot(data = res2_dt)
    + geom_point(aes(x = log2FoldChange, y = -log10(padj)), alpha = 0.1)
    + geom_hline(aes(yintercept = -log10(0.05)))
    + geom_vline(aes(xintercept = -log2(1.5)))
    + geom_vline(aes(xintercept = log2(1.5)))
    + labs(
        x = "log2(FoldChange)",
        y = "-log10(adjusted p-value)",
        title = "1stKD vs Control Differential Accessibility",
        subtitle = "Volcano plot of peaks"
    )
)
ggsave(
    "2ndKD-vs-Ctrl.volcano.png",
    height = 12,
    width = 20,
    units = "cm"
)
