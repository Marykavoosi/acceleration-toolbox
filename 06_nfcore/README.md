# *nf-core*


<img width="500" alt="image" src="https://github.com/user-attachments/assets/942aaaad-9418-4c50-9142-5803967c00a9" />

## 1. Background: The nf-core Initiative

In the era of massive genomics data, reproducibility and scalability are paramount. While **Nextflow** provides a robust domain-specific language (DSL) for writing scalable workflows, researchers often found themselves "reinventing the wheel" by writing their own custom RNA-seq, ChIP-seq, or WGS pipelines. 

**nf-core** was born out of the need to standardize these efforts. It is a community-driven project to collect a curated set of bioinformatics analysis pipelines built using Nextflow. 

**Key Principles of nf-core:**
* **Reproducibility:** Ensuring that data analyzed today will yield the exact same results years from now, regardless of the compute environment.
* **Portability:** Write once, run anywhere. Pipelines run seamlessly on a laptop, a university HPC cluster, or public clouds (AWS, GCP, Azure).
* **Community:** Developed collaboratively by institutions worldwide, ensuring pipelines represent the current best practices in bioinformatics.


---

## 2. The nf-core Platform & Infrastructure

The power of nf-core lies in how it abstracts the underlying computational platform, allowing workflow managers to focus on data rather than IT configuration.

### Containerization
Every tool used in an nf-core pipeline is containerized. nf-core mandates that pipelines support multiple software packaging tools:
* **Docker:** Ideal for local development and cloud execution.
* **Singularity / Apptainer:** The standard for High-Performance Computing (HPC) clusters due to its secure user-space execution.
* **Conda:** Provided as a fallback, though containers are highly preferred for strict reproducibility.

### Execution Environments
Through Nextflow's abstraction, an nf-core pipeline can be deployed on various infrastructures simply by changing the `-profile` flag:
* **Local:** Executing directly on a single machine.
* **HPC Schedulers:** Native integration with Slurm, PBS, SGE, LSF.
* **Cloud Batch Services:** AWS Batch, Google Cloud Life Sciences, Azure Batch.
* **Kubernetes:** For cloud-native orchestration.

### Nextflow Tower (Seqera Platform)
For enterprise workflow managers, nf-core pipelines integrate natively with Seqera Platform (formerly Nextflow Tower), providing a GUI for launching, monitoring, and auditing pipeline runs across multiple compute environments.
<img width="1335" height="619" alt="image" src="https://github.com/user-attachments/assets/2def7194-a292-4494-bc4a-3c3767ad4191" />


