ALL_PEAKS=$(ls ../../Data/Processed/180913_D00165_0223_BCCGG2ANX_Schimmer_Mingjing/output_*/peak/macs2/rep*/*pval0.01.narrowPeak.gz)

for i in ${ALL_PEAKS[@]};
do
    cond=$(echo $i | cut -f 6 -d "/" | cut -f 2 -d "_")
    rep=$(echo $i | cut -f 9 -d "/")
    outname="${cond}-${rep}.narrowPeak"
    echo $outname
    # sort BED files
    zcat $i | awk -v FS="\t" -v OFS="\t" '{print $1, $2, $3}' | sort -k1,1 -k2,2n > "Sorted/${outname}.sorted.bed"

    # filter out inconsistent chromosomes (i.e. ones not in 1-22, X, Y)
    grep "^chr[1-9,X,Y]" "Sorted/${outname}.sorted.bed" > "Sorted/${outname}.sorted.filtered.bed"
done
