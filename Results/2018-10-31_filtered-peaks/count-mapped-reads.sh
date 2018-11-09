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

# list of chromosomes that are removed from further analyses
NC_CHROMS=($(awk '{if (NR >= 23) print $1}' hg38-chrom-sizes.bed))

OUTPUT="Counts/mapped-reads.tsv"

echo -e "Condition\tReplicate\tMappedReads\tNonCanonicalChromMappedReads" > $OUTPUT

echo "Counting mapped reads"
for i in `seq 0 7`;
do
    con=${CONDITIONS[$i]}
    rep=${REPS[$i]}
    bam=${BAMS[$i]}
    echo "  $con $rep"
    # total number of mapped reads
    echo -e "    Total number of mapped reads"
    count=$(samtools view -F 0x04 -c $bam)
    echo -e "      ${count}"
    # total number of mapped reads to removed chromosomes
    echo -e "    Total number of mapped reads to removed chromosomes"
    nc_count=0
    for chr in ${NC_CHROMS[@]};
    do
        echo $chr
        nc_count=$((${nc_count} + $(samtools view -F 0x04 -c $bam $chr)))
        echo "  ${nc_count}"
    done
    echo -e "      ${nc_count}"
    echo -e "${con}\t${rep}\t${count}\t${nc_count}" >> $OUTPUT
done
