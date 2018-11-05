CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3)

OUTPUT="num-peaks-bp.tsv"

echo -e "Condition\tReplicate\tPeaks\tbp" > $OUTPUT

for i in `seq 0 7`;
do
    cond=${CONDITIONS[$i]}
    rep=${REPS[$i]}
    peak="../2018-10-31_filtered-peaks/Filter/logq_2.5/${cond}_Rep${rep}.bedGraph"
    echo "$cond Rep$rep"

    npeak=$(cat $peak | wc -l)
    nbp=$(cat $peak | awk 'BEGIN{x=0}{x+=($3 - $2)}END{print x}')
    echo -e "${cond}\t${rep}\t${npeak}\t${nbp}" >> $OUTPUT
done
