#!/bin/bash

# Run restore-stow.sh from the cloned conf repository
if [ -f "$HOME/git/conf/restore-stow.sh" ]; then
  "$HOME/git/conf/restore-stow.sh" --no-backup
else
  echo "Error: ~/git/conf/restore-stow.sh not found."
  exit 1
fi
