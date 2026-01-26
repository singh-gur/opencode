#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing opencode config to ~/.config/opencode..."

# Create the directory if it doesn't exist
if [ ! -d ~/.config/opencode ]; then
  mkdir -p ~/.config/opencode
fi

# Copy agents, commands, and config
cp -r "$SCRIPT_DIR/agent" ~/.config/opencode/
cp -r "$SCRIPT_DIR/command" ~/.config/opencode/
cp "$SCRIPT_DIR/opencode.jsonc" ~/.config/opencode/

echo "Installation complete."
