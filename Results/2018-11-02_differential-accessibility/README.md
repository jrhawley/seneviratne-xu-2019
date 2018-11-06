# Summary

This folder re-runs the differential accessibility analyses done in `2018-10-25_differential-accessibility/` with the re-preprocessed data.
The dataset now contains the BAM for 1stKD Rep1, so now I have 8 samples across 3 conditions to compare instead of 6 samples across 2 conditions.

## Steps

### Calculating read depths

I've calculated the read depths for each sample in the consensus peak list by running `qsub generate-counts-in-consensus.sh`.

### DEseq

All the steps for calculating differential accessibility via read count differences between conditions can be found in `calculate-diff-acc.R`.

## Results

### QC plots with full consensus list

The dispersion plot does look much better in this attempt than the previous one.

![Dispersion plot](DEseq/dispersion.png)

There are many fewer coefficients that are far from the fitted values, and it looks much more like the dispersion plot from the example data shown in the DEseq2 vignette.
There is somewhat of a levelling of the fitted values, unlike the previous attempts.
The fit is approximately exponential (linear in log-space), and while there is some levelling near the high normalized counts, it's not nearly flat.

Other QC plots can be seen below, indicating that this seems like a reasonable fit, but not without its issues.
