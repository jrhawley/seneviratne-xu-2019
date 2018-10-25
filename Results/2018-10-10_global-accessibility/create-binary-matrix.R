# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("ggplot2"))
suppressMessages(library("GenomicRanges"))

# ==============================================================================
# Functions
# ==============================================================================
#' Conver narrowPeak files to GRanges
#'
#' @param filename
#' @return GRanges
np2granges <- function(filename, zipped = FALSE) {
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
files = c(
    "ctl.sorted.merged.bed",
    "kd1.sorted.merged.bed",
    "kd2.sorted.merged.bed"
)

sample_names = c("Knockdown 1", "Knockdown 2", "Control")
merged_file = "all.sorted.merged.bed"

# want to keep both the data.table and the GRanges object
query = np2granges(merged_file)
queryDF = data.frame(query)
queryDF$width <- NULL
queryDF$strand <- NULL

# ==============================================================================
# Analysis
# ==============================================================================
for (i in 1:length(files)){
  print(i)
  subject = np2granges(files[i])
  hits = findOverlaps(query, subject)
  print("overlap finding done")
  hitsDF <- data.frame(hits)
  queryDF[hitsDF$queryHits, sample_names[i]] <- 1
  queryDF[-hitsDF$queryHits, sample_names[i]] <- 0
}

fwrite(
    queryDF,
    "consensus-binary-matrix.tsv",
    col.names = TRUE,
    sep = "\t"
)
