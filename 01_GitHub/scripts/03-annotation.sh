#!/bin/bash
set -euo pipefail

READS_DIR=$1
RESULTS_DIR=$2
DB=$3
THREADS=$4
MAX_TARGET_SEQS=1
N_FILES=12

mkdir -p "$RESULTS_DIR"

echo "Running annotation against database of glucocorticoid-responsive genes"

for FILE in "$READS_DIR"/*.fastq.gz; 
do 
    
    echo "Annotating file: $FILE"

    # GROUP 3 - WRITE HERE THE COMMAND TO RUN DIAMOND BLASTX
    # READS ARE GZIPPED AT $READS_DIR
    # OUTPUT SHOULD GO TO $RESULTS_DIR, WITH FILENAME FORMAT: sample_matches.tab
    # USE $DB AS THE DIAMOND DATABASE, $THREADS FOR THREADS, AND $MAX_TARGET_SEQS FOR MAX TARGET SEQS
    # OUTFMT SHOULD BE 6 (TABULAR)
    # tips below
    diamond blastx -d "$DB" -q "$FILE" -o "$RESULTS_DIR"/$(basename "$FILE" .fastq.gz)_matches.tab --threads "$THREADS" --max-target-seqs "$MAX_TARGET_SEQS" --outfmt 6
    
done

# check if 12 annotation results were generated, and exit code 1 if not
if [ $(ls "$RESULTS_DIR"/*_matches.tab | wc -l) -ne $N_FILES ]; then
    echo "Error: Not all annotation results were generated. Expected $N_FILES, but found $(ls "$RESULTS_DIR"/*_matches.tab | wc -l)."
    exit 1
fi

# tip: $(basename "$FILE" .fastq.gz) extracts the sample name from the filename by removing the directory path and the .fastq.gz extension

echo "Annotation complete"