FROM golang:1.22

LABEL maintainer="bioinformatics-workshop" \
      description="Minimal container building seqkit from source"

# Install git (needed to fetch source code)
RUN apt-get update && apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Build seqkit from source
RUN git clone https://github.com/shenwei356/seqkit.git /opt/seqkit && \
    cd /opt/seqkit && \
    go build -o seqkit

# Make it available globally
RUN mv /opt/seqkit/seqkit /usr/local/bin/

# Default command
CMD ["seqkit", "--help"]