#!/bin/bash

# A list of ollama models to download
MODELS=(
  "nomic-embed-text:latest"
  "qwen3:8b"
  "qwen2.5-coder:7b"
  "qwen3-vl:8b"
  "deepseek-r1:8b"
  "mistral:7b"
  "qwen2.5-coder:14b"
  "ministral-3:8b"
)

for model in "${MODELS[@]}"; do
  echo "Downloading $model..."
  ollama pull "$model"
  if [ $? -ne 0 ]; then
    echo "Failed to download $model. Please check your network connection or the model name."
  fi
done

echo "Ollama model download script finished."