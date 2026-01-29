#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Configure Ollama Remote"
fake_loading

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root${RESET}"
  exit 1
fi

mkdir -p /etc/systemd/system/ollama.service.d
echo -e "${BLUE}Writing override configuration...${RESET}"
cat <<EOF > /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
EOF

echo -e "${BLUE}Reloading and restarting ollama service...${RESET}"
systemctl daemon-reload
systemctl restart ollama.service

echo -e "${GREEN}ollama service configured to accept remote connections.${RESET}"