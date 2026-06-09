#!/bin/bash
set -euo pipefail

RESULTS_DIR=$1
OUTPUT_DIR=$2
N_FILES=12

echo "Counting matches into summary matrix"

mkdir -p "$OUTPUT_DIR"

python 01_GitHub/scripts/build_matrix.py "$RESULTS_DIR" "$OUTPUT_DIR"

# check if the matrix file was created successfully
if [ ! -f "$OUTPUT_DIR/matches_summary.csv" ]; then
    echo "Error: matches_summary.csv was not created in $OUTPUT_DIR."
    exit 1
fi

echo "Matches matrix built"
