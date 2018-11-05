CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3)

# calculate Jaccard indices between samples
echo "Calculating Jaccard indices"
for i in `seq 0 7`;
do
    con_i=${CONDITIONS[$i]}
    rep_i=${REPS[$i]}
    bed_i="../2018-10-31_filtered-peaks/Filter/logq_2.5/${con_i}_Rep${rep_i}.bedGraph"
    echo "  ${con_i} Rep${rep_i}"
    for j in `seq 0 7`;
    do
        con_j=${CONDITIONS[$j]}
        rep_j=${REPS[$j]}
        bed_j="../2018-10-31_filtered-peaks/Filter/logq_2.5/${con_j}_Rep${rep_j}.bedGraph"
        echo "    ${con_j} Rep${rep_j}"
        out="Jaccards/${con_i}_Rep${rep_i}.${con_j}_Rep${rep_j}.jaccard.tsv"
        bedtools jaccard -a ${bed_i} -b ${bed_j} > $out
    done
done
echo "Done"
