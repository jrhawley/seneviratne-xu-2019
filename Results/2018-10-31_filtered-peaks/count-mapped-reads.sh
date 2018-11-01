BAMS=$(ls ../../Data/Processed/atac_dnase/output_*/align/rep*/*.nodup.bam)

for bam in ${BAMS[@]};
do
    echo $bam
    samtools view -F 0x04 -c $bam
done
