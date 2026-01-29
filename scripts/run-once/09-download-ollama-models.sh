#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Download Ollama Models"
fake_loading

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
  echo -e "${BLUE}Downloading $model...${RESET}"
  if ollama pull "$model"; then
      echo -e "${GREEN}Successfully downloaded $model${RESET}"
  else
      echo -e "${RED}Failed to download $model. Please check your network connection.${RESET}"
  fi
done

echo -e "${GREEN}Ollama model download script finished.${RESET}"