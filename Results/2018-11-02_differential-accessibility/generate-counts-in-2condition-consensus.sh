#$ -t 1-11
#$ -q lupiengroup
#$ -V
#$ -cwd
#$ -N ReadsInConsensus

# BAM files to get read counts from
BAMS=( \
    "../../Data/Processed/atac_dnase/output_1stKD_TAZ/align/rep1/967_1_S31_L007_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_1stKD_TAZ/align/rep2/967_2_S35_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/align/rep1/1337_1_S37_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/align/rep2/1337_2_S32_L007_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/align/rep3/1337_3_S36_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_Control/align/rep1/GFP_1_S38_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_Control/align/rep2/GFP_2_S33_L007_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_Control/align/rep3/GFP_3_S34_L007_R1_001.nodup.bam" \
    # need to run Ctrls twice sine they're being compared against 2 different consensus lists
    "../../Data/Processed/atac_dnase/output_Control/align/rep1/GFP_1_S38_L008_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_Control/align/rep2/GFP_2_S33_L007_R1_001.nodup.bam" \
    "../../Data/Processed/atac_dnase/output_Control/align/rep3/GFP_3_S34_L007_R1_001.nodup.bam" \
)
# consensus set to select loci from
CONSENSUS=( \
    "../2018-10-31_global-accessibility/Consensus/consensus.1stKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.1stKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.2ndKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.2ndKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.2ndKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.1stKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.1stKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.1stKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.2ndKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.2ndKD-Ctrl.bed" \
    "../2018-10-31_global-accessibility/Consensus/consensus.2ndKD-Ctrl.bed" \
)
COMPARISON=( \
    "1stKD-Ctrl" \
    "1stKD-Ctrl" \
    "2ndKD-Ctrl" \
    "2ndKD-Ctrl" \
    "2ndKD-Ctrl" \
    "1stKD-Ctrl" \
    "1stKD-Ctrl" \
    "1stKD-Ctrl" \
    "2ndKD-Ctrl" \
    "2ndKD-Ctrl" \
    "2ndKD-Ctrl" \
)
CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3 1 2 3)

i=$(($SGE_TASK_ID - 1))

# ensure bedtools v 2.23.0
bedtools --version

cond=${CONDITIONS[$i]}
rep=${REPS[$i]}
bam=${BAMS[$i]}
consensus=${CONSENSUS[$i]}
comp=${COMPARISON[$i]}

echo "$cond Rep$rep : $comp"

# calculate read depth in each peak of the consensus peak list
echo "Calculating depths"
echo "bedtools coverage -abam $bam -b $consensus -counts > Counts/${comp}/${cond}_Rep${rep}.bed"
bedtools coverage -abam $bam -b $consensus -counts > Counts/${comp}/${cond}_Rep${rep}.bed
echo "Sorting"
echo "sort -k1,1 -k2,2n Counts/${comp}/${cond}_Rep${rep}.bed > Counts/${comp}/${cond}_Rep${rep}.sorted.bed"
sort -k1,1 -k2,2n Counts/${comp}/${cond}_Rep${rep}.bed > Counts/${comp}/${cond}_Rep${rep}.sorted.bed
echo "Done"
