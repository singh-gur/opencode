set shell := ["bash", "-cu"]

# Run `just` with no args to see available recipes.
default:
    just --list

# Install only the external skills declared in `skills-install.json`.
install-skills:
    ./scripts/install-external-skills.sh

# Run the main installer for local config only.
install:
    ./install.sh

# Run both the local installer and external skills installer.
install-all:
    ./install.sh
    ./scripts/install-external-skills.sh
