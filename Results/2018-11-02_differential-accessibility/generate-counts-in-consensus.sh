#$ -t 1-8
#$ -q lupiengroup
#$ -V
#$ -cwd
#$ -N ReadsInConsensus

BAMS=( \
    "../../Data/Processed/atac_dnase/output_1stKD_TAZ/align/rep1/967_1_S31_L007_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_1stKD_TAZ/align/rep2/967_2_S35_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/align/rep1/1337_1_S37_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/align/rep2/1337_2_S32_L007_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/align/rep3/1337_3_S36_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_Control/align/rep1/GFP_1_S38_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_Control/align/rep2/GFP_2_S33_L007_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_Control/align/rep3/GFP_3_S34_L007_R1_001.nodup.bam" \
)
CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3)

i=$(($SGE_TASK_ID - 1))

# ensure bedtools v 2.23.0
bedtools --version

con=${CONDITIONS[$i]}
rep=${REPS[$i]}
bam=${BAMS[$i]}
echo "$con Rep$rep"
consensus="../2018-10-31_global-accessibility/Consensus/consensus.bed"

# calculate read depth in each peak of the consensus peak list
echo "Calculating depths"
echo "bedtools coverage -abam $bam -b $consensus -counts > Counts/${con}_Rep${rep}.bed"
bedtools coverage -abam $bam -b $consensus -counts > Counts/${con}_Rep${rep}.bed
echo "Sorting"
echo "sort -k1,1 -k2,2n Counts/${con}_Rep${rep}.bed > Counts/${con}_Rep${rep}.sorted.bed"
sort -k1,1 -k2,2n Counts/${con}_Rep${rep}.bed > Counts/${con}_Rep${rep}.sorted.bed
echo "Done"
