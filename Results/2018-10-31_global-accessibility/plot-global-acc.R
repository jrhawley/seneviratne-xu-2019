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
# testing for differences in bp accessibility
bp_ctrl_kd1 <- perm2samp(
    peaks[Condition == "Ctrl", bp],
    peaks[Condition == "1stKD", bp],
    alternative = "less"
)
bp_ctrl_kd2 <- perm2samp(
    peaks[Condition == "Ctrl", bp],
    peaks[Condition == "2ndKD", bp],
    alternative = "less"
)
bp_kd1_kd2 <- perm2samp(
    peaks[Condition == "1stKD", bp],
    peaks[Condition == "2ndKD", bp]
)

# testing for differences in number of peaks
peak_ctrl_kd1 <- perm2samp(
    peaks[Condition == "Ctrl", Peaks],
    peaks[Condition == "1stKD", Peaks],
    alternative = "less"
)
peak_ctrl_kd2 <- perm2samp(
    peaks[Condition == "Ctrl", Peaks],
    peaks[Condition == "2ndKD", Peaks],
    alternative = "less"
)
peak_kd1_kd2 <- perm2samp(
    peaks[Condition == "1stKD", Peaks],
    peaks[Condition == "2ndKD", Peaks]
)


# ==============================================================================
# Plots
# ==============================================================================
gg <- (
    ggplot(peaks)
    + geom_point(aes(x = Condition, y = bp, colour = Condition), size = 2)
    + ggtitle("Number of bp in peaks per sample")
)
ggsave(
    "bp.png",
    height = 12,
    width = 20,
    units = "cm"
)

gg <- (
    ggplot(peaks)
    + geom_point(aes(x = Condition, y = Peaks, colour = Condition), size = 2)
    + ggtitle("Number of peaks per sample")
)
ggsave(
    "peaks.png",
    height = 12,
    width = 20,
    units = "cm"
)