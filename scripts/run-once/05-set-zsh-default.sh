#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Set Zsh Default"
fake_loading

echo -e "${BLUE}Setting Zsh as the default shell...${RESET}"
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s $(which zsh) $(whoami)
    echo -e "${GREEN}Zsh is now the default shell. Please log out and log back in.${RESET}"
else
    echo -e "${GREEN}Zsh is already the default shell.${RESET}"
fi
