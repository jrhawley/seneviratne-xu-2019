PEAKS=$(ls ../../Data/Processed/180913_D00165_0223_BCCGG2ANXX​_Schimmer_Mingjing/output_*/peak/macs2/*/*pval0.01.narrowPeak.gz)
OPTIMAL_PEAKS=$(ls ../../Data/Processed/180913_D00165_0223_BCCGG2ANXX​_Schimmer_Mingjing/output_*/peak/macs2/idr/optimal_set/*IDR0.1.narrowPeak.gz)

OUTPUT="num-peaks.tsv"

echo -e "Condition\tReplicate\tCount" > $OUTPUT

for f in ${PEAKS[@]};
do
    basename $f
    cond=$(echo $f | cut -f 6 -d "/" | cut -f 2 -d "_")
    rep=$(echo $f | cut -f 9 -d "/")
    np=$(zcat $f | wc -l)
    echo -e "${cond}\t${rep}\t${np}" >> $OUTPUT
done

for f in ${OPTIMAL_PEAKS[@]};
do
    basename $f
    cond=$(echo $f | cut -f 6 -d "/" | cut -f 2 -d "_")
    rep=$(echo $f | cut -f 9 -d "/")
    np=$(zcat $f | wc -l)
    echo -e "${cond}\t${rep}\t${np}" >> $OUTPUT
done