### Getting Started Tutorial
[nf-core/demo](https://nf-co.re/docs/get_started/run-your-first-pipeline)

---

## 3. Standardized Workflows

What makes an nf-core pipeline different from a standard Nextflow script? **Strict standardization.**

To be accepted into the nf-core repository, a pipeline must pass rigorous automated testing and adhere to strict guidelines:
1.  **Continuous Integration (CI):** Every commit triggers GitHub Actions that run the pipeline on minimal test datasets to ensure no code breaks the workflow.
2.  **Linting:** The `nf-core lint` tool enforces code formatting, standard parameter naming (e.g., always using `--input` for input files, `--outdir` for output directory), and documentation standards.
3.  **Standardized Output:** All pipelines generate comprehensive MultiQC reports summarizing the run, software versions, and primary QC metrics.
4.  **Stable Releases:** Pipelines are versioned using Git tags (e.g., `3.10.1`). Users are encouraged to run a specific release (using `-r`) rather than the `master` branch to guarantee long-term reproducibility.

**List of nf-core pipelines:**
[nf-core/pipelines](https://nf-co.re/pipelines/)

<img width="1652" height="878" alt="image" src="https://github.com/user-attachments/assets/d54b0edd-ba8d-4845-97a7-a452d7f7225e" />

---

## 4. nf-core Usage: The Command Line Interface

While Nextflow handles the execution, the nf-core tools Python package provides a powerful Command Line Interface (CLI) designed to help workflow managers discover, configure, and deploy these standardized pipelines.

The `nf-core` Python package is the primary command-line tool for interacting with the ecosystem.

**Installation:**
The nf-core CLI is built in Python and can be easily installed via pip or conda:

```{bash}
# Using pip
pip install nf-core

# Using conda (creates an isolated environment)
conda create -n nf-core python=3.10 nf-core -c bioconda
conda activate nf-core
```

**Essential CLI commands**
- ```nf-core pipeline list```: Displays a dynamically updated list of all available pipelines in the nf-core repository. It shows the latest stable release version, when it was last updated, and whether it has been downloaded locally.
  - > Tip: Use ```nf-core pipeline list rnaseq``` to filter for specific keywords.
- ```nf-core pipeline launch <pipeline>```: Instead of manually writing long bash scripts with dozens of --parameters, this command starts an interactive, web-based (or CLI-based) wizard. It walks you through every available parameter, validates your inputs, and generates a ```params.json``` file to safely launch the run.
- ```nf-core pipeline download <pipeline>```: Essential for institutions with strict security protocols. This command downloads the pipeline code, the exact institutional configuration files, and even pulls the required Docker/Singularity container images for offline, air-gapped execution.

<img width="1378" height="493" alt="image" src="https://github.com/user-attachments/assets/eb3ea00d-1d9a-41cc-ae87-214b8c4056bc" />


## 5. Example Run Analysis: ```nf-core/rnaseq```

To demonstrate the power of the platform, we will walk through setting up and running nf-core/rnaseq, the community's flagship pipeline for RNA sequencing analysis. It handles everything from raw read QC and adapter trimming to alignment (STAR) and transcript-level quantification (Salmon) - *green metro path*.

<img width="1795" height="631" alt="image" src="https://github.com/user-attachments/assets/381b40e7-0872-4b0e-80e8-6c8bb21d0973" />


### **Step 1** Prepare the Sample Sheet

```nf-core``` pipelines utilize a strict, standardized ```CSV``` format for data input to ensure metadata is passed correctly.
Create a file named ```samplesheet.csv```. It must contain the exact headers: 

- ```sample```,
- ```fastq_1```,
- ```fastq_2``` and
- ```strandedness```.

```{bash}
sample,fastq_1,fastq_2,strandedness
Control1,path/to/data/ctrl_1_R1.fq.gz,data/ctrl_1_R2.fq.gz,auto
Contro2,path/to/data/ctrl_2_R1.fq.gz,data/ctrl_2_R2.fq.gz,auto
Treated1,path/to/data/treat_1_R1.fq.gz,data/treat_1_R2.fq.gz,auto
Treated2,path/to/data/treat_2_R1.fq.gz,data/treat_2_R2.fq.gz,auto

```
> Note: Setting strandedness to auto tells the pipeline to automatically infer the library prep directionality.

### **Step 2** Execute the pipeline

Nextflow separates the logic (what the pipeline does) from the configuration (where and how it runs). We control this using the ```-profile``` flag.
In this example, we will run the pipeline using Docker for dependency management, specify a stable release version (```-r 3.14.0```) to ensure reproducibility, and use a pre-configured reference genome (*GRCh38*)

```{bash}
nextflow run nf-core/rnaseq \
    -r 3.14.0 \
    -profile apptainer \
    --input samplesheet.csv \
    --outdir results/rnaseq_output \
    --genome GRCh38 \
    --aligner star_salmon \
    --max_cpus 16 \
    --max_memory '32.GB'
```

----------------

**Alternatively** we can laucnh the setup tool with the necessary imput parameters and start the analysis based on:
- A. ```launch_id``` - After setting up all the parameters online

```
nf-core launch --id 1782913143_322d17c5ccf4
```

<img width="934" height="581" alt="image" src="https://github.com/user-attachments/assets/308f6a9e-3aa9-44db-9614-8c5f87351121" />

----------------------

- B. ```Using parameters.json``` file

*parameters.json*
```{json}
{
    "input": "samplesheet.csv",
    "outdir": "results/rnaseq_output",
    "genome": "GRCh38"
}
```

Start analysis:
```{bash}
nextflow run nf-core/rnaseq -r 3.14.0 -profile apptainer -params-file parameters.json
```

<img width="792" height="320" alt="image" src="https://github.com/user-attachments/assets/a4d013be-0d76-4872-93fb-a61612f19fdc" />


### **Step 3** Inspect output

One of the main benefits of nf-core is standardized output structures. When the run finishes, check the ```--outdir``` (results/rnaseq_output). You will find well-organized directories:

- ```fastqc/``` & ```trimgalore```/: Contains pre- and post-trimming read quality metrics.
- ```star_salmon/```: Contains the aligned BAM files, BigWig tracks for visualization in IGV, and the computed gene/transcript counts.
- ```multiqc/```: The crown jewel of the output. This directory contains a multiqc_report.html file that aggregates logs from FastQC, Cutadapt, STAR, and Salmon into a single, interactive, presentation-ready web dashboard.
- ```pipeline_info/```: Contains detailed trace, timeline, and execution reports generated by Nextflow. Workflow managers use these files to audit runtimes, track cloud compute costs, and optimize resource allocation for future runs.

<img width="1637" height="801" alt="image" src="https://github.com/user-attachments/assets/71bc428f-a2af-44b1-89a9-7fc7be8ccfc5" />

*Pipeline execution summary report (with cached processes from previous run)*

<img width="1059" height="1761" alt="image" src="https://github.com/user-attachments/assets/53110614-08c5-404f-a022-bbb1f8f56355" />

*Execution timeline of nf-core/rnaseq*

<img width="848" height="806" alt="image" src="https://github.com/user-attachments/assets/05dc6227-c068-4bfd-94c3-985f4a91bce0" />

*Overview of resource usage for each process*

<img width="1640" height="854" alt="image" src="https://github.com/user-attachments/assets/062e217a-a6b1-4853-9370-6118dd57a751" />
*MultiQC report*





