#!/usr/bin/env bash

source /workspace/specvalid/.venv/bin/activate

models=$1

if [ -z "$models" ]; then
  echo "Error: No models specified."
  echo "Usage: $0 <models>"
  exit 1
fi

python3 specvalid/experiments/run_testgen_experiments_pipeline.py -m "$models"