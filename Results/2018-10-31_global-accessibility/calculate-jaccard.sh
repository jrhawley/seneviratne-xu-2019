CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3)

# sort narrowPeaks
echo "Sorting peaks"
for i in `seq 0 7`;
do
    con=${CONDITIONS[$i]}
    rep=${REPS[$i]}
    echo "  $con Rep$rep"
    peak="../2018-10-31_filtered-peaks/Filter/logq_2.5/${con}_Rep${rep}.filtered.narrowPeak"
    out="Sorted/${con}_Rep${rep}.filtered.sorted.bed"
    awk -v FS="\t" -v OFS="\t" '{print $1, $2, $3}' $peak | sort -k1,1 -k2,2n > $out
done
echo "Done"

# calculate Jaccard indices between samples
echo "Calculating Jaccard indices"
for i in `seq 0 7`;
do
    con_i=${CONDITIONS[$i]}
    rep_i=${REPS[$i]}
    bed_i="Sorted/${con_i}_Rep${rep_i}.filtered.sorted.bed"
    echo "  ${con_i} Rep${rep_i}"
    for j in `seq 0 7`;
    do
        con_j=${CONDITIONS[$j]}
        rep_j=${REPS[$j]}
        bed_j="Sorted/${con_j}_Rep${rep_j}.filtered.sorted.bed"
        echo "    ${con_j} Rep${rep_j}"
        out="Jaccards/${con_i}-Rep${rep_i}_${con_j}-Rep${rep_j}.jaccard.tsv"
        bedtools jaccard -a ${bed_i} -b ${bed_j} > $out
    done
done
echo "Done"