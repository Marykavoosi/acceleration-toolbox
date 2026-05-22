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

### 2. Key conepts and the Docker Hub
- **Image**: A read-only blueprint containing the OS, software, and dependencies.
- **Container**: A running, active instance of an image.
- **Dockerfile**: A simple text script containing the instructions used to build an image.
- **Docker Hub**: Think of it as "GitHub for Docker images." It is a public registry where developers upload their built images so others can download (pull) and use them. [DockerHub](https://hub.docker.com)

<img width="1200" height="594" alt="image" src="https://github.com/user-attachments/assets/0d7ffc96-c457-4631-b3cb-e7d332f6d2c8" />

### 3. Basic Structure of a Dockerfile

A Dockerfile is built layer by layer using specific keywords:
- **FROM**: The starting point or base image (e.g., ubuntu:22.04 or python:3.10-slim). Every Dockerfile must start with a FROM statement.
- **RUN**: Executes terminal commands to install software or download files (e.g., RUN apt-get install -y wget).
- **WORKDIR**: Sets the working directory inside the container.
- **COPY**: Copies files from your local machine into the container.
- **CMD**: The default command the container runs if no other command is provided.

<img width="1184" height="831" alt="image" src="https://github.com/user-attachments/assets/2215ba89-df63-43b6-a8a8-818ebf3742f6" />

### 4. Building & Running: Docker vs. Apptainer (HPC)
**If you have Root privileges (e.g., on your personal laptop):**
You would typically build and test containers using Docker directly:
```
docker build -t my-tool:latest .
docker run --rm my-tool:latest
```

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
3. Alignment + quantification (psueodalignment) --> ```Salmon```
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

|Group|Tool|DockerHub Tag|
|------|--------|----------|
| Group1 | FastQC + MultiQC | hcemm/bioinfo-workshop:fastqc|
| Group2| trimmomatic | hcemm/bioinfo-workshop:trimming|
| Group3 | salmon | hcemm/bioinfo-workshop:salmon|
| Group4 | R + limma | hcemm/bioinfo-workshop:limma|


-----------------------

### 6. Example DockerFile

```
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

