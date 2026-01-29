#!/bin/bash

# Corporate WiFi Connection Script
# Uses nmcli to connect to WPA2-Enterprise networks

set -e

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

title_screen "Corporate WiFi Connector"
fake_loading

set -e

echo -e "${BLUE}Scanning for available networks...${RESET}"
nmcli device wifi rescan
nmcli device wifi list

read -p "Enter the SSID (WiFi Name): " SSID
read -p "Enter Identity (Username): " IDENTITY
read -p "Enter Anonymous Identity (optional, press Enter to skip): " ANON_IDENTITY
read -s -p "Enter Password: " PASSWORD
echo ""

if [ -z "$ANON_IDENTITY" ]; then
    ANON_IDENTITY="$IDENTITY"
fi

echo -e "${YELLOW}Connecting to $SSID...${RESET}"

# Delete existing connection if it exists to avoid conflicts/duplicates
if nmcli connection show "$SSID" >/dev/null 2>&1; then
    echo -e "${YELLOW}Referenced connection already exists. Deleting...${RESET}"
    nmcli connection delete "$SSID"
fi

# Add the new connection
# Note: 802-1x.phase2-auth is typically set to mschapv2 for corporate networks (PEAP)
nmcli connection add \
    type wifi \
    con-name "$SSID" \
    ifname wlan0 \
    ssid "$SSID" \
    wifi-sec.key-mgmt wpa-eap \
    802-1x.eap peap \
    802-1x.phase2-auth mschapv2 \
    802-1x.identity "$IDENTITY" \
    802-1x.anonymous-identity "$ANON_IDENTITY" \
    802-1x.password "$PASSWORD"

# Connect
nmcli connection up "$SSID"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully connected to $SSID!${RESET}"
else
    echo -e "${RED}Failed to connect. Please check your credentials and try again.${RESET}"
    # Optional: cleanup failed connection
    # nmcli connection delete "$SSID"
fi
