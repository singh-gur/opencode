#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_CONFIG_FILE="$ROOT_DIR/skills-install.json"

EXTERNAL_SKILL_ATTEMPTED=0
EXTERNAL_SKILL_INSTALLED=0
EXTERNAL_SKILL_FAILED=0

install_configured_skills() {
  if [ ! -f "$SKILLS_CONFIG_FILE" ]; then
    echo "No external skills config found at $SKILLS_CONFIG_FILE, skipping skills.sh installs."
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "Warning: jq is not installed; skipping external skills. Install jq to enable $SKILLS_CONFIG_FILE."
    return 0
  fi

  local skill_entries
  if ! skill_entries="$(jq -r '
    if type != "object" then
      error("skills-install.json must contain a JSON object")
    else
      to_entries[]?
      | .key as $url
      | if (.value | type) != "array" then
          error("Expected an array of skills for \($url)")
        else
          .value[]?
          | if type != "string" then
              error("Invalid skill name for \($url)")
            else
              . as $skill
              | ($skill | gsub("^\\s+|\\s+$"; "")) as $trimmed_skill
              | if ($trimmed_skill | length) == 0 then
                  error("Invalid skill name for \($url)")
                else
                  "\($url)\t\($trimmed_skill)"
                end
            end
        end
    end
  ' "$SKILLS_CONFIG_FILE")"; then
    echo "Error: failed to parse $SKILLS_CONFIG_FILE."
    return 1
  fi

  if [ -z "$skill_entries" ]; then
    echo "No external skills configured in $SKILLS_CONFIG_FILE."
    return 0
  fi

  echo "Installing configured skills from $SKILLS_CONFIG_FILE..."

  while IFS=$'\t' read -r repo_url skill_name; do
    [ -n "$repo_url" ] || continue

    EXTERNAL_SKILL_ATTEMPTED=$((EXTERNAL_SKILL_ATTEMPTED + 1))
    echo "Installing external skill '$skill_name' from $repo_url..."

    if npx skills add "$repo_url" --skill "$skill_name" -g --agent opencode -y </dev/null; then
      EXTERNAL_SKILL_INSTALLED=$((EXTERNAL_SKILL_INSTALLED + 1))
    else
      EXTERNAL_SKILL_FAILED=$((EXTERNAL_SKILL_FAILED + 1))
      echo "Warning: failed to install '$skill_name' from $repo_url, continuing..."
    fi
  done <<< "$skill_entries"

  echo "External skills installed: $EXTERNAL_SKILL_INSTALLED/$EXTERNAL_SKILL_ATTEMPTED"
  if [ "$EXTERNAL_SKILL_FAILED" -gt 0 ]; then
    echo "External skill installs failed: $EXTERNAL_SKILL_FAILED"
  fi
}

install_configured_skills
