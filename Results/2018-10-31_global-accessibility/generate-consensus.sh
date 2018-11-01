CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3)

# get corresponding peak files
peaks_all=$(for i in {0..7}; do echo "../2018-10-31_filtered-peaks/Filter/logq_2.5/${CONDITIONS[$i]}_Rep${REPS[$i]}.filtered.narrowPeak"; done)
peaks_1stKD=$(for i in {0..1}; do echo "../2018-10-31_filtered-peaks/Filter/logq_2.5/${CONDITIONS[$i]}_Rep${REPS[$i]}.filtered.narrowPeak"; done)
peaks_2ndKD=$(for i in {2..4}; do echo "../2018-10-31_filtered-peaks/Filter/logq_2.5/${CONDITIONS[$i]}_Rep${REPS[$i]}.filtered.narrowPeak"; done)
peaks_Ctrl=$(for i in {5..7}; do echo "../2018-10-31_filtered-peaks/Filter/logq_2.5/${CONDITIONS[$i]}_Rep${REPS[$i]}.filtered.narrowPeak"; done)

# print first 3 columns (i.e. genomic coordinates) then sort the entire BED file
echo "Sorting peaks"
echo "  Consensus"
awk -v FS="\t" -v OFS="\t" '{print $1, $2, $3}' ${peaks_all} | sort -k1,1 -k2,2n > Consensus/consensus.bed
echo "  1stKD"
awk -v FS="\t" -v OFS="\t" '{print $1, $2, $3}' ${peaks_1stKD} | sort -k1,1 -k2,2n > Consensus/1stKD.bed
echo "  2ndKD"
awk -v FS="\t" -v OFS="\t" '{print $1, $2, $3}' ${peaks_2ndKD} | sort -k1,1 -k2,2n > Consensus/2ndKD.bed
echo "  Ctrl"
awk -v FS="\t" -v OFS="\t" '{print $1, $2, $3}' ${peaks_Ctrl} | sort -k1,1 -k2,2n > Consensus/Ctrl.bed

# merge peaks together
echo "Merging consensus peaks"
bedtools merge -i Consensus/consensus.bed > Consensus/consensus.merged.bed
bedtools merge -i Consensus/1stKD.bed > Consensus/1stKD.merged.bed
bedtools merge -i Consensus/2ndKD.bed > Consensus/2ndKD.merged.bed
bedtools merge -i Consensus/Ctrl.bed > Consensus/Ctrl.merged.bed
