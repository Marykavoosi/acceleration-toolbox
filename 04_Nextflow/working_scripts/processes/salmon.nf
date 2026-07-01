process SALMON_INDEX {
    tag "Salmon Indexing"
    publishDir "${params.outdir}/salmon_index", mode: 'copy'

    container "hcemm/bioinfo-workshop:salmon"

    input:
    path transcriptome

    output:
    path "transcripts_index", emit: index

    script:
    """
    salmon index -t ${transcriptome} -i transcripts_index
    """
}

process SALMON_QUANT {
    tag "Salmon on $sample_id"
    publishDir "${params.outdir}/salmon", mode: 'copy'

    container "hcemm/bioinfo-workshop:salmon"

    input:
    tuple val(sample_id), path(trimmed_reads)
    path index

    output:
    path "${sample_id}_quant", emit: quant_dirs

    script:
    """
    salmon quant -i ${index} -l A \
        -1 ${trimmed_reads[0]} \
        -2 ${trimmed_reads[1]} \
        -p ${task.cpus} \
        --validateMappings \
        -o ${sample_id}_quant
    """
}
