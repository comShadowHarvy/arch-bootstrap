#!/bin/bash

# This script installs and runs nvim-lazyman.

# Function to print messages
print_message() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

# 1. Clone nvim-lazyman repository
print_message "Cloning nvim-lazyman repository..."
if [ ! -d "$HOME/.config/nvim-Lazyman" ]; then
    git clone https://github.com/doctorfree/nvim-lazyman "$HOME/.config/nvim-Lazyman"
else
    echo "nvim-lazyman repository already exists."
fi

# 2. Run lazyman.sh
print_message "Running lazyman.sh..."
if [ -f "$HOME/.config/nvim-Lazyman/lazyman.sh" ]; then
    "$HOME/.config/nvim-Lazyman/lazyman.sh"
else
    echo "Error: $HOME/.config/nvim-Lazyman/lazyman.sh not found."
    exit 1
fi

print_message "nvim-lazyman installation and setup complete!"
