# SpecValid Replication Package

Docker container for running SpecValid experiments with automated test generation and validation using LLMs.

## Quick Start

### 1. Build Container

```bash
docker build -t specvalid .
```

### 2. Run Container

**With NVIDIA GPU:**

```bash
docker run --gpus all -it specvalid
```

**With AMD GPU:**

```bash
docker run --device /dev/kfd --device /dev/dri -v ollama:/root/.ollama -p 11434:11434 -it specvalid
```

**With external API services:**

```bash
# For OpenAI models (GPT-4, GPT-4o, GPT-3.5-turbo, etc.)
docker run -e OPENAI_API_KEY=your_openai_key --gpus all -it specvalid

# For Hugging Face models (Llama, Mistral, Phi, etc.)
docker run -e HUGGINGFACE_API_KEY=your_hf_key --gpus all -it specvalid

# For Google Gemini models
docker run -e GOOGLE_API_KEY=your_google_key --gpus all -it specvalid

# Multiple API keys
docker run -e OPENAI_API_KEY=your_openai_key -e HUGGINGFACE_API_KEY=your_hf_key --gpus all -it specvalid
```

**For local Ollama models (no API key needed):**

```bash
# Run container
docker run --gpus all -it specvalid

# Inside container, pull desired models
ollama pull llama3.2
ollama pull phi4
ollama pull mistral
ollama pull deepseek-r1:7b
```

**To persist experiment results (recommended):**

```bash
# Create local results directory
mkdir -p ./results

# Run with volume mapping
docker run --gpus all -v $(pwd)/results:/workspace/specvalid/experiments/results -it specvalid
```

### 3. Run Experiments

Inside the container:

```bash
./run_llm_testgen_and_validation.sh "model_name"
```

**Available model types:**

- **Local Ollama models** (prefix `L_`): `L_Llama318Instruct`, `L_Phi4`, `L_Mistral7B03Instruct`, `L_DeepSeekR1Qwen7`
- **OpenAI models** (prefix `GPT`): `GPT4o`, `GPT4oMini`, `GPT4Turbo`, `GPT35Turbo`
- **Hugging Face models**: `Llama3370Instruct`, `Phi35MiniInstruct`, `Mistral7B03Instruct`
- **Google Gemini models**: `Gemini25Flash`

Example models: `llama3.2`, `codellama`, `gpt-4`, etc.

## Accessing Results

Experiment results are saved in `/workspace/specvalid/experiments/results/` inside the container.

**Option 1: Volume mapping (recommended)**
Run with volume mapping as shown above to automatically save results to your local `./results` directory.

**Option 2: Copy from container**

```bash
# Find your container ID
docker ps -a

# Copy results from container to local directory
docker cp <container_id>:/workspace/specvalid/experiments/results ./results
```

**Option 3: Interactive access**
Keep the container running and access results interactively:

```bash
# Inside container, view results
ls /workspace/specvalid/experiments/results/
cat /workspace/specvalid/experiments/results/test_generation_stats.csv
```
