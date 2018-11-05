"""
preprocess-peaks
==========

1. Remove chrX, Y, M, and non-canonical chromosomes
2. Sort the peaks
3. Remove summits, only keeping unique peaks and retaining the largest -log10(q)
among a set of identical peaks
"""

from __future__ import division, absolute_import, print_function
import os.path
import pandas as pd
import gzip
import pybedtools as pbt

# ==============================================================================
# Constants
# ==============================================================================
peak_metadata = pd.DataFrame({
    "Condition": [
        "1stKD",
        "1stKD",
        "2ndKD",
        "2ndKD",
        "2ndKD",
        "Ctrl",
        "Ctrl",
        "Ctrl"
    ],
    "Replicate": [1, 2, 1, 2, 3, 1, 2, 3],
    "narrowPeak": [
        "../../Data/Processed/atac_dnase/output_1stKD_TAZ/peak/macs2/rep1/967_1_S31_L007_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_1stKD_TAZ/peak/macs2/rep2/967_2_S35_L008_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/peak/macs2/rep1/1337_1_S37_L008_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/peak/macs2/rep2/1337_2_S32_L007_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/peak/macs2/rep3/1337_3_S36_L008_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_Control/peak/macs2/rep1/GFP_1_S38_L008_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_Control/peak/macs2/rep2/GFP_2_S33_L007_R1_001.nodup.tn5.pf.narrowPeak.gz",
        "../../Data/Processed/atac_dnase/output_Control/peak/macs2/rep3/GFP_3_S34_L007_R1_001.nodup.tn5.pf.narrowPeak.gz"
    ]
})
peak_metadata["Filtered"] = [
    os.path.join("BedGraphs", c + "_Rep" + str(r) + ".filtered.bedGraph")
    for (c, r) in zip(peak_metadata["Condition"], peak_metadata["Replicate"])
]
peak_metadata["Sorted"] = [
    os.path.join("BedGraphs", c + "_Rep" + str(r) +
                 ".filtered.sorted.bedGraph")
    for (c, r) in zip(peak_metadata["Condition"], peak_metadata["Replicate"])
]
peak_metadata["Unique"] = [
    os.path.join("BedGraphs", c + "_Rep" + str(r) +
                 ".filtered.sorted.unique.bedGraph")
    for (c, r) in zip(peak_metadata["Condition"], peak_metadata["Replicate"])
]

# ==============================================================================
# Functions
# ==============================================================================


def filter_chr(narrowPeak, outfile):
    """
    Filter X, Y, M, and non-canonical chromosomes from a narrowPeak file

    Parameters
    ----------
    narrowPeak : str
        Path to narrowPeak file
    outfile : str
        Path to output file
    """
    chrs = ["chr" + str(c) for c in range(1, 23)]
    f_in = gzip.open(narrowPeak, "rt")
    f_out = open(outfile, "w")
    for line in f_in:
        splitline = line.rstrip().split("\t")
        chrom = splitline[0]
        start = splitline[1]
        end = splitline[2]
        logq = splitline[8]
        if chrom in chrs:
            f_out.write("\t".join([chrom, start, end, logq]) + "\n")
    f_in.close()
    f_out.close()


def remove_dups(bg, outfile):
    """
    Remove duplicate peaks due to --call-summits, and keep the largest -log10(q)

    Parameters
    ----------
    bg : str
        Path to input peak bedGraph file
    outfile : str
        Path to output file
    """
    f_in = open(bg, "r")
    f_out = open(outfile, "w")
    # read first line
    prev = f_in.readline().rstrip().split("\t")
    for line in f_in:
        splitline = line.rstrip().split("\t")
        # check if chr, start, and end are the same as the previous line
        # (can do this because input is sorted)
        if splitline[0:3] == prev[0:3]:
            if splitline[3] > prev[3]:
                # replace -log10(q) if this peak has a larger value
                prev[3] = splitline[3]
        else:
            # print prev to outfile if this is a new locus
            f_out.write("\t".join(prev) + "\n")
            # replace prev for next comparison
            prev = splitline
    f_in.close()
    f_out.close()


# ==============================================================================
# Main
# ==============================================================================
print("Filtering chromosomes")
for i in range(len(peak_metadata)):
    print("\t", peak_metadata["Condition"].iloc[i],
          peak_metadata["Replicate"].iloc[i])
    filter_chr(
        peak_metadata["narrowPeak"].iloc[i],
        peak_metadata["Filtered"].iloc[i]
    )

print("Sorting BedGraphs")
for i in range(len(peak_metadata)):
    print("\t", peak_metadata["Condition"].iloc[i],
          peak_metadata["Replicate"].iloc[i])
    bed = pbt.BedTool(peak_metadata["Filtered"].iloc[i])
    bed_sorted = bed.sort()
    bed_sorted.saveas(peak_metadata["Sorted"].iloc[i])

print("De-duplicating summits and peaks")
for i in range(len(peak_metadata)):
    print("\t", peak_metadata["Condition"].iloc[i],
          peak_metadata["Replicate"].iloc[i])
    remove_dups(
        peak_metadata["Sorted"].iloc[i],
        peak_metadata["Unique"].iloc[i]
    )
print("Done")
