#!/bin/bash

# Create ~/git directory if it doesn't exist
mkdir -p "$HOME/git"

# Clone betterstrap repository
if [ ! -d "$HOME/git/betterstrap" ]; then
  git clone https://github.com/comShadowHarvy/betterstrap.git "$HOME/git/betterstrap"
fi

# Clone conf repository
if [ ! -d "$HOME/git/conf" ]; then
  git clone https://github.com/comShadowHarvy/conf.git "$HOME/git/conf"
fi
