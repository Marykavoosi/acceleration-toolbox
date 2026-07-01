process R_ANALYSIS {
    tag "R Analysis"
    publishDir "${params.outdir}/R_plots", mode: 'copy'

    container "hcemm/bioinfo-workshop:limma"

    input:
    path quant_dirs
    path tx2gene
    path metadata

    output:
    path "expression_summary.pdf"
    path "final_results.csv"

    script:
    """
    Rscript ${projectDir}/scripts/limma_analysis.R --quant_dirs ${quant_dirs.join(',')} --tx2gene ${tx2gene} --metadata ${metadata}
    """
}
