#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMON_SCRIPT="$SCRIPT_DIR/../../scripts/common.sh"
[ -f "$COMMON_SCRIPT" ] && source "$COMMON_SCRIPT"

title_screen "Restore Stow Configs"
fake_loading

if [ -f "$HOME/git/conf/restore-stow.sh" ]; then
  echo -e "${BLUE}Running restore-stow.sh...${RESET}"
  "$HOME/git/conf/restore-stow.sh" --no-backup
else
  echo -e "${RED}Error: ~/git/conf/restore-stow.sh not found.${RESET}"
  exit 1
fi
