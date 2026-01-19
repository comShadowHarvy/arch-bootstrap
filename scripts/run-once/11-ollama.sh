#!/bin/bash

# ==========================================
#  Ollama Server Installer (User Mode)
# ==========================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Starting Ollama Server Setup ===${NC}"

# 1. Install Ollama (Elevated)
if pacman -Qi ollama &> /dev/null; then
    echo -e "${BLUE}[*] Ollama is already installed.${NC}"
else
    echo -e "${GREEN}[+] Installing Ollama via pacman (requires sudo)...${NC}"
    if ! sudo pacman -S --noconfirm ollama; then
        echo -e "${RED}[!] Installation failed.${NC}"
        exit 1
    fi
fi

# 2. Configure for Server Mode (Elevated)
# We use 'sudo tee' to write to the protected file securely
SERVICE_DIR="/etc/systemd/system/ollama.service.d"
OVERRIDE_FILE="$SERVICE_DIR/override.conf"

echo -e "${GREEN}[+] Configuring Ollama to listen on 0.0.0.0 (requires sudo)...${NC}"

# Create directory if it doesn't exist
if [ ! -d "$SERVICE_DIR" ]; then
    sudo mkdir -p "$SERVICE_DIR"
fi

# Write the configuration
echo "[Service]
Environment=\"OLLAMA_HOST=0.0.0.0\"" | sudo tee "$OVERRIDE_FILE" > /dev/null

# 3. Enable and Restart Service (Elevated)
echo -e "${GREEN}[+] Reloading systemd and restarting Ollama (requires sudo)...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable --now ollama.service
sudo systemctl restart ollama.service

# 4. Wait for Service to spin up (User Level)
echo -e "${BLUE}[*] Waiting for Ollama API to be ready...${NC}"
until curl -s http://localhost:11434 > /dev/null; do
    sleep 2
    echo -n "."
done
echo ""

# 5. Pull Required Models (User Level)
# This runs as you, but it talks to the server we just set up.
# The server (running as 'ollama' user) handles the download and storage.
echo -e "${GREEN}[+] Pulling models...${NC}"

# DeepSeek (The Brain)
echo -e "${BLUE} > Pulling deepseek-r1:8b...${NC}"
ollama pull deepseek-r1:8b

# Nomic (The Indexer)
echo -e "${BLUE} > Pulling nomic-embed-text...${NC}"
ollama pull nomic-embed-text

echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo -e "Ollama is running via systemd."
echo -e "You can access it locally or from the network at: http://$(hostname -I | cut -d' ' -f1):11434"
