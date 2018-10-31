BAMS=( \
    ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_Control/align/rep1/GFP_1_S38_L008_R1_001.nodup.bam \
    ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_Control/align/rep2/GFP_2_S33_L007_R1_001.nodup.bam \
    ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_Control/align/rep3/GFP_3_S34_L007_R1_001.nodup.bam \
    ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_1stKD_TAZ/align/rep2/967_2_S35_L008_R1_001.nodup.bam \
    ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_2ndKD_TAZ/align/rep1/1337_1_S37_L008_R1_001.nodup.bam \
    ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_2ndKD_TAZ/align/rep2/1337_2_S32_L007_R1_001.nodup.bam \
    ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_2ndKD_TAZ/align/rep3/1337_3_S36_L008_R1_001.nodup.bam \
)

NAMES=( \
    "Control_Rep1" \
    "Control_Rep2" \
    "Control_Rep3" \
    "1stKD_Rep2" \
    "2ndKD_Rep1" \
    "2ndKD_Rep2" \
    "2ndKD_Rep3" \
)

# ensure bedtools v2.23.0
bedtools --version
for((i=0;i<7;i++));
do
    echo "${NAMES[$i]} (${BAMS[$i]})"
    echo "  Coverage"
    bedtools coverage -abam ${BAMS[$i]} -b consensus.merged.filtered.bed -counts > Counts/${NAMES[$i]}.bed
    echo "  Sorting"
    sort -k1,1 -k2,2n Counts/${NAMES[$i]}.bed > Counts/${NAMES[$i]}.sorted.bed
done
