# Summary

This folder contains the preprocessing output performed by Carl and the Bioinformatics Core.
Each subfolder contains ATAC-seq data corresponding to 3 conditions:

* TAZ Knockdown 1 (2 reps)
* TAZ Knockdown 2 (3 reps)
* Control (3 reps)

The two knockdowns were generated via different methods targeting similar mechanisms.

For easy viewing, see `*_report.html` in each subfolder.

The NarrowPeaks being used for downstream analyses are the optimal set of peaks found with an irreproducible discovery rate (IDR) < 0.1.
These are located in `{condition}/peak/macs2/idr/optimal_set/`.

For whatever reason, these narrowPeaks were called with p < 0.01, and has a lot of peaks in each sample.
Additionally, it's missing the 1stKD rep1 BAMs, and no one knows where they went.
So I've asked them to rerun the preprocessing pipeline for this data, which is placed in `Data/Processed/atac_dnase/`.

I'm not longer using this data, and will be using the data from the other folder.

