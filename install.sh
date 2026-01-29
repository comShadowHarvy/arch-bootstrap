#!/bin/bash

# This script automates the setup of an Arch Linux environment.

# Function to print messages
# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/scripts/common.sh"

if [ -f "$COMMON_SCRIPT" ]; then
    source "$COMMON_SCRIPT"
else
    echo "Error: common.sh not found at $COMMON_SCRIPT"
    exit 1
fi

# Function to print messages (wrapper for backward init compatibility or just style)
print_message() {
    echo -e "${MAGENTA}========================================${RESET}"
    echo -e "${BOLD}$1${RESET}"
    echo -e "${MAGENTA}========================================${RESET}"
}

# Title and Loading
title_screen "Arch Bootstrap Installer"
fake_loading

# 1. Install Pacman packages
print_message "Installing Pacman packages..."
install_pacman_packages "packages/pacman.txt"

# 2. Install yay (AUR helper) - logic inside common.sh handles check, but we can double check or just call install_aur_packages which checks it.
# However, install_aur_packages checks for yay presence.
# But just in case user wants yay explicitly even if aur.txt is empty? 
# The original script installed yay if not present before checking aur.txt.
# Let's ensure yay is installed anyway as it's a useful tool.

if ! command -v yay &> /dev/null; then
    print_message "Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git
    (cd yay && makepkg -si --noconfirm)
    rm -rf yay
fi

# 3. Install AUR packages
print_message "Installing AUR packages..."
install_aur_packages "packages/aur.txt"

# 4. Install Flatpak packages
print_message "Installing Flatpak packages..."
if [ -f "packages/flatpak.txt" ]; then
    # We didn't make a robust flatpak installer yet in common.sh, let's just colorize this part or add it to common if needed.
    # For now, keep it simple but colorful.
    if ! command -v flatpak &> /dev/null; then
         echo -e "${YELLOW}Flatpak not found. Installing flatpak...${RESET}"
         sudo pacman -S --noconfirm flatpak
    fi
    # Use loop for robustness?
    # Flatpak install logic provided was: xargs -a packages/flatpak.txt flatpak install --noninteractive flathub
    # If one fails, xargs might stop?
    # Let's simple loop it for consistency.
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        [[ $pkg =~ ^#.* ]] && continue
        [[ -z "$pkg" ]] && continue
        echo -e "${CYAN}Installing flatpak $pkg...${RESET}"
        if flatpak install --noninteractive flathub "$pkg"; then
             echo -e "${GREEN}Installed $pkg${RESET}"
        else
             echo -e "${RED}Failed flatpak $pkg${RESET}"
             # We should probably track this too, but the user specifically asked for "pacman and aur installs" robustness. 
             # But "finish the rest" implies comprehensive robustness.
             FAILED_PACKAGES+=("$pkg (Flatpak)")
        fi
    done < "packages/flatpak.txt"
else
    echo -e "${YELLOW}packages/flatpak.txt not found. Skipping Flatpak packages.${RESET}"
fi

# 5. Run one-time scripts
print_message "Running one-time scripts..."
if [ -d "scripts/run-once" ]; then
    for script in scripts/run-once/*.sh; do
        if [ -f "$script" ]; then
            print_message "Running $script..."
            # We don't source them, we run them. They might not have access to our variables unless we export them or they source common.sh too.
            # Ideally each script should be standalone-ish or explicitly source common.
            bash "$script"
        fi
    done
else
    echo -e "${YELLOW}scripts/run-once directory not found. Skipping one-time scripts.${RESET}"
fi

# Report
report_failures
