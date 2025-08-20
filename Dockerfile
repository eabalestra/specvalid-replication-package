# Use the official Ollama image as base so runtime + GPU support is baked-in.
# If you will run primarily on AMD/ROCm hosts, swap to: FROM ollama/ollama:rocm
FROM ollama/ollama:0.11.5

ENV DEBIAN_FRONTEND=noninteractive
ENV DAIKONDIR=/workspace/daikon-5.8.2
ENV GASSERT_DIR=/workspace/GAssert
ENV SPECS_DIR=/workspace/specfuzzer-subject-results
ENV SPECVALID_DIR=/workspace/specvalid

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    unzip \
    tar \
    openjdk-8-jdk \
    python3.12 \
    python3.12-venv \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /workspace

# Clone repos
RUN git clone https://github.com/eabalestra/specfuzzer-subject-results.git "${SPECS_DIR}"

ARG CACHEBUST=1
RUN echo $CACHEBUST \
    && git clone https://github.com/eabalestra/specvalid.git "${SPECVALID_DIR}"

# Copy compressed files into image (from build context)
COPY daikon-5.8.2.zip /workspace/
COPY GAssert.tar.gz /workspace/

# Extract and cleanup
RUN unzip /workspace/daikon-5.8.2.zip -d /workspace/ \
    && tar -xzf /workspace/GAssert.tar.gz -C /workspace/ \
    && rm /workspace/daikon-5.8.2.zip /workspace/GAssert.tar.gz

# Create virtualenv and install python deps for specvalid
RUN python3 -m venv /workspace/specvalid/.venv \
    && /workspace/specvalid/.venv/bin/pip install --upgrade pip \
    && /workspace/specvalid/.venv/bin/pip install --no-cache-dir -r /workspace/specvalid/requirements.txt \
    && /workspace/specvalid/.venv/bin/pip install -e /workspace/specvalid

COPY run_llm_testgen_and_validation.sh /workspace/run_llm_testgen_and_validation.sh
RUN chmod +x /workspace/run_llm_testgen_and_validation.sh

COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

# Expose Ollama API port
EXPOSE 11434

WORKDIR /workspace

ENTRYPOINT ["/workspace/start.sh"]

CMD ["serve"]
