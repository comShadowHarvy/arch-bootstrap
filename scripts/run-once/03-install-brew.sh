#!/bin/bash

# This script installs and configures Homebrew.

# Function to print messages
print_message() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

# 1. Install Homebrew
print_message "Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# 2. Set permissions
print_message "Setting Homebrew permissions..."
sudo chown -R $(whoami) /opt/brew
chmod u+w /opt/brew

# 3. Configure shell
print_message "Configuring shell for Homebrew..."
echo 'eval "$(/opt/brew/bin/brew shellenv)"' >> ~/.zshrc

# 4. Load Homebrew environment
eval "$(/opt/brew/bin/brew shellenv)"

print_message "Homebrew installation and setup complete!"
