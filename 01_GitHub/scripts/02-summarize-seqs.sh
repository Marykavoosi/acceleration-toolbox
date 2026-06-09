#!/bin/bash
set -euo pipefail

READS_DIR=$1
OUTPUT_FILENAME=$2
THREADS=$3
N_FILES=12

echo "Summarizing sequence statistics with SeqKit"

mkdir -p "$(dirname "$OUTPUT_FILENAME")"
echo -e "Sample\tFormat\tType\tNum_Seqs\tTotal_Length\tMin_Length\tAvg_Length\tMax_Length" > "$OUTPUT_FILENAME"

for FILE in "$READS_DIR"/*.fastq.gz
do    
    echo "Processing file: $FILE"

    SAMPLE=$(basename "$FILE" .fastq.gz)

    # GROUP 2 - WRITE HERE THE COMMAND TO RUN SEQKIT STATS AND APPEND TO OUTPUT FILE
    # READS ARE GZIPPED AT $READS_DIR
    # FOR EACH FILE, RUN seqkit stats, AND APPEND THE OUTPUT TO $OUTPUT_FILENAME
    # tips below
    
    seqkit stats -T "$FILE" --threads "$THREADS" \
    | tail -n +2 \
    | awk -v sample="$SAMPLE" -v OFS='\t' '{print sample, $2, $3, $4, $5, $6, $7, $8}' >> "$OUTPUT_FILENAME"
done

# Check if the summary file was generated and contains 12 lines of data (excluding header), and exit code 1 if not
if [ $(wc -l < "$OUTPUT_FILENAME") -ne $((N_FILES + 1)) ]; then
    echo "Error: The summary file does not contain the expected number of lines. Expected $((N_FILES + 1)), but found $(wc -l < "$OUTPUT_FILENAME")."
    exit 1
fi

# tip: tail -n +2 removes the header line
# tip 2: awk -v sample="$SAMPLE" -v OFS='\t' '{print sample, $2, $3, $4, $5, $6, $7, $8}' formats the output to include the sample name and tab-delimited fields

echo "SeqKit summary complete"