# Summary

This folder contains the preprocessing output performed by Carl and the Bioinformatics Core.
Each subfolder contains ATAC-seq data corresponding to 3 conditions:

* TAZ Knockdown 1 (2 reps)
* TAZ Knockdown 2 (3 reps)
* Control (3 reps)

The two knockdowns were generated via different methods targeting similar mechanisms.

For easy viewing, see `*_report.html` in each subfolder.

This is updated preprocessed data corresponding to the other sequencing folder, `180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/`.
This contains BAMs for all the samples, as well as all the correct peaks, so this should be all the data I need.

They still call narrowPeaks with a p-value threshold of 0.01, so I'm going to filter these for a q-value to likely reduce the noise in the peak lists.

