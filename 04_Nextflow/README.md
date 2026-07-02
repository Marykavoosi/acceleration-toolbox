## Nextflow

In previous sessions, we containerized individual bioinformatics tools. Here, we will integrate those tools into an automated, reproducible Nextflow workflow.

**The Objective**: Build a collaborative RNA-seq pipeline consisting of FastQC, Trimmomatic, Salmon, MultiQC, and R (Limma).

**The Workspace**: [```HCEMM/rnaseq-nextflow```](https://github.com/HCEMM/rnaseq-nextflow) repository (Groups 1-4).

### Part 1: Pipeline Architecture
A standard Nextflow repository relies on two central files to control execution and configuration, isolating the "how" from the "where."


Directory Overview:
- ```main.nf``` (The master script)
- ```nextflow.config``` (The settings)
- ```/processes``` (Where your individual group modules live)
- ```/data``` (Input datasets and references)
- ```/results``` (Where the final outputs will be saved)

-----------------------

### 1. ```nextflow.config``` (Infrastructure and Resources)

This file dictates execution rules: job scheduling, CPU/RAM allocation, and container integration.

<details><summary>Show me the nextflow.config file!</summary>
    
```
// 1. Executor Settings (HPC Job Scheduler)
executor {
    name = 'slurm'
    queueSize = 100            // Max jobs in SLURM queue at once
    submitRateLimit = '10 sec' // Throttle job submission to not overwhelm the scheduler
}

// 2. Process Resource Allocations
process {
    executor = 'slurm'
    // queue = 'standard'      // Uncomment and change to your HPC's specific partition if needed

    // Default fallback resources
    cpus = 1
    memory = '2 GB'
    time = '1h'

    // Tool-specific resource limits
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
    runOptions = '--bind /scratch' // Ensure the HPC scratch space is visible inside the container
}
```

</details>

----------

### 2. ```main.nf``` (The Master Workflow)

This script orchestrates data flow using *Nextflow Channels*. It imports modules and wires tool outputs to downstream inputs.

<details><summary>Show me the main.nf file!</summary>
    
```
#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// --- PARAMETERS ---
// These can be overridden in the command line using e.g., --reads "/path/to/reads"
params.reads         = "/scratch/jsequeira/sznistvan/data/rnaseq/bioinformatics_hpc/workshop_ready/*_workshop_{1,2}.fastq.gz"
params.transcriptome = "$projectDir/data/Homo_sapiens.GRCh38.cdna.all.fa"
params.metadata      = "$projectDir/data/samples.csv"       // Required for R (limma/DESeq2)
params.tx2gene       = "$projectDir/data/tx2gene/tx2gene.csv" // Required for R (tximport)
params.outdir        = "$projectDir/results"

// --- MODULE IMPORTS ---
// Bringing in the modules your groups are building inside the /processes folder
include { FASTQC }       from './processes/fastqc.nf'
include { TRIMMOMATIC }  from './processes/trimming.nf'
include { SALMON_INDEX } from './processes/salmon.nf'
include { SALMON_QUANT } from './processes/salmon.nf'
include { MULTIQC }      from './processes/multiqc.nf'
include { R_ANALYSIS }   from './processes/r_analysis.nf'


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
        ).collect()
    )

    // 5. Differential Expression in R
    // Pass the quantified directories, plus the necessary biological metadata
    R_ANALYSIS(
        SALMON_QUANT.out.quant_dirs.collect(),
        tx2gene_ch,
        metadata_ch
    )
}
```

</details>

----------------

### Part 2: Writing Nextflow Processes | Nextflow Directives & Data Types

**Exapmple DAG architecture**

<img width="691" height="686" alt="flowchart" src="https://github.com/user-attachments/assets/78237e23-4b0c-42f4-bab8-e6e8cd9f037a" />


A Nextflow process wraps your Bash or R scripts into reusable modules. To write effective modules, you must understand Nextflow directives and data types.

**1. Directives and Task Variables**

Directives control the environment and behavior of your specific process.

**A. Global Implicit Variables**
|Variable|Function|Example|
|---------|--------|-------|
|```publishDir```|Saves specific output files to your final results folder. (Otherwise, files remain hidden in temporary directories).|```publishDir "${params.outdir}/fastqc", mode: 'copy'```|
|```launchDir```|This points to the directory where the user actually typed ```nextflow run ...``` in their terminal.| ```[user@server: ~/my/folder] nextflow run main.nf```|
|```workDir```| Points to the path of the temporary scratch directory (usually ```work/```)| e.g. ```$projectDir/work/3f/55560c68752026892c4267c4a42105/```|
|```params```| The global parameter dictionary. Any variable prefixed with ```params.``` can be dynamically overridden by the user from the command line using ```--reads```| e.g ```params.reads```|

**B. Essential Directives**
|Directive|Function|Example|
|---------|--------|-------|
|```task.cpus``` and ```task.memory```|These are dynamic global variables. Instead of hardcoding threads 4 in your Bash script, use ${task.cpus}.| e.g. ```fastqc -t ${task.cpus} reads.fastq.gz```|
|```tag```|Customizes terminal logs to show exactly which sample is currently processing.| ```[3f/55560c] FASTQC (FastQC on SRR1039520)```|
|```container```|Specifies the exact image to pull for this step if not globally defined.|```container 'biocontainers/fastqc:v0.11.9_cv8'```|
|```errorStrategy```|Defines pipeline behavior upon task failure (```terminate```, ```ignore```, ```retry```).|```errorStrategy 'retry'```|

<img width="545" height="212" alt="image" src="https://github.com/user-attachments/assets/ebdadd10-a0df-42e0-a157-f3619badf04e" />

-----------------------

**2. Input and Output Types**
Nextflow needs to know exactly what kind of data is flowing into and out of your process so it can stage the files correctly in the temporary work directories.
|Type|Description|Examples Use Case|
|----|-----------|-----------------|
|```val```|A simple value or string. It is not a file.|Passing a sample ID: ```val(sample_id)```|
|```path```|A physical file or directory path. Nextflow will symlink this into the task's execution folder.|Passing a FASTQ file: ```path(fastq_file)```|
|```tuple```|A logical grouping of multiple elements that must travel together through an input channel. |Pairing an ID with its files: ```tuple val(sample_id), path(reads)```|
```env```|Captures an environment variable set in the script block.|```env(MY_VAR)```|
```stdout```|Captures standard output printed to the terminal.| *stdout*|

----------------------

### Part 3: Group Assignment
> *Your task is to convert hollow ```.nf``` templates into functional modules using your optimized container commands.*

**The Assignments**
- Group 1: Quality Control | Complete ```fastqc.nf```
- Group 2: Read Trimming | Complete ```trimming.nf```
- Group 3: Quantification | Complete ```salmon.nf``` (*only quantification*)
- Group 4: Differential Expression | Complete ```r_analysis.nf``` (using the R limma package)

> All of these processes rely on the containers built and pushed to [DockerHub](https://hub.docker.com/repository/docker/hcemm/bioinfo-workshop) in the previous part.

**Submission Protocol**
Once the processes are updated, please:
- Commit to your group branch: ```git commit -m "some message + group name"```
- Push to [```HCEMM/rnaseq-nextflow```](https://github.com/HCEMM/rnaseq-nextflow) repository
- Check Github Actions (CICD) syntax and Nextflow tests (```nf-test```)
- When all checks are passed, open a Pull Request (PR) to ```developer``` branch!

image

> Once all groups have created a PR, a whole pipeline test will be performed! ✅

---------
### Group and branch names
|Group|Tool|Branch|DockerHub Tag|
|------|--------|-------|----------|
| Group1 | FastQC + MultiQC |fastqc-g1| hcemm/bioinfo-workshop:fastqc|
| Group2| trimmomatic |trimming-g2| hcemm/bioinfo-workshop:trimming|
| Group3 | salmon |salmon-g3| hcemm/bioinfo-workshop:salmon|
| Group4 | R + limma |limma-g4| hcemm/bioinfo-workshop:limma|

### Part 4: Execution & Debugging
Once all PRs are merged into the main branch and tested with Github Actions, we execute our pipeline.

```
nextflow run main.nf -resume
```
> *Note on ```-resume```: If the pipeline crashes, fix the typo and run this exact command again. Nextflow uses cached hashes to skip completed steps and instantly restart at the point of failure.*


### Inspecting the Outputs
Nextflow generates two critical directories. Knowing the difference is key to debugging. (```work``` and ```results```)

1. The ```work/``` Directory (The Engine Room)
- Nextflow executes every single process in a heavily isolated, hidden directory inside the work/ folder.
- If you look at your terminal output during execution, you will see alphanumeric hashes next to each process (e.g., [7b/3a1c9f]).
- You can navigate to work/7b/3a1c9f... to see exactly what happened in that specific job. Inside, you will find hidden files like .command.sh (the exact bash script that ran), .command.out (the standard output), and .command.err (the error messages). This is your primary debugging zone!

2. The ```results/``` Directory (The Display Case)
Because the work/ directory is chaotic, heavily nested, and temporary, we use Nextflow's publishDir directive in our code to copy the final, important files here.

Let's open our results/ folder and inspect our final outputs:
- The MultiQC HTML report to see our sequence quality before and after trimming.
- The Salmon quantification tables mapping our reads to transcripts.
- The R/limma plots (e.g., Volcano plots, PCA) showing the differentially expressed genes in our dataset.

----------------

**Congratulations! You have successfully built, containerized, and automated a collaborative bioinformatics workflow!**
