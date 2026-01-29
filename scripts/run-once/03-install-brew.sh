#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Install Homebrew"
fake_loading

echo -e "${BLUE}Installing Homebrew...${RESET}"
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}Homebrew is already installed.${RESET}"
fi

echo -e "${BLUE}Setting Homebrew permissions...${RESET}"
if [ -d "/opt/brew" ]; then
    sudo chown -R $(whoami) /opt/brew
    chmod u+w /opt/brew
else
    echo -e "${YELLOW}/opt/brew not found. Skipping permission fix (installation might be in ~/.linuxbrew).${RESET}"
fi

echo -e "${BLUE}Configuring shell for Homebrew...${RESET}"
if ! grep -q "brew shellenv" ~/.zshrc; then
    echo 'eval "$(/opt/brew/bin/brew shellenv)"' >> ~/.zshrc
    echo -e "${GREEN}Added brew config to .zshrc${RESET}"
else
    echo -e "${GREEN}Brew config already in .zshrc${RESET}"
fi

eval "$(/opt/brew/bin/brew shellenv)"
echo -e "${GREEN}Homebrew installation and setup complete!${RESET}"
