#!/bin/python

from glob import glob
from os.path import isfile
import pandas as pd
import sys

def build_matrix(results_dir, output_dir):
    # Get list of annotation summary files
    summary_files = glob(f"{results_dir}/*_matches.tab")
    
    # Initialize an empty DataFrame to hold the matrix
    matrix_df = pd.DataFrame()
    
    # Loop through each summary file and populate the matrix
    for file in summary_files:
        sample_name = file.split('/')[-1].replace('_matches.tab', '')
        report = pd.read_csv(file, sep='\t', header=None, usecols=[0, 1], names=['qseqid', 'sseqid'])
        report = report.groupby('sseqid').size().reset_index(name='Count').rename(columns={'Count': sample_name})
        report.set_index('sseqid', inplace=True)
        
        if matrix_df.empty:
            matrix_df = report
        else:
            matrix_df = matrix_df.join(report, how='outer')
    
    # Fill NaN values with 0 and convert counts to integers
    matrix_df.fillna(0, inplace=True)
    matrix_df = matrix_df.astype(int)
    
    # Save the final matrix to a CSV file
    matrix_df = matrix_df.transpose()
    matrix_df.index.name = 'Sample'
    matrix_df.to_csv(f"{output_dir}/matches_summary.csv")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python build_matrix.py <results_dir> <output_dir>")
        sys.exit(1)
        
    build_matrix(sys.argv[1], sys.argv[2])
