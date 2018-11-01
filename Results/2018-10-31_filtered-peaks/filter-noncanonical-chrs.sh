CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3)
THRESHOLDS=(1 2 2.5 3 4)

for i in `seq 0 7`;
do
    con=${CONDITIONS[$i]}
    rep=${REPS[$i]}
    bam=${BAMS[$i]}
    echo "$con Rep$rep"
    for t in ${THRESHOLDS[@]};
    do
        peak="Filter/logq_${t}/${con}_Rep${rep}.narrowPeak"
        out="Filter/logq_${t}/${con}_Rep${rep}.filtered.narrowPeak"
        echo $t
        echo "  $peak"
        # remove X, Y, M, and non-canonical chromosomes
        grep "^chr[1-9]" $peak > $out
    done
done
