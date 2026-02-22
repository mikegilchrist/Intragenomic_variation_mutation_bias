#!/bin/bash

# Description: ROC Analysis
# Usage: ./runRoc_parallel.sh 

#species list 
SPECIES_LIST=("saccharomyces_uvarum" "ogataea_methanolica" "ogataea_parapolymorpha" "ogataea_polymorpha")

INFOLDER="fasta/revisit_cds_data"
OUTPUT_BASE="Results/ConstMut"
SUFFIX=".max.cds"

#loop through each species
for SPECIES in "${SPECIES_LIST[@]}"; do 

INPUT="${INFOLDER}/${SPECIES}${SUFFIX}"

#results saved to a unique subfolder using the species name
OUTPUT="${OUTPUT_BASE}/${SPECIES}"
mkdir -p "$OUTPUT"


echo "Running ROC analysis for ${SPECIES}..."
nohup Rscript --vanilla Scripts/rocAnalysis.R -i "$INPUT" -o "$OUTPUT" -d 0 -s 1000 -a 20 -t 5 -n 8 --est_csp --est_phi --est_hyp --max_num_runs 2 --codon_table 1 &> "${OUTPUT}/roc_analysis.log" &
wait
done
