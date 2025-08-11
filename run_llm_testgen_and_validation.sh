#!/usr/bin/env bash

source /workspace/specvalid/.venv/bin/activate

models=$1
prompts="General_V1"


if [ -z "$models" ]; then
  echo "❌ Error: No models specified."

  specvalid --list-llms

  echo "ℹ️  Usage: $0 model1[,model2,...] (model1: required, additional models: optional, comma-separated)"
  echo ""
  exit 1
fi

python3 specvalid/experiments/run_testgen_experiments_pipeline.py -m "$models" -p "$prompts"