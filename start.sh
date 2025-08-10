#!/usr/bin/env bash
set -e
echo "Environment setup complete! 🎉"

# API key hints
if [ -z "$OPENAI_API_KEY" ]; then
  echo "NOTICE: OPENAI_API_KEY not set. OpenAI-based models won't be available."
fi
if [ -z "$HUGGINGFACE_API_KEY" ]; then
  echo "NOTICE: HUGGINGFACE_API_KEY not set. HuggingFace-based flows won't be available."
fi
if [ -z "$GOOGLE_API_KEY" ]; then
  echo "NOTICE: GOOGLE_API_KEY not set. Google-based flows won't be available."
fi
echo "If no API keys are set, local-only models will be available."

# Default Ollama host binding (so it is reachable from other containers/host)
export OLLAMA_HOST="${OLLAMA_HOST:-0.0.0.0}"

# GPU detection (best-effort)
GPU_TYPE="cpu"

# NVIDIA checks
if [ -c /dev/nvidia0 ] || command -v nvidia-smi >/dev/null 2>&1 || [ -f /proc/driver/nvidia/version ]; then
  GPU_TYPE="nvidia"
fi

# AMD/ROCm checks (best-effort)
if [ "$GPU_TYPE" = "cpu" ]; then
  if [ -c /dev/kfd ] || command -v rocm-smi >/dev/null 2>&1 || [ -d /opt/rocm ]; then
    GPU_TYPE="amd"
  fi
fi

echo "GPU detection result: $GPU_TYPE"

# Friendly runtime hints
if [ "$GPU_TYPE" = "nvidia" ]; then
  cat <<'WARN'
NVIDIA GPU detected inside container.
 -> Ensure the host has NVIDIA drivers + NVIDIA Container Toolkit installed.
 -> Start the container with:  docker run --gpus all -v ollama:/root/.ollama -p 11434:11434 your-image
See NVIDIA Container Toolkit docs for details.
WARN
elif [ "$GPU_TYPE" = "amd" ]; then
  cat <<'WARN'
AMD/ROCm GPU detected (or ROCm files present).
 -> For best compatibility prefer the official ROCm image: ollama/ollama:rocm
 -> If using this image, run with device passthrough, e.g.:
    docker run -d --device /dev/kfd --device /dev/dri -v ollama:/root/.ollama -p 11434:11434 your-image
WARN
else
  echo "No GPU found: Ollama will run on CPU. To use GPU, run the container with the proper host GPU flags."
fi

if [ "$1" = "serve" ] || [ -z "$1" ]; then
  echo "Starting Ollama server in background (OLLAMA_HOST=${OLLAMA_HOST}) ..."
  # Start Ollama in background and redirect logs to a file
  ollama serve > /var/log/ollama.log 2>&1 &
  OLLAMA_PID=$!
  
  echo "Ollama server started with PID: $OLLAMA_PID"
  echo "Container is ready! You can now access Ollama on port 11434"
  echo "Logs are being written to /var/log/ollama.log"
  echo "Use 'tail -f /var/log/ollama.log' to view logs"
  echo ""
  echo "You now have a shell! Type 'exit' to stop the container."
  
  /bin/bash
else
  exec "$@"
fi
