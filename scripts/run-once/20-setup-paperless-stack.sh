#!/bin/bash

# Source common
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
if [ -f "$COMMON_SCRIPT" ]; then
    source "$COMMON_SCRIPT"
else
    # Fallback
    GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m';
    title_screen() { echo "=== $1 ==="; }
    fake_loading() { sleep 1; }
fi

title_screen "Paperless-ngx Stack Setup"
fake_loading

# --- CONFIGURATION ---
REPO_URL="https://github.com/timothystewart6/paperless-stack"
TARGET_DIR="$HOME/git/paperless-stack"
TUI_SCRIPT_SRC="$SCRIPT_DIR/../../run_stack_with_tui.py"

echo -e "${BLUE}=== Starting Setup ===${NC}"

# 1. Install & Configure NVIDIA Toolkit
echo -e "${GREEN}[+] Verifying NVIDIA Container Toolkit...${NC}"
if ! pacman -Qi nvidia-container-toolkit &> /dev/null; then
    echo -e "${BLUE}[*] Installing nvidia-container-toolkit... (sudo required)${NC}"
    sudo pacman -S --noconfirm nvidia-container-toolkit
else
    echo -e "${GREEN}[*] nvidia-container-toolkit already installed.${NC}"
fi

echo -e "${GREEN}[+] Configuring Docker Runtime...${NC}"
sudo nvidia-ctk runtime configure --runtime=docker
echo -e "${GREEN}[+] Restarting Docker...${NC}"
sudo systemctl restart docker

# 2. Clone Repository
echo -e "${GREEN}[+] Setting up Paperless Stack Repository...${NC}"
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${BLUE}[*] Cloning $REPO_URL to $TARGET_DIR...${NC}"
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo -e "${BLUE}[*] Updating existing repository at $TARGET_DIR...${NC}"
    cd "$TARGET_DIR" && git pull
fi

# 3. Setup TUI Launcher
echo -e "${GREEN}[+] Setting up TUI Launcher...${NC}"
cd "$TARGET_DIR"

# Ensure compose.yaml exists for the script
if [ ! -f "compose.yaml" ] && [ -f "docker-compose.yml" ]; then
    echo -e "${BLUE}[*] Symlinking docker-compose.yml to compose.yaml...${NC}"
    ln -sf docker-compose.yml compose.yaml
fi

if [ -f "$TUI_SCRIPT_SRC" ]; then
    cp "$TUI_SCRIPT_SRC" .
    echo -e "${GREEN}[*] Copied run_stack_with_tui.py to repository.${NC}"
else
    echo -e "${RED}[!] Error: Source TUI script not found at $TUI_SCRIPT_SRC${NC}"
    exit 1
fi

# 4. Pull Images (The Models)
echo -e "${GREEN}[+] Pulling Docker Images...${NC}"
docker compose pull

# 5. Launch Stack
echo -e "${GREEN}[+] Launching Stack with TUI Script...${NC}"
# Use python3 to run the TUI script which handles the compose up
python3 run_stack_with_tui.py

# 6. Pull Existing Models
echo -e "${GREEN}[+] Syncing Ollama Models...${NC}"
MODELS=(
    "deepseek-r1:8b"
    "rnj-1:8b"
    "qwen3:8b"
    "jayeshpandit2480/gemma3-UNCENSORED:4b"
    "llama3.2:3b"
)

echo "Waiting for Ollama service to be ready..."
until docker exec ollama ollama list &> /dev/null; do
    sleep 2
done

for model in "${MODELS[@]}"; do
    echo -e "${BLUE}[*] Pulling model: $model...${NC}"
    docker exec ollama ollama pull "$model"
done

echo -e "${BLUE}=== Setup Complete ===${NC}"
