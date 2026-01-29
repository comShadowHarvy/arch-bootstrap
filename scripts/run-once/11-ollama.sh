#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Ollama Server Installer"
fake_loading

# 1. Install Ollama (Elevated)
if pacman -Qi ollama &> /dev/null; then
    echo -e "${BLUE}[*] Ollama is already installed.${RESET}"
else
    echo -e "${GREEN}[+] Installing Ollama via pacman (requires sudo)...${RESET}"
    if ! sudo pacman -S --noconfirm ollama; then
        echo -e "${RED}[!] Installation failed.${RESET}"
        exit 1
    fi
fi

# 2. Configure for Server Mode (Elevated)
SERVICE_DIR="/etc/systemd/system/ollama.service.d"
OVERRIDE_FILE="$SERVICE_DIR/override.conf"

echo -e "${GREEN}[+] Configuring Ollama to listen on 0.0.0.0 (requires sudo)...${RESET}"

if [ ! -d "$SERVICE_DIR" ]; then
    sudo mkdir -p "$SERVICE_DIR"
fi

echo "[Service]
Environment=\"OLLAMA_HOST=0.0.0.0\"" | sudo tee "$OVERRIDE_FILE" > /dev/null

# 3. Enable and Restart
echo -e "${GREEN}[+] Reloading systemd and restarting Ollama (requires sudo)...${RESET}"
sudo systemctl daemon-reload
sudo systemctl enable --now ollama.service
sudo systemctl restart ollama.service

# 4. Wait
echo -e "${BLUE}[*] Waiting for Ollama API to be ready...${RESET}"
until curl -s http://localhost:11434 > /dev/null; do
    sleep 2
    echo -n "."
done
echo ""

# 5. Pull Models
echo -e "${GREEN}[+] Pulling models...${RESET}"
echo -e "${BLUE} > Pulling deepseek-r1:8b...${RESET}"
ollama pull deepseek-r1:8b

echo -e "${BLUE} > Pulling nomic-embed-text...${RESET}"
ollama pull nomic-embed-text

echo -e "${GREEN}=== Setup Complete! ===${RESET}"
echo -e "${CYAN}Ollama is running via systemd at: http://$(hostname -I | cut -d' ' -f1):11434${RESET}"
