#!/bin/bash

# This script automates the setup of an Arch Linux environment.

# Function to print messages
print_message() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

# 1. Install Pacman packages
print_message "Installing Pacman packages..."
if [ -f "packages/pacman.txt" ]; then
    sudo pacman -S --noconfirm - < packages/pacman.txt
else
    echo "packages/pacman.txt not found. Skipping Pacman packages."
fi

# 2. Install yay (AUR helper)
print_message "Installing yay (AUR helper)..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    (cd yay && makepkg -si --noconfirm)
    rm -rf yay
else
    echo "yay is already installed."
fi

# 3. Install AUR packages
print_message "Installing AUR packages..."
if [ -f "packages/aur.txt" ]; then
    yay -S --noconfirm - < packages/aur.txt
else
    echo "packages/aur.txt not found. Skipping AUR packages."
fi

# 4. Install Flatpak packages
print_message "Installing Flatpak packages..."
if [ -f "packages/flatpak.txt" ]; then
    xargs -a packages/flatpak.txt flatpak install --noninteractive flathub
else
    echo "packages/flatpak.txt not found. Skipping Flatpak packages."
fi

# 5. Run one-time scripts
print_message "Running one-time scripts..."
if [ -d "scripts/run-once" ]; then
    for script in scripts/run-once/*.sh; do
        if [ -f "$script" ]; then
            print_message "Running $script..."
            bash "$script"
        fi
    done
else
    echo "scripts/run-once directory not found. Skipping one-time scripts."
fi

print_message "Setup complete!"
