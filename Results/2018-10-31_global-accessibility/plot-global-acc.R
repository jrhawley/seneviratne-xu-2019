# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("ggplot2"))

# ==============================================================================
# Functions
# ==============================================================================
meandif <- function(x,y) mean(x) - mean(y)
# function for performing permutations
perm2samp <- function(
        x, # vector from group 1
        y, # vector from group 2
        myfun = meandif, # function of group data
        alternative = c("two.sided", "less", "greater") # x ALT y
    ){
    theta.hat = myfun(x,y)
    m = length(x)
    n = length(y)
    N = m + n
    z = c(x,y)
    # matrix of all possible group assignments
    gmat = expand.grid(replicate(N, 1:2, simplify = FALSE))
    # remove first and last rows (all elements belong to a single group)
    gmat = gmat[c(-1, -(2^N)), ]
    nsamp = nrow(gmat)
    theta.mc = apply(
        gmat,
        1,
        function(g,z){
            meandif(z[g == 1], z[g != 1])
        },
        z = z
    )
    if(alternative[1] == "less") {
        perm = sum(theta.mc <= theta.hat) / nsamp
    } else if(alternative[1] == "greater") {
        perm = sum(theta.mc >= theta.hat) / nsamp
    } else {
        perm = sum(abs(theta.mc) >= abs(theta.hat)) / nsamp
    }
    return(list(
        theta.hat = theta.hat,
        theta.mc = theta.mc,
        p = perm
    ))
}

# ==============================================================================
# Data
# ==============================================================================
peaks = fread("num-peaks-bp.tsv")

# ==============================================================================
# Analysis
# ==============================================================================
# hypothesis test placeholder
test_results = data.table(
    X = rep(c("Ctrl", "1stKD"), c(4, 2)),
    Y = c("1stKD", "2ndKD", "1stKD", "2ndKD", "2ndKD", "2ndKD"),
    Data = c("bp", "bp", "Peaks", "Peaks", "bp", "Peaks"),
    Hypothesis = rep(c("X >= Y", "X = Y"), c(4, 2)),
    Alternative = rep(c("less", "two.sided"), c(4, 2)),
    p = 1,
    FDR = 1
)

# testing for differences in bp accessibility
cat("Permutation tests\n")
for (i in 1:test_results[, .N]) {
    x = test_results[i, X]
    y = test_results[i, Y]
    dtype = test_results[i, Data]
    alt = test_results[i, Alternative]
    cat(x, y, dtype, alt, "\n")
    res = perm2samp(
        peaks[Condition == x, get(dtype)],
        peaks[Condition == y, get(dtype)],
        alternative = alt
    )
    test_results[i, p := res$p]
}
cat("Done\n")

# multiple test correction based on data used
test_results[Data == "bp", FDR := p.adjust(p, "fdr")]
test_results[Data == "Peak", FDR := p.adjust(p, "fdr")]
fwrite(
    test_results,
    "global-tests.tsv",
    col.names = TRUE,
    sep = "\t"
)

# melt for facetted plotting
peaks_melted = melt(
    peaks,
    id.vars = c("Condition", "Replicate"),
    measure.vars = c("Peaks", "bp"),
    variable.name = "dtype",
    value.name = "Count"
)

# ==============================================================================
# Plots
# ==============================================================================
gg <- (
    ggplot(peaks_melted)
    + geom_col(
        aes(
            x = Condition,
            y = Count,
            fill = Condition,
            group = Replicate
        ),
        size = 2,
        position = position_dodge(width = 1.0)
    )
    + labs(title = "Peak and bp counts per sample")
    + facet_wrap(~ dtype, scale = "free_y")
)
ggsave(
    "peaks-bp.png",
    height = 12,
    width = 20,
    units = "cm"
)
