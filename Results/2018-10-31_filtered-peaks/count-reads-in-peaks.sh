#$ -t 1-8
#$ -q lupiengroup
#$ -V
#$ -cwd
#$ -N ReadsInPeaks

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
THRESHOLDS=(1 2 2.5 3 4 5)

i=$(($SGE_TASK_ID - 1))

# ensure bedtools v 2.23.0
bedtools --version

con=${CONDITIONS[$i]}
rep=${REPS[$i]}
bam=${BAMS[$i]}
echo "$con Rep$rep"
for t in ${THRESHOLDS[@]};
do
    peak="Filter/logq_${t}/${con}_Rep${rep}.bedGraph"
    counts="Counts/logq_${t}/${con}_Rep${rep}.bedGraph"
    sorted_counts="Counts/logq_${t}/${con}_Rep${rep}.sorted.bedGraph"
    echo $t
    # echo "bedtools coverage -abam $bam -b $peak -counts > Counts/logq_${t}/${con}_Rep${rep}.bed"
    echo "  Calculating depths"
    bedtools coverage -abam $bam -b $peak -counts > $counts
    
    echo "  Sorting"
    # remove the -log10(q) from the original peak bedGraph, only keep the depth
    awk -v FS="\t" -v OFS="\t" '{print $1, $2, $3, $5}' $counts | sort -k1,1 -k2,2n > ${sorted_counts}
done
