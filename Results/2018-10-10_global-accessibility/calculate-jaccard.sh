ALL_PEAKS=$(ls Sorted/*.filtered.bed)

for i in ${ALL_PEAKS[@]};
do
    iname=$(basename $i | cut -f 1 -d ".")
    echo $iname
    for j in ${ALL_PEAKS[@]};
    do
        jname=$(basename $j | cut -f 1 -d ".")
        echo "  $jname"
        bedtools jaccard -a $i -b $j > Jaccards/${iname}_${jname}.jaccard.tsv
    done
done
