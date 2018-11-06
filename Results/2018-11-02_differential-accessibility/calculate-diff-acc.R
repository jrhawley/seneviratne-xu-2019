# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("ggplot2"))
suppressMessages(library("DESeq2"))

# ==============================================================================
# Data
# ==============================================================================
case_metadata = data.frame(
    Condition = factor(
        rep(c("1stKD", "2ndKD", "Ctrl"), c(2, 3, 3)),
        levels = c("Ctrl", "1stKD", "2ndKD")
    ),
    Replicate = factor(c(1, 2, 1, 2, 3, 1, 2, 3))
)
# DEseq requires a data.frame of this structure with matching rownames
# column data information with rownames in the same order as the counts' colnames
rownames(case_metadata) = paste0(
    case_metadata$Condition,
    "_Rep",
    case_metadata$Replicate
)

# read in loci
consensus = fread(
    "../2018-10-31_global-accessibility/Consensus/consensus.bed",
    header = FALSE,
    sep = "\t",
    col.names = c("Chr", "Start", "End")
)

cat("Loading counts\n")
for (i in 1:length(case_metadata$Replicate)) {
    # read in counts for each case
    case = rownames(case_metadata)[i]
    cat("  ", case, "\n")
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
cat("Done\n")

# just the count matrix
count_mtx = as.matrix(consensus[, -(1:3)])
loci = consensus[, paste0(Chr, ":", Start, "-", End)]
rownames(count_mtx) = loci

# create DESeqDataSet object
dds = DESeqDataSetFromMatrix(
    countData = count_mtx,
    colData = case_metadata,
    design = ~ Replicate + Condition
)

# ==============================================================================
# Analysis
# ==============================================================================
# filter out peaks that are below the 1st percentile for read
# counts across all samples to reduce the presence of noisy reads and likely
# PCR duplicates, respectively (this removes ~ 2% of peaks)
peak_counts = rowSums(count_mtx)
count_filters = quantile(peak_counts, c(0.01, 0.99))
remove_counts = which(peak_counts < count_filters[1])
loci = loci[-remove_counts]
consensus_loci = consensus[-remove_counts, .SD, .SDcols = c("Chr", "Start", "End")]
dds_filtered = dds[-remove_counts, ]


# perform differential calculations
dds_filtered = DESeq(dds_filtered)

# save results with genomic coordinates
res1 = results(dds_filtered, contrast = c("Condition", "1stKD", "Ctrl"))
res1_dt = as.data.table(cbind(
    consensus_loci,
    as.data.frame(res1)
))
res2 = results(dds_filtered, contrast = c("Condition", "2ndKD", "Ctrl"))
res2_dt = as.data.table(cbind(
    consensus_loci,
    as.data.frame(res2)
))

fwrite(
    res1_dt,
    "DEseq/1stKD-vs-Ctrl.results.tsv",
    sep = "\t",
    col.names = TRUE
)
fwrite(
    res2_dt,
    "DEseq/2ndKD-vs-Ctrl.results.tsv",
    sep = "\t",
    col.names = TRUE
)


# ==============================================================================
# QC Plots
# ==============================================================================
# Read count distributions
# =====================================
# reshape count matrix for plotting read count distributions across samples
n_loci = consensus[, .N]
read_counts_melted = as.data.table(melt(
    count_mtx,
    measure.vars = 1:8
))
# assign column names since rownames(count_mtx) gets added as its own column
colnames(read_counts_melted) = c("Locus", "Case", "Count")
# add Condition and Replicate columns for plot facetting
melted_conditions = rep(
    c("1stKD", "2ndKD", "Ctrl"),
    n_loci * c(2, 3, 3)
)
melted_replicates = rep(
    c(1, 2, 1, 2, 3, 1, 2, 3),
    each = n_loci
)
read_counts_melted[, Condition := melted_conditions]
read_counts_melted[, Replicate := melted_replicates]

gg <- (
    ggplot(data = read_counts_melted)
    + geom_histogram(aes(x = Count, fill = Condition))
    + labs(x = "Read Count", y = "Density", title = "Sample Read Count Density")
    + facet_grid(Condition ~ Replicate)
    + guides(fill = FALSE)
)
ggsave(
    "DEseq/read-count-distribution.png",
    height = 20,
    width = 20,
    units = "cm"
)

# Dispersion plot
# =====================================
png("DEseq/dispersion.png", width = 12, height = 12, units = "cm", res = 300)
plotDispEsts(dds_filtered)
dev.off()

# Independent filtering plot
# =====================================
png("DEseq/independent-filtering.png", width = 24, height = 12, units = "cm", res = 300)
par(mfrow=c(1,2))
plot(
    metadata(res1)$filterNumRej,
    type="b",
    xlab="quantiles of filter",
    ylab="number of rejections",
    main = "1stKD vs Ctrl"
)
lines(metadata(res1)$lo.fit, col="red")
abline(v=metadata(res1)$filterTheta)
plot(
    metadata(res2)$filterNumRej,
    type="b",
    xlab="quantiles of filter",
    ylab="number of rejections",
    main = "2ndKD vs Ctrl"
)
lines(metadata(res2)$lo.fit, col="red")
abline(v=metadata(res2)$filterTheta)
dev.off()

resNoFilt <- results(dds_filtered, independentFiltering=FALSE)
addmargins(table(filtering=(res$padj < .1),
                 noFiltering=(resNoFilt$padj < .1)))
# 

# RLD plot
# =====================================
png("RLD.png", width = 12, height = 12, units = "cm", res = 300)
rld = rlog(dds_filtered, blind = FALSE)
vsn::meanSdPlot(assay(rld))
dev.off()


# Histogram of p-values
# =====================================
gg <- (
    ggplot(data = res1_dt)
    + geom_histogram(aes(x = pvalue))
    + labs(
        title = "1stKD vs Control Differential Accessibility",
        subtitle = "Histogram of p-values",
        x = "p-value",
        y = "Frequency"
    )
)
ggsave(
    "DEseq/1stKD-vs-Ctrl.pvalues.png",
    height = 12,
    width = 20,
    units = "cm"
)

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
    "DEseq/2ndKD-vs-Ctrl.pvalues.png",
    height = 12,
    width = 20,
    units = "cm"
)

png("DEseq/1stKD-vs-Ctrl.MA.png", width = 12, height = 12, units = "cm", res = 300)
plotMA(res1, ylim = c(-5, 5))
dev.off()

png("DEseq/2ndKD-vs-Ctrl.MA.png", width = 12, height = 12, units = "cm", res = 300)
plotMA(res2, ylim = c(-5, 5))
dev.off()

# Volcano plot
# =====================================
gg <- (
    ggplot(data = res1_dt)
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
    "DEseq/1stKD-vs-Ctrl.volcano.png",
    height = 12,
    width = 20,
    units = "cm"
)

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
    "DEseq/2ndKD-vs-Ctrl.volcano.png",
    height = 12,
    width = 20,
    units = "cm"
)
