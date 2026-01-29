#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Enable Ollama Service"
fake_loading

echo -e "${BLUE}Enabling ollama service...${RESET}"
if systemctl enable ollama.service; then
    echo -e "${GREEN}Service enabled.${RESET}"
else
    echo -e "${RED}Failed manually to enable service.${RESET}"
fi