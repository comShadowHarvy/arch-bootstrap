#!/bin/bash

# This script installs dotfiles using com.ml4w.dotfilesinstaller Flatpak.

# Function to print messages
print_message() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

print_message "Running dotfilesinstaller with hyprland-starter.dotinst..."

# Execute the dotfilesinstaller Flatpak with the specified URL
# Assuming dotfilesinstaller accepts a URL for installation.
# This command might need adjustment if the Flatpak has different argument expectations.
flatpak run com.ml4w.dotfilesinstaller --install-url https://raw.githubusercontent.com/mylinuxforwork/hyprland-starter/main/hyprland-starter.dotinst

print_message "Dotfiles installation process initiated."
