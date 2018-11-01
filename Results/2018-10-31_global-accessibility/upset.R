# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("UpSetR"))

# ==============================================================================
# Data
# ==============================================================================
consensus = fread(
    "Consensus/consensus-binary-matrix.tsv",
    header = TRUE,
    sep = "\t"
)

# ==============================================================================
# Plots
# ==============================================================================
png("upset.png", width = 20, height = 12, units = "cm", res = 300)
upset(
    consensus,
    nsets = 8,
    queries = list(
        list(
            query = intersects,
            params = list("Ctrl"),
            active = T
        ),
        list(
            query = intersects,
            params = list("1stKD"),
            active = T
        ),
        list(
            query = intersects,
            params = list("2ndKD"),
            active = T
        ),
        list(
            query = intersects,
            params = list("1stKD", "2ndKD"),
            active = T
        ),
        list(
            query = intersects,
            params = list("1stKD", "2ndKD", "Ctrl"),
            active = T
        )
    )
)
dev.off()
