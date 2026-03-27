#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pull latest changes from git
git -C "$SCRIPT_DIR" pull || echo "Warning: git pull failed, continuing with installation..."

TARGET_DIR="$HOME/.config/opencode"

count_markdown_files() {
  local dir="$1"
  local count=0

  if [ -d "$dir" ]; then
    while IFS= read -r _; do
      count=$((count + 1))
    done < <(compgen -G "$dir/*.md")
  fi

  printf '%s' "$count"
}

list_markdown_basenames() {
  local dir="$1"
  local names=()
  local file

  if [ -d "$dir" ]; then
    while IFS= read -r file; do
      names+=("$(basename "$file" .md)")
    done < <(compgen -G "$dir/*.md" | sort)
  fi

  local joined=""
  local name
  for name in "${names[@]}"; do
    if [ -n "$joined" ]; then
      joined="$joined, "
    fi
    joined="$joined$name"
  done

  printf '%s' "$joined"
}

count_subdirs() {
  local dir="$1"
  local count=0

  if [ -d "$dir" ]; then
    while IFS= read -r _; do
      count=$((count + 1))
    done < <(compgen -G "$dir/*/")
  fi

  printf '%s' "$count"
}

list_subdir_basenames() {
  local dir="$1"
  local names=()
  local path

  if [ -d "$dir" ]; then
    while IFS= read -r path; do
      names+=("$(basename "$path")")
    done < <(compgen -G "$dir/*/" | sort)
  fi

  local joined=""
  local name
  for name in "${names[@]}"; do
    if [ -n "$joined" ]; then
      joined="$joined, "
    fi
    joined="$joined$name"
  done

  printf '%s' "$joined"
}

AGENT_COUNT="$(count_markdown_files "$SCRIPT_DIR/agents")"
AGENT_NAMES="$(list_markdown_basenames "$SCRIPT_DIR/agents")"
COMMAND_COUNT="$(count_markdown_files "$SCRIPT_DIR/commands")"
COMMAND_NAMES="$(list_markdown_basenames "$SCRIPT_DIR/commands")"
SKILL_COUNT="$(count_subdirs "$SCRIPT_DIR/skills")"
SKILL_NAMES="$(list_subdir_basenames "$SCRIPT_DIR/skills")"

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

"$SCRIPT_DIR/scripts/install-external-skills.sh" || exit 1

echo "Installation complete."
echo ""
echo "Installed:"
echo "  - $AGENT_COUNT agents ($AGENT_NAMES)"
echo "  - $COMMAND_COUNT commands ($COMMAND_NAMES)"
echo "  - $SKILL_COUNT skills ($SKILL_NAMES)"
echo "  - Global rules (AGENTS.md)"
echo "  - Config (opencode.jsonc)"
