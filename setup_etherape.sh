#!/bin/bash
# Provide raw socket access and net admin capabilities to etherape
# This allows running it without sudo, preserving the user environment (themes, icons).

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/scripts/common.sh"

if [ -f "$COMMON_SCRIPT" ]; then
    source "$COMMON_SCRIPT"
else
    title_screen() { echo "Starting $1..."; }
    fake_loading() { sleep 1; }
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m';
fi

title_screen "Etherape Setup"
fake_loading

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root to set capabilities.${RESET}"
   echo "Please run: sudo $0"
   exit 1
fi

ETHERAPE_BIN=$(which etherape)

if [ -z "$ETHERAPE_BIN" ]; then
    echo -e "${RED}Error: etherape not found in PATH.${RESET}"
    exit 1
fi

echo -e "${CYAN}Setting capabilities on $ETHERAPE_BIN...${RESET}"
setcap cap_net_raw,cap_net_admin+ep "$ETHERAPE_BIN"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success! You can now run 'etherape' without sudo.${RESET}"
else
    echo -e "${RED}Failed to set capabilities.${RESET}"
    exit 1
fi
