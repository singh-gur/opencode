#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.config/opencode"

echo "Installing opencode config to $TARGET_DIR..."

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy agents, commands, skills, rules, and config
cp -r "$SCRIPT_DIR/agents" "$TARGET_DIR/"
cp -r "$SCRIPT_DIR/commands" "$TARGET_DIR/"
cp -r "$SCRIPT_DIR/skills" "$TARGET_DIR/"
cp "$SCRIPT_DIR/AGENTS.md" "$TARGET_DIR/"
cp "$SCRIPT_DIR/opencode.jsonc" "$TARGET_DIR/"

# Clean up old directory names if they exist from previous installs
if [ -d "$TARGET_DIR/agent" ]; then
  echo "Removing old agent/ directory..."
  rm -rf "$TARGET_DIR/agent"
fi
if [ -d "$TARGET_DIR/command" ]; then
  echo "Removing old command/ directory..."
  rm -rf "$TARGET_DIR/command"
fi

echo "Installation complete."
echo ""
echo "Installed:"
echo "  - 2 agents (senior-engineer, k8s-devops)"
echo "  - 5 commands (git-cap, git-quick, git-safe, bug-report, security-scan)"
echo "  - 3 skills (frontend-dev, security-audit, ai-engineering)"
echo "  - Global rules (AGENTS.md)"
echo "  - Config (opencode.jsonc)"
