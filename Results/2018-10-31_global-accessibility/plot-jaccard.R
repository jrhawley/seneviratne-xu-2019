# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("gplots"))
suppressMessages(library("reshape2"))

# ==============================================================================
# Data
# ==============================================================================
cases = data.table(
    Condition = rep(c("1stKD", "2ndKD", "Ctrl"), c(2, 3, 3)),
    Replicate = c(1, 2, 1, 2, 3, 1, 2, 3)
)
jaccard = rbindlist(lapply(
    1:cases[, .N],
    function(i) {
        con_i = cases[i, Condition]
        rep_i = cases[i, Replicate]
        rbindlist(lapply(
            1:cases[, .N],
            function(j) {
                con_j = cases[j, Condition]
                rep_j = cases[j, Replicate]
                f = paste0(
                    "Jaccards/",
                    con_i,
                    "_Rep",
                    rep_i,
                    ".",
                    con_j,
                    "_Rep",
                    rep_j,
                    ".jaccard.tsv"
                )
                dt = fread(f, header = TRUE, sep = "\t", select = 3)
                dt[, ConditionX := con_i]
                dt[, ConditionY := con_j]
                dt[, ReplicateX := rep_i]
                dt[, ReplicateY := rep_j]
                return(dt)
            }
        ))
    }
))
# combine condition and replicate names
jaccard[, CaseX := paste0(ConditionX, " Rep", ReplicateX)]
jaccard[, CaseY := paste0(ConditionY, " Rep", ReplicateY)]

# convert to matrix format
mat = acast(jaccard, CaseX~CaseY, value.var="jaccard")

# cellnote labelling. only show upper half
mat_note = round(mat, 2)

# produce hierarchical clustering
clust = hclust(dist(1 - mat))

# ==============================================================================
# Plots
# ==============================================================================
cols = colorRampPalette(c("white", "firebrick2"))
labelcols = c(
    "1stKD Rep1" = "#FF7F0E",
    "1stKD Rep2" = "#FF7F0E",
    "2ndKD Rep1" = "#2CA02C",
    "2ndKD Rep2" = "#2CA02C",
    "2ndKD Rep3" = "#2CA02C",
    "Control Rep1" = "#1F77B4",
    "Control Rep2" = "#1F77B4",
    "Control Rep3" = "#1F77B4"
)

png("Jaccards/jaccard.png", width = 30, height = 30, units = "cm", res = 300)
heatmap.2(
    mat,
    cellnote = mat_note,
    notecol = "black",
    dendrogram = "row",
    col = cols,
    trace = "none",
    margins = c(10, 10),
    lwid = c(1.5, 4),
    lhei = c(0.8, 4),
    RowSideColors = labelcols
)
dev.off()
