#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Compact and more readable script to run the generation/validation pipeline
SCRIPT_NAME=$(basename "$0")
VENV_PATH="/workspace/specvalid/.venv/bin/activate"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [-m models] [-p prompts]

Options:
  -m MODELS   Models (format: model1[,model2,...]). If not provided, a notice will be shown.
  -p PROMPTS  Prompts (optional)
  -h          Show this help

Example:
  $SCRIPT_NAME -m "L_Gemma31" -p "General_V1"
EOF
}

models=""
prompts=""

# Simple parsing of flags (-m and -p). If not used, positional args are allowed.
while getopts ":m:p:h" opt; do
  case $opt in
    m) models="$OPTARG" ;;
    p) prompts="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage; exit 2 ;;
  esac
done
shift $((OPTIND -1))

# Fallback to positional arguments if flags were not used
if [ -z "$models" ] && [ $# -ge 1 ]; then models="$1"; fi
if [ -z "$prompts" ] && [ $# -ge 2 ]; then prompts="$2"; fi

# Keep previous logic: error only if both models and prompts are empty.
if [ -z "$models" ] && [ -z "$prompts" ]; then
  echo "❌ Error: No models or prompts specified."
  echo ""
  echo "List of available LLMs (if the 'specvalid' command is in PATH):"
  if command -v specvalid >/dev/null 2>&1; then
    specvalid --list-llms || true
  else
    echo "  (command 'specvalid' not found in PATH)"
  fi
  echo ""
  usage
  exit 1
fi

if [ -z "$models" ]; then
  echo "⚠️  Warning: No models specified (-m)."
  if command -v specvalid >/dev/null 2>&1; then
    specvalid --list-llms || true
  fi
fi

# Activate virtual environment if it exists
if [ -f "$VENV_PATH" ]; then
  # shellcheck disable=SC1091
  source "$VENV_PATH"
else
  echo "ℹ️  Virtual environment not found at '$VENV_PATH'; continuing without activating it."
fi

# Build the command safely; only add -p if prompts is not empty
cmd=(python3 specvalid/experiments/run_testgen_experiments_pipeline.py)
if [ -n "$models" ]; then cmd+=(-m "$models"); fi
if [ -n "$prompts" ]; then cmd+=(-p "$prompts"); fi

echo "Executing: ${cmd[*]}"
exec "${cmd[@]}"