# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("gplots"))
suppressMessages(library("reshape2"))

# ==============================================================================
# Data
# ==============================================================================
cases = c("1stKD", "2ndKD", "Ctrl")
jaccard = rbindlist(lapply(
    1:length(cases),
    function(i) {
        rbindlist(lapply(
            1:length(cases),
            function(j) {
                f = paste0(
                    "Jaccards/",
                    cases[i],
                    ".",
                    cases[j],
                    ".jaccard.tsv"
                )
                dt = fread(f, header = TRUE, sep = "\t", select = 3)
                dt[, ConditionX := cases[i]]
                dt[, ConditionY := cases[j]]
                return(dt)
            }
        ))
    }
))

# convert to matrix format
mat = acast(jaccard, ConditionX~ConditionY, value.var="jaccard")

# cellnote labelling. only show upper half
mat_note = round(mat, 2)

# produce hierarchical clustering
clust = hclust(dist(1 - mat))

# ==============================================================================
# Plots
# ==============================================================================
cols = colorRampPalette(c("white", "firebrick2"))
labelcols = c(
    "1stKD" = "#FF7F0E",
    "2ndKD" = "#2CA02C",
    "Ctrl" = "#1F77B4"
)

png("Jaccards/jaccard-condition.png", width = 30, height = 30, units = "cm", res = 300)
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
