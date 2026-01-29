#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Autostart Udiskie"
fake_loading

echo -e "${BLUE}Configuring Udiskie...${RESET}"
echo -e "\n# Autostart udiskie\nexec-once = udiskie" >> ~/.config/hypr/hyprland.conf
echo -e "${GREEN}Added to hyprland config.${RESET}"
