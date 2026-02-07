#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.config/opencode"

echo "Installing opencode config to $TARGET_DIR..."

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Clean up old directory names from previous installs first
if [ -d "$TARGET_DIR/agent" ]; then
  echo "Removing old agent/ directory..."
  rm -rf "$TARGET_DIR/agent"
fi
if [ -d "$TARGET_DIR/command" ]; then
  echo "Removing old command/ directory..."
  rm -rf "$TARGET_DIR/command"
fi

# Copy new agents, commands, skills, rules, and config
cp -r "$SCRIPT_DIR/agents" "$TARGET_DIR/"
cp -r "$SCRIPT_DIR/commands" "$TARGET_DIR/"
cp -r "$SCRIPT_DIR/skills" "$TARGET_DIR/"
cp "$SCRIPT_DIR/AGENTS.md" "$TARGET_DIR/"
cp "$SCRIPT_DIR/opencode.jsonc" "$TARGET_DIR/"

echo "Installation complete."
echo ""
echo "Installed:"
echo "  - 1 agent (senior-engineer)"
echo "  - 5 commands (git-cap, git-quick, git-safe, bug-report, security-scan)"
echo "  - 10 skills (python, golang, rust, k8s-devops, terraform, postgresql, testing-patterns, ai-engineering, frontend-dev, security-audit)"
echo "  - Global rules (AGENTS.md)"
echo "  - Config (opencode.jsonc)"
