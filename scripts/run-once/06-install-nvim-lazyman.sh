#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Install Nvim Lazyman"
fake_loading

echo -e "${BLUE}Cloning nvim-lazyman repository...${RESET}"
if [ ! -d "$HOME/.config/nvim-Lazyman" ]; then
    git clone https://github.com/doctorfree/nvim-lazyman "$HOME/.config/nvim-Lazyman"
else
    echo -e "${GREEN}nvim-lazyman repository already exists.${RESET}"
fi

echo -e "${BLUE}Running lazyman.sh...${RESET}"
if [ -f "$HOME/.config/nvim-Lazyman/lazyman.sh" ]; then
    "$HOME/.config/nvim-Lazyman/lazyman.sh"
    echo -e "${GREEN}nvim-lazyman installation and setup complete!${RESET}"
else
    echo -e "${RED}Error: $HOME/.config/nvim-Lazyman/lazyman.sh not found.${RESET}"
    exit 1
fi
