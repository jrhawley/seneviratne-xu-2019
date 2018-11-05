CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3)

# get corresponding peak files
peaks_all=( \
    "../2018-10-31_filtered-peaks/Filter/logq_2.5/1stKD_Rep1.bedGraph" \
    "../2018-10-31_filtered-peaks/Filter/logq_2.5/1stKD_Rep2.bedGraph" \
    "../2018-10-31_filtered-peaks/Filter/logq_2.5/2ndKD_Rep1.bedGraph" \
    "../2018-10-31_filtered-peaks/Filter/logq_2.5/2ndKD_Rep2.bedGraph" \
    "../2018-10-31_filtered-peaks/Filter/logq_2.5/2ndKD_Rep3.bedGraph" \
    "../2018-10-31_filtered-peaks/Filter/logq_2.5/Ctrl_Rep1.bedGraph" \
    "../2018-10-31_filtered-peaks/Filter/logq_2.5/Ctrl_Rep2.bedGraph" \
    "../2018-10-31_filtered-peaks/Filter/logq_2.5/Ctrl_Rep3.bedGraph" \
)
# slice array corresponding to each condition
peaks_1stKD=(${peaks_all[@]:0:2})
peaks_2ndKD=(${peaks_all[@]:2:3})
peaks_Ctrl=(${peaks_all[@]:5:3})

# intersect peaks in each condition to get a common set for a given condition
echo "Calculating condition intersections"
echo "  1stKD"
bedtools intersect -a ${peaks_1stKD[0]} -b ${peaks_1stKD[1]} -sorted > Consensus/1stKD.bedGraph
echo "  2ndKD"
bedtools intersect -a ${peaks_2ndKD[0]} -b ${peaks_2ndKD[1]} -sorted > Consensus/2ndKD.bedGraph.temp
bedtools intersect -a Consensus/2ndKD.bedGraph.temp -b ${peaks_2ndKD[2]} -sorted > Consensus/2ndKD.bedGraph
rm Consensus/2ndKD.bedGraph.temp
echo "  Ctrl"
bedtools intersect -a ${peaks_Ctrl[0]} -b ${peaks_Ctrl[1]} -sorted > Consensus/Ctrl.bedGraph.temp
bedtools intersect -a Consensus/Ctrl.bedGraph.temp -b ${peaks_Ctrl[2]} -sorted > Consensus/Ctrl.bedGraph
rm Consensus/Ctrl.bedGraph.temp

# Remove -log10(q) column (i.e. only keep genomic coordinates)
echo "Removing -log10(q) values"
for i in {"1stKD","2ndKD","Ctrl"};
do
    echo "  $i"
    awk -v FS="\t" -v OFS="\t" '{print $1, $2, $3}' Consensus/${i}.bedGraph > Consensus/${i}.bed
done

# generate consensus from the intersections
echo "Generating consensus"
cat Consensus/*.bed | sort -k1,1 -k 2,2n | bedtools merge -i stdin > Consensus/consensus.bed
