## Nextflow

An example pipeline generation in Nextlow
Pipeline:
- fastqc
- multiqc
- trimming
- salmon
- diff expression
- etc.

We are in groups... 1-4
working collab on the repo: HCEMM/rnaseq-nextflow

We will use Nextflow to stitch those individual tools into a single, automated, reproducible RNA-seq pipeline.

Step 1: Understanding the Pipeline Architecture
Before you write any code, let's look at how our Nextflow repository is structured. You will see two main structural files that act as the "brain" of our pipeline:

- main.nf
- nextflow.config
- /processes
- /data
- /results

1. nextflow.config (The Settings)
This file tells Nextflow how to run the pipeline. It defines parameters (like where to find the input data), execution profiles (whether to run locally, on an HPC, or in the cloud), and most importantly for us, it links our processes to the Docker containers you just built.

```
executor {
    name = 'slurm'
    queueSize = 100            // Max jobs in SLURM queue at once
    submitRateLimit = '10 sec' // Throttle job submission
}

// 2. Process Resource Allocations
process {
    executor = 'slurm'
    // queue = 'standard'         // Change to your HPC's specific partition

    // Default fallback resources
    cpus = 1
    memory = '2 GB'
    time = '1h'

    // Tool-specific resources
    withName: 'FASTQC' {
        cpus = 2
        memory = '4 GB'
    }
    withName: 'TRIMMOMATIC' {
        cpus = 4
        memory = '8 GB'
    }
    withName: 'SALMON_QUANT' {
        cpus = 6
        memory = '12 GB'
    }
    withName: 'R_SUMMARY' {
        cpus = 1
        memory = '4 GB'
    }
}

// 3. Enable Apptainer (Singularity)
apptainer {
    enabled = true
    autoMounts = true
    runOptions = '--bind /scratch'
}
```

2. main.nf (The Conductor)
This is the master script. It does not do any bioinformatics analysis itself. Instead, it defines the channels (the data pathways) and controls the order in which the tools run. It imports your individual modules and connects the outputs of one tool to the inputs of the next.

```
#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// --- PARAMETERS ---
params.reads         = "/scratch/jsequeira/sznistvan/data/rnaseq/bioinformatics_hpc/workshop_ready/*_workshop_{1,2}.fastq.gz"
// --reads /scratch/jsequeira/sznistvan/data/rnaseq/bioinformatics_hpc/workshop_ready/*_workshop_{1,2}.fastq.gz
params.transcriptome = "$projectDir/data/Homo_sapiens.GRCh38.cdna.all.fa"
//params.adapters      = "$projectDir/data/adapters.fa"       // Added: Required for trimming
params.metadata      = "$projectDir/data/samples.csv"       // Added: Required for R (limma)
params.tx2gene       = "$projectDir/data/tx2gene/tx2gene.csv"       // Added: Required for R (tximport)
params.outdir        = "$projectDir/results"

// --- MODULE IMPORTS ---
include { FASTQC }       from './processes/fastqc.nf'
include { TRIMMOMATIC }  from './processes/trimming.nf'
include { SALMON_INDEX } from './processes/salmon.nf'       // Added: Salmon Indexing step
include { SALMON_QUANT } from './processes/salmon.nf'
include { MULTIQC }      from './processes/multiqc.nf'      // Added: MultiQC!
include { R_ANALYSIS }   from './processes/r_analysis.nf'

//ml apptainer!

// --- WORKFLOW ---
workflow {
    // 1. Create channels from input data
    read_pairs_ch    = Channel.fromFilePairs(params.reads, checkIfExists: true).view { "Found sample: ${it[0]}" }   
    transcriptome_ch = file(params.transcriptome, checkIfExists: true)
    tx2gene_ch       = file(params.tx2gene, checkIfExists: true)
    metadata_ch      = file(params.metadata, checkIfExists: true)

    // 2. Quality Control & Trimming
    FASTQC(read_pairs_ch)
    TRIMMOMATIC(read_pairs_ch)

    // 3. Transcriptome Indexing & Quantification
    SALMON_INDEX(transcriptome_ch)
    
    // Pass the trimmed reads and the generated index into Salmon Quant
    SALMON_QUANT(TRIMMOMATIC.out.trimmed_reads, SALMON_INDEX.out.index)
    
    
    // 4. Summarize all Quality Control logs
    // We mix the outputs from FastQC, Trimmomatic, and Salmon into one channel for MultiQC
    MULTIQC(
        FASTQC.out.qc_results.mix(
            TRIMMOMATIC.out.log,
            SALMON_QUANT.out.quant_dirs
        ).collect())

    // 5. Differential Expression in R
    // Pass the quantified directories, plus the necessary biological metadata
    R_ANALYSIS(
        SALMON_QUANT.out.quant_dirs.collect(),
        tx2gene_ch,
        metadata_ch
    )
}
```
