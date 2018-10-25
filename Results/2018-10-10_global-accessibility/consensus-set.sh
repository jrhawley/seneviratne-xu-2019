ALL_PEAKS=$(ls ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_*/peak/macs2/rep*/*pval0.01.narrowPeak.gz)
CTL_PEAKS=$(ls ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_Control/peak/macs2/rep*/*pval0.01.narrowPeak.gz)
KD1_PEAKS=$(ls ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_1stKD_TAZ/peak/macs2/rep*/*pval0.01.narrowPeak.gz)
KD2_PEAKS=$(ls ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_2ndKD_TAZ/peak/macs2/rep*/*pval0.01.narrowPeak.gz)

echo "Sorting"
zcat ${ALL_PEAKS[@]} | sort -k1,1 -k2,2n > all.sorted.bed
zcat ${CTL_PEAKS[@]} | sort -k1,1 -k2,2n > ctl.sorted.bed
zcat ${KD1_PEAKS[@]} | sort -k1,1 -k2,2n > kd1.sorted.bed
zcat ${KD2_PEAKS[@]} | sort -k1,1 -k2,2n > kd2.sorted.bed

echo "Merging"
bedtools merge -i all.sorted.bed > all.sorted.merged.bed
bedtools merge -i ctl.sorted.bed > ctl.sorted.merged.bed
bedtools merge -i kd1.sorted.bed > kd1.sorted.merged.bed
bedtools merge -i kd2.sorted.bed > kd2.sorted.merged.bed