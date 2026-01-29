#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Set Default Apps"
fake_loading

CONFIG_DIR="$HOME/.config"
MIMEAPPS_FILE="$CONFIG_DIR/mimeapps.list"

echo -e "${BLUE}Creating $MIMEAPPS_FILE...${RESET}"
mkdir -p "$CONFIG_DIR"

cat > "$MIMEAPPS_FILE" << EOL
[Default Applications]
video/x-matroska=mpv.desktop
video/mp4=mpv.desktop
video/webm=mpv.desktop
video/x-flv=mpv.desktop
video/quicktime=mpv.desktop
video/x-msvideo=mpv.desktop
video/x-ms-wmv=mpv.desktop

image/jpeg=imv.desktop
image/png=imv.desktop
image/gif=imv.desktop
image/bmp=imv.desktop
image/svg+xml=imv.desktop
EOL

echo -e "${GREEN}Default applications set.${RESET}"
