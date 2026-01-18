#!/bin/bash

# This script sets Zsh as the default shell for the current user.

# Function to print messages
print_message() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

print_message "Setting Zsh as the default shell..."

# Set Zsh as the default shell
sudo chsh -s $(which zsh) $(whoami)

print_message "Zsh is now the default shell. Please log out and log back in for the change to take effect."
