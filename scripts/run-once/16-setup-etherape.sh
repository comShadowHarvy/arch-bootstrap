#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Etherape Setup"
fake_loading

# Provide raw socket access and net admin capabilities to etherape
# This allows running it without sudo, preserving the user environment (themes, icons).

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root to set capabilities.${RESET}"
   # If we are in run-once context mostly running as user, user might need to sudo this script explicitly.
   echo -e "${YELLOW}Please run: sudo $0${RESET}"
   # In automated run-once loop, typically we might not pause. But let's fail gracefully.
   exit 1
fi

ETHERAPE_BIN=$(which etherape)

if [ -z "$ETHERAPE_BIN" ]; then
    echo -e "${RED}Error: etherape not found in PATH.${RESET}"
    exit 1
fi

echo -e "${CYAN}Setting capabilities on $ETHERAPE_BIN...${RESET}"
if setcap cap_net_raw,cap_net_admin+ep "$ETHERAPE_BIN"; then
    echo -e "${GREEN}Success! You can now run 'etherape' without sudo.${RESET}"
else
    echo -e "${RED}Failed to set capabilities.${RESET}"
    exit 1
fi
