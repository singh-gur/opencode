#!/bin/bash

echo "Installing opencode config to ~/.config/opencode..."

# Create the directory if it doesn't exist
if [ ! -d ~/.config/opencode ]; then
  mkdir -p ~/.config/opencode
fi

# Copy agents, commands, and config
cp -r agent ~/.config/opencode/
cp -r command ~/.config/opencode/
cp config.json ~/.config/opencode/

echo "Installation complete."