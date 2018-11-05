CONDITIONS=("1stKD" "2ndKD" "Ctrl")

# calculate Jaccard indices between samples
echo "Calculating Jaccard indices"
for i in `seq 0 2`;
do
    con_i=${CONDITIONS[$i]}
    bed_i="Consensus/${con_i}.bed"
    echo "  ${con_i}"
    for j in `seq 0 2`;
    do
        con_j=${CONDITIONS[$j]}
        bed_j="Consensus/${con_j}.bed"
        echo "    ${con_j}"
        out="Jaccards/${con_i}.${con_j}.jaccard.tsv"
        bedtools jaccard -a ${bed_i} -b ${bed_j} > $out
    done
done
echo "Done"
