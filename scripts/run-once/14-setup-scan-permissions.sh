#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Setup Scan Permissions"
fake_loading

NMAP_PATH=$(which nmap)
ETHERAPE_PATH=$(which etherape)
NETPEEK_PATH=$(which netpeek)

if [ -z "$NMAP_PATH" ]; then
    echo -e "${YELLOW}nmap not found.${RESET}"
else
    echo -e "${BLUE}Setting capabilities for nmap...${RESET}"
    sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip "$NMAP_PATH" && echo -e "${GREEN}Success.${RESET}"
fi

if [ -z "$ETHERAPE_PATH" ]; then
    echo -e "${YELLOW}etherape not found.${RESET}"
else
    echo -e "${BLUE}Setting capabilities for etherape...${RESET}"
    sudo setcap cap_net_raw,cap_net_admin+eip "$ETHERAPE_PATH" && echo -e "${GREEN}Success.${RESET}"
fi

if [ -z "$NETPEEK_PATH" ]; then
    echo -e "${YELLOW}netpeek not found.${RESET}"
else
    echo -e "${BLUE}Setting capabilities for netpeek...${RESET}"
    sudo setcap cap_net_raw,cap_net_admin+eip "$NETPEEK_PATH" && echo -e "${GREEN}Success.${RESET}"
fi

echo -e "${MAGENTA}Capabilities setup complete.${RESET}"
