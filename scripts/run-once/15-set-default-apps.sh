#!/bin/bash

CONFIG_DIR="$HOME/.config"
MIMEAPPS_FILE="$CONFIG_DIR/mimeapps.list"

# Create the .config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Create the mimeapps.list file with the desired associations
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

echo "Default applications set in $MIMEAPPS_FILE"
