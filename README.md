# Setup

## Download GAssert subjects from this link ()
Download the subjects used in SpecFuzzer (GAssert subjects) from this link.
https://drive.google.com/file/d/14QH1LFURZuDvWFJTXS8KYslt9H9S4tt-/view

## Download our Daikon version:


### Build

```bash
docker build -t specvalid .
```

### Run container with NVIDIA GPU:

```bash
docker run --gpus all -it specvalid
```

### Run container with AMD GPUS:

```bash
docker run -d --device /dev/kfd --device /dev/dri -v ollama:/root/.ollama -p 11434:11434 specvalid
```

If you have API key, you must export the apis:

````bash
docker run -e API_KEY=your_api_key_here --gpus all -it specvalide
```

### Run llm test generation and validation

```bash
./run_llm_testgen_and_validation.sh "<models>"
````
# specvalid-replication-package
