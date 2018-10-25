# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("gplots"))
suppressMessages(library("reshape2"))

# ==============================================================================
# Data
# ==============================================================================
files = paste0("Jaccards/", list.files(path = "Jaccards"))
jaccard = rbindlist(lapply(
    files,
    function(f) {
        basef = basename(f)
        indices = gregexpr("[-_\\.]", basef)[[1]]
        dt = fread(f, header = TRUE, sep = "\t")
        dt[, ConditionX := substr(basef, 1, indices[1] - 1)]
        dt[, ReplicateX := substr(basef, indices[1] + 1, indices[2] - 1)]
        dt[, ConditionY := substr(basef, indices[2] + 1, indices[3] - 1)]
        dt[, ReplicateY := substr(basef, indices[3] + 1, indices[4] - 1)]
        return(dt)
    }
))
# combine condition and replicate names
jaccard[, CaseX := paste(ConditionX, ReplicateX)]
jaccard[, CaseY := paste(ConditionY, ReplicateY)]

# convert to matrix format
mat = acast(jaccard, CaseX~CaseY, value.var="jaccard")

# produce hierarchical clustering
clust = hclust(dist(1 - mat))

# ==============================================================================
# Plots
# ==============================================================================
cols = colorRampPalette(c("white", "firebrick2"))
labelcols = c(
    "1stKD rep1" = "#FF7F0E",
    "1stKD rep2" = "#FF7F0E",
    "2ndKD rep1" = "#2CA02C",
    "2ndKD rep2" = "#2CA02C",
    "2ndKD rep3" = "#2CA02C",
    "Control rep1" = "#1F77B4",
    "Control rep2" = "#1F77B4",
    "Control rep3" = "#1F77B4"
)

png("jaccard.png", width = 30, height = 30, units = "cm", res = 300)
heatmap.2(
    mat,
    dendrogram = "row",
    col = cols,
    trace = "none",
    margins = c(10, 10),
    lwid = c(1.5, 4),
    lhei = c(0.8, 4),
    RowSideColors = labelcols
)
dev.off()
