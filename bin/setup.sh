#!/bin/bash
# set -euo pipefail

# Function to load environment variables from a file
load_env_file() {
  local env_file="$1"
  if [[ -f "$env_file" ]]; then
    echo "✅ Loading environment from $env_file"
    export $(grep -v '^#' "$env_file" | xargs)
  else
    echo "❌ Env file $env_file not found!"
    exit 1
  fi
}

# Detect current Terraform workspace
if ! command -v terraform &> /dev/null; then
  echo "❌ Terraform not found in PATH."
  exit 1
fi

WORKSPACE=$(terraform workspace show 2>/dev/null || echo "default")
ENV_FILE=".env.$WORKSPACE"

# Fallback to .env if workspace-specific file doesn't exist
if [[ ! -f "$ENV_FILE" ]]; then
  echo "⚠️  $ENV_FILE not found, falling back to .env"
  ENV_FILE=".env"
fi

load_env_file "$ENV_FILE"

# Set up Python virtual environment
VENV_DIR=".venv"

if [[ ! -d "$VENV_DIR" ]]; then
  echo "🚧 .venv not found, creating virtual environment..."
  if ! command -v python &> /dev/null; then
    echo "❌ 'python' not found in PATH. Aborting."
    exit 1
  fi

  python -m venv "$VENV_DIR"
  echo "✅ Virtual environment created at $VENV_DIR"

  if [[ -f "requirements.txt" ]]; then
    echo "📦 Installing dependencies from requirements.txt"
    source "$VENV_DIR/scripts/activate"
    pip install --upgrade pip
    pip install -r requirements.txt
  else
    echo "⚠️  requirements.txt not found. Skipping dependency install."
  fi
fi

# Activate the virtual environment
echo "🐍 Activating virtual environment"
source "$VENV_DIR/scripts/activate"

echo "✅ Environment ready (Terraform workspace: $WORKSPACE)"
