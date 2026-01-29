#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Set Etherape Cap (Run-Once)"
fake_loading

echo -e "${BLUE}Setting capabilities on etherape...${RESET}"
if sudo setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' @/usr/bin/etherape; then
    echo -e "${GREEN}Success.${RESET}"
else
    echo -e "${RED}Failed.${RESET}"
fi
