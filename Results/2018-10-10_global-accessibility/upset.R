# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("UpSetR"))


# ==============================================================================
# Functions
# ==============================================================================

# ==============================================================================
# Data
# ==============================================================================
consensus = fread(
    "consensus-binary-matrix.tsv",
    header = TRUE,
    sep = "\t"
)

# ==============================================================================
# Plots
# ==============================================================================
png("upset.png", width = 20, height = 12, units = "cm", res = 300)
upset(
    consensus,
    nsets = 3,
    queries = list(
        list(
            query = intersects,
            params = list("Control"),
            active = T
        ),
        list(
            query = intersects,
            params = list("Knockdown 1"),
            active = T
        ),
        list(
            query = intersects,
            params = list("Knockdown 2"),
            active = T
        )
    )
)
dev.off()