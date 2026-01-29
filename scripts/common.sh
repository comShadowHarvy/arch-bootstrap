#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

# Check for gum
if command -v gum &> /dev/null; then
    HAS_GUM=true
else
    HAS_GUM=false
fi

# Global array to track failed packages
FAILED_PACKAGES=()

# Function to show title screen
title_screen() {
    clear
    local title="$1"
    echo -e "${CYAN}================================================================${RESET}"
    echo -e "${CYAN}   _____                __         ____              __  ${RESET}"
    echo -e "${CYAN}  /  _  \\_______   ____|  |__     /    \\   ____   __| _/ ${RESET}"
    echo -e "${CYAN} /  /_\\  \\_  __ \\_/ ___\\  |  \\   /  |  \\ /  \\ \\ / __ |  ${RESET}"
    echo -e "${CYAN}/    |    \\  | \\/\\  \\___|   Y  \\ /   |   \\    |  / /_/ |  ${RESET}"
    echo -e "${CYAN}\\____|__  /__|    \\___  >___|  / \\___|  / ___  /\\____ |  ${RESET}"
    echo -e "${CYAN}        \\/            \\/     \\/       \\/       \\/      \\/  ${RESET}"
    echo -e "${CYAN}================================================================${RESET}"
    echo -e "${MAGENTA}${BOLD}   $title ${RESET}"
    echo -e "${CYAN}================================================================${RESET}"
    echo ""
}

# Function for fake loading screen (4 seconds)
fake_loading() {
    echo -e "${YELLOW}Loading resources...${RESET}"
    
    if [ "$HAS_GUM" = true ]; then
        gum spin --spinner dot --title "Initializing..." -- sleep 4
    else
        # Fallback spinner
        local pid=$!
        local delay=0.1
        local spinstr='|/-\'
        local count=0
        while [ $count -lt 40 ]; do
            local temp=${spinstr#?}
            printf " [%c]  " "$spinstr"
            local spinstr=$temp${spinstr%"$temp"}
            sleep $delay
            printf "\b\b\b\b\b\b"
            count=$((count + 1))
        done
        printf "    \b\b\b\b"
    fi
    echo -e "${GREEN}Done!${RESET}"
    echo ""
}

# Robust Pacman Installer
install_pacman_packages() {
    local list_file="$1"
    
    if [ ! -f "$list_file" ]; then
        echo -e "${YELLOW}Warning: $list_file not found. Skipping.${RESET}"
        return
    fi
    
    echo -e "${BLUE}Starting Pacman installation...${RESET}"
    
    # Read file line by line
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        # Skip comments and empty lines
        [[ $pkg =~ ^#.* ]] && continue
        [[ -z "$pkg" ]] && continue
        
        echo -e "${CYAN}Installing $pkg...${RESET}"
        if sudo pacman -S --noconfirm "$pkg"; then
            echo -e "${GREEN}Successfully installed $pkg${RESET}"
        else
            echo -e "${RED}Failed to install $pkg${RESET}"
            FAILED_PACKAGES+=("$pkg (pacman)")
        fi
    done < "$list_file"
}

# Robust AUR Installer
install_aur_packages() {
    local list_file="$1"
    
    if [ ! -f "$list_file" ]; then
        echo -e "${YELLOW}Warning: $list_file not found. Skipping.${RESET}"
        return
    fi
    
    # Ensure yay is installed
    if ! command -v yay &> /dev/null; then
        echo -e "${YELLOW}yay not found. Installing yay...${RESET}"
        git clone https://aur.archlinux.org/yay.git
        (cd yay && makepkg -si --noconfirm)
        rm -rf yay
    fi
    
    echo -e "${BLUE}Starting AUR installation...${RESET}"
    
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        [[ $pkg =~ ^#.* ]] && continue
        [[ -z "$pkg" ]] && continue
        
        echo -e "${CYAN}Installing $pkg...${RESET}"
        if yay -S --noconfirm "$pkg"; then
            echo -e "${GREEN}Successfully installed $pkg${RESET}"
        else
            echo -e "${RED}Failed to install $pkg${RESET}"
            FAILED_PACKAGES+=("$pkg (AUR)")
        fi
    done < "$list_file"
}

# Helper for general reporting
report_failures() {
    echo ""
    echo -e "${CYAN}================================================================${RESET}"
    echo -e "${CYAN}   Installation Report ${RESET}"
    echo -e "${CYAN}================================================================${RESET}"
    
    if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
         echo -e "${GREEN}Success! All packages installed correctly.${RESET}"
    else
         echo -e "${RED}The following packages failed to install:${RESET}"
         for pkg in "${FAILED_PACKAGES[@]}"; do
             echo -e "${RED} - $pkg${RESET}"
         done
         echo -e "${YELLOW}The script finished the rest of the tasks despite these failures.${RESET}"
    fi
    echo ""
}
