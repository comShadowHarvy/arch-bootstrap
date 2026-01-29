#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Clone Personal Repos"
fake_loading

echo -e "${BLUE}Creating ~/git directory...${RESET}"
mkdir -p "$HOME/git"

if [ ! -d "$HOME/git/betterstrap" ]; then
  echo -e "${YELLOW}Cloning betterstrap...${RESET}"
  git clone https://github.com/comShadowHarvy/betterstrap.git "$HOME/git/betterstrap"
else
  echo -e "${GREEN}betterstrap already exists.${RESET}"
fi

if [ ! -d "$HOME/git/conf" ]; then
  echo -e "${YELLOW}Cloning conf...${RESET}"
  git clone https://github.com/comShadowHarvy/conf.git "$HOME/git/conf"
else
  echo -e "${GREEN}conf already exists.${RESET}"
fi
