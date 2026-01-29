#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Install Dotfiles"
fake_loading

echo -e "${BLUE}Running dotfilesinstaller with hyprland-starter.dotinst...${RESET}"
flatpak run com.ml4w.dotfilesinstaller --install-url https://raw.githubusercontent.com/mylinuxforwork/hyprland-starter/main/hyprland-starter.dotinst

echo -e "${GREEN}Dotfiles installation process initiated.${RESET}"
