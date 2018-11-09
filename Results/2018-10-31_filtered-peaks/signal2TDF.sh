#$ -t 1-8
#$ -q lupiengroup
#$ -V
#$ -cwd
#$ -N toTDF

module load igvtools
module load ucsctools/315

SIGNALS=( \
    "../../Data/Processed/atac_dnase/output_1stKD_TAZ/signal/macs2/rep1/967_1_S31_L007_R1_001.nodup.tn5.pf.pval.signal.bigwig" \
    "../../Data/Processed/atac_dnase/output_1stKD_TAZ/signal/macs2/rep2/967_2_S35_L008_R1_001.nodup.tn5.pf.pval.signal.bigwig" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/signal/macs2/rep1/1337_1_S37_L008_R1_001.nodup.tn5.pf.pval.signal.bigwig" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/signal/macs2/rep2/1337_2_S32_L007_R1_001.nodup.tn5.pf.pval.signal.bigwig" \
    "../../Data/Processed/atac_dnase/output_2ndKD_TAZ/signal/macs2/rep3/1337_3_S36_L008_R1_001.nodup.tn5.pf.pval.signal.bigwig" \
    "../../Data/Processed/atac_dnase/output_Control/signal/macs2/rep1/GFP_1_S38_L008_R1_001.nodup.tn5.pf.pval.signal.bigwig" \
    "../../Data/Processed/atac_dnase/output_Control/signal/macs2/rep2/GFP_2_S33_L007_R1_001.nodup.tn5.pf.pval.signal.bigwig" \
    "../../Data/Processed/atac_dnase/output_Control/signal/macs2/rep3/GFP_3_S34_L007_R1_001.nodup.tn5.pf.pval.signal.bigwig" \
)
CONDITIONS=("1stKD" "1stKD" "2ndKD" "2ndKD" "2ndKD" "Ctrl" "Ctrl" "Ctrl")
REPS=(1 2 1 2 3 1 2 3)

i=$(($SGE_TASK_ID - 1))

bigwig=${SIGNALS[$i]}
con=${CONDITIONS[$i]}
rep=${REPS[$i]}
wig="Signal/${con}_Rep${rep}.wig"
output="Signal/${con}_Rep${rep}.tdf"

echo "${con} Rep${rep}"
# need to convert to Wiggle before converting to TDF
echo "  Converting to Wiggle"
bigWigToWig $bigwig $wig
echo "  Converting to TDF"
igvtools toTDF $wig $output "hg38"
