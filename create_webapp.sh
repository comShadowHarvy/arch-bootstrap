#!/bin/bash

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/scripts/common.sh"

if [ -f "$COMMON_SCRIPT" ]; then
    source "$COMMON_SCRIPT"
else
    # Fallback minimal definitions if common.sh missing
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m';
    title_screen() { echo "Starting $1..."; }
    fake_loading() { sleep 1; }
fi

# Dependency check (HAS_GUM is set in common.sh usually, but we check again or respect it)
if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}This script works best with 'gum' installed.${RESET}"
    echo -e "${YELLOW}Falling back to standard input, but consider installing gum for a better experience.${RESET}"
    HAS_GUM=false
else
    HAS_GUM=true
fi

# Aesthetics
title_screen "Web App Creator"
fake_loading

# Helper functions
get_input() {
    local prompt="$1"
    local placeholder="$2"
    if [ "$HAS_GUM" = true ]; then
        gum input --header "$prompt" --placeholder "$placeholder"
    else
        read -p "$prompt ($placeholder): " val
        echo "$val"
    fi
}

choose_option() {
    local prompt="$1"
    shift
    if [ "$HAS_GUM" = true ]; then
        gum choose --header "$prompt" "$@"
    else
        echo "$prompt"
        select opt in "$@"; do
            echo "$opt"
            break
        done
    fi
}

# 1. Get App Name
if [ "$HAS_GUM" = true ]; then
    APP_NAME=$(gum input --header "Enter the name of the Web App" --placeholder "e.g. YouTube")
else
    read -p "Enter the name of the Web App: " APP_NAME
fi

if [ -z "$APP_NAME" ]; then
    echo "App name is required."
    exit 1
fi

SANITIZED_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# 2. Get URL
if [ "$HAS_GUM" = true ]; then
    APP_URL=$(gum input --header "Enter the URL" --placeholder "https://www.youtube.com")
else
    read -p "Enter the URL: " APP_URL
fi

if [ -z "$APP_URL" ]; then
    echo "URL is required."
    exit 1
fi

# Ensure URL has protocol
if [[ ! "$APP_URL" =~ ^http ]]; then
    APP_URL="https://$APP_URL"
fi

# 3. Get Icon
ICON_DIR="$HOME/.local/share/icons"
mkdir -p "$ICON_DIR"
ICON_PATH="$ICON_DIR/$SANITIZED_NAME.png"

echo "Select Icon Source:"
if [ "$HAS_GUM" = true ]; then
    ICON_SOURCE=$(gum choose --header "Select Icon Source" "Download from URL" "Local File" "Auto-detect (Default from Service)")
else
    echo "Select Icon Source:"
    select ICON_SOURCE in "Download from URL" "Local File" "Auto-detect (Default from Service)"; do
        break
    done
fi

case "$ICON_SOURCE" in
    "Download from URL")
        if [ "$HAS_GUM" = true ]; then
            ICON_URL=$(gum input --header "Enter Icon URL" --placeholder "https://example.com/logo.png")
        else
            read -p "Enter Icon URL: " ICON_URL
        fi
        curl -L "$ICON_URL" -o "$ICON_PATH"
        ;;
    "Local File")
        if [ "$HAS_GUM" = true ]; then
            # gum file is nice for paths
            LOCAL_ICON=$(gum file --directory "$HOME")
        else
            read -p "Enter path to icon: " LOCAL_ICON
        fi
        cp "$LOCAL_ICON" "$ICON_PATH"
        ;;
    *)
        # Auto-detect using Google Favicon service
        # Extract domain from URL
        DOMAIN=$(echo "$APP_URL" | awk -F/ '{print $3}')
        echo "Fetching icon for $DOMAIN..."
        curl -L "https://www.google.com/s2/favicons?domain=${DOMAIN}&sz=128" -o "$ICON_PATH"
        ;;
esac

# 4. Create Desktop Entry
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_ENTRY_DIR"
DESKTOP_FILE="$DESKTOP_ENTRY_DIR/$SANITIZED_NAME.desktop"

# Browser selection (optional, but good for "App Mode" feel)
# We default to just running the command, but we can try to be smart.
# If firefox, --new-window is good.
# If chromium, --app=URL is better.

BROWSER="firefox"
if command -v google-chrome-stable &> /dev/null; then
    EXEC_CMD="google-chrome-stable --app=$APP_URL"
elif command -v chromium &> /dev/null; then
    EXEC_CMD="chromium --app=$APP_URL"
elif command -v brave &> /dev/null; then
    EXEC_CMD="brave --app=$APP_URL"
else
    # Fallback to firefox or xdg-open
    EXEC_CMD="firefox --new-window $APP_URL"
fi

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=Web App for $APP_NAME
Exec=$EXEC_CMD
Icon=$ICON_PATH
Terminal=false
Categories=Network;WebBrowser;
EOF

# Make it executable just in case
chmod +x "$DESKTOP_FILE"

# Notify
if [ "$HAS_GUM" = true ]; then
    gum style --foreground 212 --border-foreground 212 --border double --align center --width 50 --margin "1 2" --padding "2 4" \
        "Web App Installed!" \
        "" \
        "Name: $APP_NAME" \
        "Launched via: $EXEC_CMD" \
        "Icon: $ICON_PATH" \
        "Desktop File: $DESKTOP_FILE"
else
    echo "--------------------------------"
    echo "Web App Installed!"
    echo "Name: $APP_NAME"
    echo "Desktop File: $DESKTOP_FILE"
    echo "--------------------------------"
fi

# Update desktop database if possible
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_ENTRY_DIR"
fi
