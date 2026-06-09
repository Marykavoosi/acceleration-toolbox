#!/bin/bash
set -euo pipefail

INPUT_DIR=$1
OUTPUT_DIR=$2
MULTIQC_CONFIG=$3

echo "Generating MultiQC report"

mkdir -p "$OUTPUT_DIR"/multiqc_report

multiqc "$INPUT_DIR" -c "$MULTIQC_CONFIG" -o "$OUTPUT_DIR"/multiqc_report

# check if multiqc_report directory was generated, and exit code 1 if not
if [ ! -d "$OUTPUT_DIR/multiqc_report" ]; then
    echo "Error: MultiQC report was not generated at $OUTPUT_DIR/multiqc_report."
    exit 1
fi

echo "Report assets copied"
