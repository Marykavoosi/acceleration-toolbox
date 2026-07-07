## Bioinformatics Containers

### 1. Why Containers?

Have you ever tried to run a tool that worked perfectly on a colleague's laptop, only to face hours of installation errors on your own machine? This is the exact problem containers solve.

In bioinformatics, reproducibility is critical. A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another.

In this workshop, we will use containers to build reproducible steps of a Nextflow pipeline.

Why are they useful?
- **Reproducibility**: A containerized pipeline run today will produce the exact same results 5 years from now.
- **Dependency Isolation**: Need a specific version for one tool? Containers keep their environments entirely separated.
- **Portability**: You can move the exact same environment from your laptop to a massive HPC cluster or the cloud.



### Containers in Nextflow

Nextflow integrates seamlessly with containers. Instead of installing tools locally, each process in a pipeline can spin up its own container, run the job, and shut down:

```{groovy}
process FASTQC {
    container 'your-dockerhub-username/fastqc:latest'
    
    script:
    """
    fastqc input.fastq
    """
}
```

### 2. Key concepts and DockerHub
- **Image**: A read-only blueprint containing the OS, software, and dependencies.
- **Container**: A running, active instance of an image.
- **Dockerfile**: A simple text script containing the instructions used to build an image.
- **[DockerHub](https://hub.docker.com)**: "GitHub for Docker images." It is a public registry where developers upload their built images so others can download (pull) and use them. 

<img width="1200" height="594" alt="image" src="https://github.com/user-attachments/assets/0d7ffc96-c457-4631-b3cb-e7d332f6d2c8" />

### 3. Basic Structure of a Dockerfile

A Dockerfile is built layer by layer using specific keywords:

#### FROM

The starting point or base image (e.g., ubuntu:22.04 or python:3.10-slim). Every Dockerfile must start with a FROM statement.
```
FROM ubuntu:22.04
```
For ML pipelines, you might use a base image that already has Python and some libraries installed:
```
FROM python:3.10-slim
```
For R pipelines, you might use a base image that already has R installed:
```
FROM rocker/r-ver:4.3.1
```
Running conda environments
```
FROM continuumio/miniconda3:latest
```

3.1. Why is it better to use python:slim instead of full ubuntu?

3.2. How do you know which base image to use for your tool? 

#### RUN

Executes terminal commands during build.

Update the system and install FastQC in one layer to reduce image size:
```
RUN apt-get update && apt-get install -y fastqc
```
Important to combine commands with `&&` and clean up cache to reduce image size:
```
RUN apt-get update && \
    apt-get install -y fastqc && \
    rm -rf /var/lib/apt/lists/*
```
3.3. Why is it important to clean up the cache after installing packages?

3.4. Why do we delete /var/lib/apt/lists/*?

#### WORKDIR

Sets the working directory inside the container.
```
WORKDIR /data
```

3.5. What happens if you don’t set WORKDIR?

#### COPY

Copies files from your local machine into the container.
```
COPY script.sh /usr/local/bin/script.sh
```

3.7. Why is COPY preferred over downloading files inside container?

#### ENV

Sets environment variables inside the container.
```
ENV PATH="/usr/local/bin:${PATH}"
ENV LC_ALL=C
```
3.6. Why is setting LC_ALL sometimes important in bioinformatics?

#### CMD vs ENTRYPOINT

The default command that runs when the container starts. CMD can be overridden by arguments passed to `docker run`. ENTRYPOINT is used when you want the container to always run a specific command, treating any additional arguments as parameters for that command.

#### CMD (default command)

```
CMD ["fastqc", "--version"]
```

#### ENTRYPOINT (fixed tool)

```
ENTRYPOINT ["fastqc"]
```

3.7. When would ENTRYPOINT be better than CMD in a bioinformatics container?

<img width="1184" height="831" alt="image" src="https://github.com/user-attachments/assets/2215ba89-df63-43b6-a8a8-818ebf3742f6" />

### 4. Building & Running: Docker vs. Apptainer (HPC)

**If you have Root privileges (e.g., on your personal laptop):**
You would typically build and test containers using Docker directly:
```
cd 02_Containers/seqkit_container
docker compose build    # or docker compose up --build
docker run --rm seqkit-workshop seqkit --help       # or docker compose run seqkit seqkit --help
```

4.1. Why is `--rm` useful when testing?

**Working on an HPC (Workshop Reality):** \
Docker requires root (administrator) privileges to run, which poses a massive security risk on shared High-Performance Computing (HPC) clusters. Therefore, HPCs use Apptainer (formerly named Singularity).

Apptainer can download and run Docker images without requiring root privileges.

The Problem: If we don't have root on the HPC, how do we build our Docker images?
> The Solution: We will write the code, push it to GitHub, and let an automated GitHub workflow build it and push it to Docker Hub for us!

------------------

### 5. Building Your Own Containers
You will work in groups. Each group is responsible for creating a working Docker container for one step of our RNA-seq workflow:
1. Quality control --> ```FastQC``` and ```MultiQC```
2. Read trimming --> ```trimmomatic```
3. Alignment + quantification (pseudodalignment) --> ```Salmon```
4. Differential expression analysis --> ```R + limma```

### The workflow

1. Write your Dockerfile: Your group will be given an incomplete or empty Dockerfile. Use the examples below to fill it out and make it working.
2. Commit and Push: Push your completed Dockerfile to your group's specific branch on the workshop's GitHub repository.
3. Wait for the Automated Build: Once pushed, a GitHub Action will automatically trigger. It will read your Dockerfile, build the image, and push it directly to Docker Hub. (Check the "Actions" tab in GitHub to watch it build!)
4. Test on the HPC with Apptainer: Once the build is successful, log into the HPC. Use Apptainer to pull your new image from Docker Hub and test if the tool installed correctly by checking its version.

### Testing Command Example
Use this command to test your automatically built image on the HPC:
```
ml apptainer
apptainer exec docker://hcemm/bioinfo-workshop:group_tag installed_tool --version
```

5.1. What is the difference between image and container?
5.2. Why do we need containers in HPC?
5.3. Why is reproducibility improved by containers?
5.4. What happens if two tools require different Python versions?
5.5. Could you fully reproduce a container without internet access?
5.6. What is the weakest point of container reproducibility?

## Answers



|Group|Tool|DockerHub Tag|
|------|--------|----------|
| Group1 | FastQC + MultiQC | hcemm/bioinfo-workshop:fastqc|
| Group2| trimmomatic | hcemm/bioinfo-workshop:trimming|
| Group3 | salmon | hcemm/bioinfo-workshop:salmon|
| Group4 | R + limma | hcemm/bioinfo-workshop:limma|

-----------------------

### 6. Example DockerFile

```sh
# 1. BASE IMAGE (Required)
# Always start here. What OS or programming language environment do you need?
FROM [base-image]:[version-tag]

# 2. METADATA (Optional but good practice)
# Add labels for author, version, or description.
LABEL maintainer="[your-name]" \
      description="[what-this-container-does]"

# 3. ENVIRONMENT VARIABLES (Optional)
# Set paths, locale settings, or flags (e.g., to stop interactive prompts during install).
ENV [VARIABLE_NAME]="[value]"

# 4. INSTALL DEPENDENCIES (Required)
# Update the package manager, install your required tools, and CLEAN UP cache 
# to keep the image size as small as possible. Combine into one RUN statement with &&.
RUN [update-command] && \
    [install-command] [dependency-1] [dependency-2] && \
    [cleanup-command]

# 5. WORKING DIRECTORY (Recommended)
# Set the default directory where all subsequent commands will be run.
# If it doesn't exist, Docker creates it.
WORKDIR /[directory-name]

# 6. ADD LOCAL FILES (Optional)
# Copy scripts, code, or configuration files from your computer/repo into the container.
COPY [local-path-to-file] [container-destination-path]

# 7. EXECUTION COMMAND (Required)
# The default command that runs when the container starts.
# Use the "exec form" (JSON array) for cleaner signal handling.
CMD ["[tool-or-executable]", "[flag]", "[argument]"]

# (Alternative to CMD) 
# Use ENTRYPOINT if the container is designed to run ONLY one specific tool, 
# treating any extra arguments passed during 'docker run' as arguments for that tool.
# ENTRYPOINT ["[tool-or-executable]"]
```

3.1 Why is it better to use python:slim instead of full ubuntu? 

<details> <summary><b>Answer</b></summary>

Because python:slim:

is much smaller in size

contains only essential dependencies

reduces build time

reduces security vulnerabilities

is faster to transfer and deploy (important for HPC + CI)

👉 Ubuntu full images include many unnecessary packages that are not needed for bioinformatics pipelines.

</details>

3.2 How do you know which base image to use for your tool?
<details> <summary><b>Answer</b></summary>

You choose based on the tool ecosystem:

Python tools → python:* images

R tools → rocker/r-ver

Conda-based pipelines → continuumio/miniconda3

Prebuilt bioinformatics tools → biocontainers/*

👉 Rule of thumb:
Use the closest official ecosystem image to reduce installation complexity.

</details>

3.3 Why is it important to clean up the cache after installing packages?
<details> <summary><b>Answer</b></summary>

Because package managers store temporary files used only during installation.

Cleaning cache:

reduces image size significantly

removes unnecessary build artifacts

improves portability and download speed

👉 Especially important in HPC where storage + transfer matters.

</details>

3.4 Why do we delete /var/lib/apt/lists/*?
<details> <summary><b>Answer</b></summary>

Because it contains:

package index metadata used only during apt-get update

After installation, it is no longer needed.

👉 Removing it:

reduces image size

avoids stale package metadata

improves reproducibility of builds

</details>

3.5 What happens if you don’t set WORKDIR?
<details> <summary><b>Answer</b></summary>
The container uses / (root) as default working directory

files may be written in unexpected locations

relative paths may break scripts

👉 WORKDIR ensures predictable execution context.

</details>

3.6 Why is setting LC_ALL sometimes important in bioinformatics?
<details> <summary><b>Answer</b></summary>

Because locale settings affect:

string sorting

text parsing behavior

character encoding

Setting:

LC_ALL=C

ensures:

consistent ASCII-based sorting

reproducible output across systems

👉 Prevents subtle differences between environments.

</details>

3.7 When would ENTRYPOINT be better than CMD in a bioinformatics container?
<details> <summary><b>Answer</b></summary>

Use ENTRYPOINT when:

the container is designed for one tool only

you want to enforce a fixed executable

you want consistent CLI behavior

Example:

ENTRYPOINT ["fastqc"]

👉 CMD is better when:

you want flexibility in overriding commands
</details>

4.1 Why is --rm useful when testing?
<details> <summary><b>Answer</b></summary>

Because it:

automatically deletes the container after execution

prevents accumulation of stopped containers

keeps the system clean during iterative testing

👉 Important for rapid debugging workflows.

</details>

5.1 What is the difference between image and container?
<details> <summary><b>Answer</b></summary>
Image = static blueprint (read-only template)
Container = running instance of that image

👉 Analogy:

Image = class definition
Container = object instance
</details>

5.2 Why do we need containers in HPC?
<details> <summary><b>Answer</b></summary>

Because HPC environments:

are shared between many users

do not allow root access (security)

require reproducible software environments

Containers solve this by:

packaging software + dependencies

running without root (Apptainer)

ensuring reproducibility across users

</details>

5.3 Why is reproducibility improved by containers?
<details> <summary><b>Answer</b></summary>

Because containers fix:

software versions

dependency versions

system libraries

environment configuration

👉 This ensures that the same pipeline produces the same results across machines and time.

</details>

5.4 What happens if two tools require different Python versions?
<details> <summary><b>Answer</b></summary>

Without containers:

dependency conflicts occur (“dependency hell”)

one tool overwrites the other’s environment

pipeline breaks

With containers:

each tool runs in isolated environment

no conflicts between versions

</details>

5.5 Could you fully reproduce a container without internet access?
<details> <summary><b>Answer</b></summary>

Yes, but only if:

all dependencies are already included in the image

no external downloads are required during build or runtime

If external sources are needed:

reproducibility fails without network access
</details>

5.6 What is the weakest point of container reproducibility?
<details> <summary><b>Answer</b></summary>

External dependencies outside the container:

package repositories (apt, CRAN, pip)

GitHub source code

online databases

remote downloads during build

👉 If those change or disappear, builds may break even if the container definition is unchanged.

</details>

------------------
|Previous|Home|Next|
|--------|----|----|
|[GitHub](../01_GitHub/README.md)|[Home](../README.md)|[Workflow Managers](../03_Workflow_Managers/README.md)
