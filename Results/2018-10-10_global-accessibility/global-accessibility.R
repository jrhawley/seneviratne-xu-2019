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
bp <- fread("num-bp.tsv")
peaks <- fread("num-peaks.tsv")

bp_reps <- bp[Replicate != "idr" & Replicate != "pooled_rep"]
peak_reps <- peaks[Replicate != "idr" & Replicate != "pooled_rep"]

# ==============================================================================
# Analysis
# ==============================================================================
# testing for differences in bp accessibility
bp_ctrl_kd1 <- perm2samp(
    bp_reps[Condition == "Control", BP],
    bp_reps[Condition == "1stKD", BP],
    alternative = "less"
)
bp_ctrl_kd2 <- perm2samp(
    bp_reps[Condition == "Control", BP],
    bp_reps[Condition == "2ndKD", BP],
    alternative = "less"
)
bp_kd1_kd2 <- perm2samp(
    bp_reps[Condition == "1stKD", BP],
    bp_reps[Condition == "2ndKD", BP]
)

# testing for differences in number of peaks
peak_ctrl_kd1 <- perm2samp(
    peak_reps[Condition == "Control", Count],
    peak_reps[Condition == "1stKD", Count],
    alternative = "less"
)
peak_ctrl_kd2 <- perm2samp(
    peak_reps[Condition == "Control", Count],
    peak_reps[Condition == "2ndKD", Count],
    alternative = "less"
)
peak_kd1_kd2 <- perm2samp(
    peak_reps[Condition == "1stKD", Count],
    peak_reps[Condition == "2ndKD", Count]
)


# ==============================================================================
# Plots
# ==============================================================================
gg <- (
    ggplot(bp[Replicate != "idr" & Replicate != "pooled_rep"])
    + geom_point(aes(x = Condition, y = BP, colour = Condition), size = 2)
    + ggtitle("Number of bp in peaks per sample")
)
ggsave(
    "bp.png",
    height = 12,
    width = 20,
    units = "cm"
)

gg <- (
    ggplot(peaks[Replicate != "idr" & Replicate != "pooled_rep"])
    + geom_point(aes(x = Condition, y = Count, colour = Condition), size = 2)
    + ggtitle("Number of peaks per sample")
)
ggsave(
    "peaks.png",
    height = 12,
    width = 20,
    units = "cm"
)