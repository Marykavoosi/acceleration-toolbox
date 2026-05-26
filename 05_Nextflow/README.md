## Nextflow

So far, you have built and containerized individual bioinformatics tools. Now, we will use Nextflow to stitch those isolated tools into a single, automated, and reproducible RNA-seq pipeline.

Our Complete Pipeline: 
- FastQC: Quality control of raw reads
- Trimmomatic: Adapter and quality trimming
- Salmon: Transcriptome indexing and read quantification
- MultiQC: Aggregating all logs and QC metrics into one report
- R (Limma): Differential expression analysis

The Workspace:
You are working in groups (1-4) collaboratively on the repository: [```HCEMM/rnaseq-nextflow```](https://github.com/HCEMM/rnaseq-nextflow).

### Step 1: Understanding the Pipeline Architecture
Before you write any code, let's look at how our Nextflow repository is structured. You will see two main structural files that act as the "brain" of our pipeline, alongside directories for our code and data.

Directory Overview:
- ```main.nf``` (The master script)
- ```nextflow.config``` (The settings)
- ```/processes``` (Where your individual group modules live)
- ```/data``` (Input datasets and references)
- ```/results``` (Where the final outputs will be saved)

-----------------------

```nextflow.config```

This file tells Nextflow how to execute the pipeline on your specific infrastructure. It defines job scheduling (SLURM), allocates resources (CPUs and RAM) to specific processes, and crucially, tells Nextflow to use Apptainer to run your Docker containers.

<details><summary>Show me the config file!</summary>
    
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

```main.nf```

This is the master script. Notice that it **does not do any bioinformatics analysis itself**. Instead, it defines the channels (the data pathways) and controls the execution order. It imports the individual modules your groups are working on and connects the outputs of one tool directly to the inputs of the next.

<details><summary>Show me the main Nextflow file!</summary>
    
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

Now work in groups
and build the process files
Group 1. QC
Group 2. trimming
Group 3. Salmon
Group 4. R (limma)

push to your branch

pull reqeust merge request

CICD tests??

Run the whole pipeline...
Inspect work directories and outputs...
Done

### Step 3: Group Work — Build Your Processes!
Now it is time to get hands-on. Break into your assigned groups. Your goal is to take your hollow .nf process files and turn them into fully functional Nextflow modules, utilizing the exact container commands you perfected earlier.

The Assignments
- Group 1: Quality Control → Complete fastqc.nf and multiqc.nf
- Group 2: Read Trimming → Complete trimming.nf
- Group 3: Quantification → Complete salmon.nf (both the indexing and quantification steps)
- Group 4: Differential Expression → Complete r_analysis.nf (using the R limma package)

### Step 4: Version Control and CI/CD
Once your group has a working process, it is time to integrate it into the main pipeline. We will follow standard, real-world software development practices.

**1. Push to Your Branch**
Commit your finished code and push it to your specific group's branch:

```
git add processes/your_process.nf
git commit -m "feat: complete [Tool Name] process"
git push origin group-[X]-branch
```

**2. Open a Pull Request (PR)**
Go to the repository on GitHub and open a Pull Request to merge your branch into the main branch.

**3. Automated CI/CD Tests (Continuous Integration)**
When you open your PR, you will likely notice automated checks running in GitHub. What is happening here?

- Syntax Checking: A CI/CD pipeline (via GitHub Actions) automatically lints your Nextflow code to ensure there are no missing brackets, typos, or syntax errors.
- Dry Runs: It may also run a tiny, simulated test dataset to verify that your process actually executes without instantly crashing.

> If the tests turn green, your code is verified and ready to be merged by the instructor!

**Step 5: The Grand Finale — Running the Pipeline**
Once all groups have successfully passed their CI/CD checks, the instructor will merge all the Pull Requests into the main branch.

We will then run the complete, integrated pipeline from the HPC terminal using this command:

```
nextflow run main.nf -profile slurm -resume
```

> Pro-Tip: The -resume Flag > This is Nextflow's superpower. If the pipeline fails halfway through (e.g., a typo in the R script), you don't have to start from scratch. Fixing the error and running with -resume tells Nextflow to use cached results for the successful steps and only rerun what failed!

**Step 6: Inspecting the Outputs**
As the pipeline finishes, we need to understand where our data went. Nextflow generates two highly important directories that you need to know how to navigate:

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
