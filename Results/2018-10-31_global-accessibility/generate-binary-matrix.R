# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("GenomicRanges"))

# ==============================================================================
# Functions
# ==============================================================================
#' Convert narrowPeak files to GRanges
#'
#' @param filename
#' @return GRanges
bed2gr <- function(filename, zipped = FALSE) {
    if (zipped) {
        filename = paste("zcat", filename)
    }
    dt = fread(
        filename,
        header = FALSE,
        sep = "\t",
        select = 1:3,
        col.names = c("chr", "start", "end")
    )
    return(GRanges(dt[, paste0(chr, ":", start, "-", end)]))
}

# ==============================================================================
# Data
# ==============================================================================
peak_metadata = data.table(
    Condition = c("1stKD", "2ndKD", "Ctrl")
)
peak_metadata[, File := paste0("Consensus/", Condition, ".bed")]

consensus = "Consensus/consensus.bed"

# want to keep both the data.table and the GRanges object
query = bed2gr(consensus)
queryDF = data.frame(query)
# remove unnecessary width and strand columns
queryDF$width <- NULL
queryDF$strand <- NULL

# ==============================================================================
# Analysis
# ==============================================================================
for (i in 1:peak_metadata[, .N]){
  print(i)
  subject = bed2gr(peak_metadata[i, File])
  cat("Finding overlaps\n")
  hits = findOverlaps(query, subject)
  cat("  Done\n")
  hitsDF = data.frame(hits)
  queryDF[hitsDF$queryHits, peak_metadata[i, Condition]] = 1
  queryDF[-hitsDF$queryHits, peak_metadata[i, Condition]] = 0
}

fwrite(
    queryDF,
    "Consensus/consensus-matrix.tsv",
    col.names = TRUE,
    sep = "\t"
)
