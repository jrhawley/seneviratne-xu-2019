PEAKS=$(ls ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_*/peak/macs2/*/*pval0.01.narrowPeak.gz)

zcat ${PEAKS[@]} | sort -k1,1 -k2,2n > consensus.bed
bedtools merge -i consensus.bed > consensus.merged.bed

# filter out non-canonical chromosomes, as well as X and Y
grep -e "^chr[1-9]" consensus.merged.bed > consensus.merged.filtered.bed

rm consensus.bed
rm consensus.merged.bed