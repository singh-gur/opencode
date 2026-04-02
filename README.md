# opencode

Personal `opencode` configuration bundle for installing custom agents, slash commands, skills, and base config into `~/.config/opencode`.

This repository is not an application in the usual sense. It is a curated config pack for an `opencode` CLI setup, with an installer that syncs local assets and optionally installs a small set of external skills.

## What This Repo Contains

- **Global rules** in `AGENTS.md` for communication style, tool usage, security constraints, task management, and code quality expectations.
- **Primary agents** in `agents/`:
  - `ask` - read-only exploration and reasoning agent
  - `super-plan` - planning-only agent that writes phase-based implementation plans
- **Reusable commands** in `commands/` for plan review/archive, git workflows, bug reporting, security scanning, and repo-to-prompt generation.
- **Local skills** in `skills/` for domain-specific engineering help:
  - `ai-engineering`
  - `frontend-dev`
  - `golang`
  - `k8s-devops`
  - `postgresql`
  - `python`
  - `rust`
  - `security-audit`
  - `terraform`
  - `testing-patterns`
- **Core opencode config** in `opencode.jsonc`, including plugin declarations and disabled-by-default MCP server entries.
- **Install automation** via `install.sh`, `scripts/install-external-skills.sh`, and `justfile`.

## How It Works

Running the installer copies this repo's local config into your user config directory:

- `agents/` -> `~/.config/opencode/agents`
- `commands/` -> `~/.config/opencode/commands`
- `skills/` -> `~/.config/opencode/skills`
- `AGENTS.md` -> `~/.config/opencode/AGENTS.md`
- `opencode.jsonc` -> `~/.config/opencode/opencode.jsonc`

It also removes legacy install paths if they exist:

- `~/.config/opencode/agent`
- `~/.config/opencode/command`

After copying local files, the installer runs `scripts/install-external-skills.sh`, which reads `skills-install.json` and installs configured external skills with `npx skills add ... -g --agent opencode -y`.

## Repository Layout

```text
.
|- AGENTS.md
|- README.md
|- install.sh
|- justfile
|- opencode.jsonc
|- skills-install.json
|- agents/
|- commands/
|- skills/
`- scripts/
```

## Included Agents

### `agents/ask.md`

Read-only assistant intended for:

- codebase exploration
- architecture explanation
- reasoning through implementation ideas
- clarifying ambiguous requests before deeper analysis

It explicitly denies file edits and bash usage.

### `agents/super-plan.md`

Planning-focused assistant intended for larger implementation efforts. It:

- explores the repo before planning
- asks the user to choose a git phase strategy for git repositories
- writes exactly one plan file
- structures work into atomic, verifiable phases
- keeps phases user-gated until reviewed and confirmed complete

## Included Commands

The `commands/` directory provides focused slash-command style workflows:

- `archive-plan.md` - archive `PLAN.md` into `.plans_archive/` only when everything is complete
- `bug-report.md` - scan a codebase for likely logic bugs and write a report
- `clone-prompt.md` - analyze a repo and generate prompts for building a similar project
- `git-cap.md` - full git review, commit, and push flow
- `git-quick.md` - lightweight low-token git commit/push flow
- `git-safe.md` - proposal-only git flow that waits for approval before writes
- `plan-progress.md` - compare repo state against an implementation plan
- `security-scan.md` - structured security review workflow

## Included Local Skills

Each local skill is a reusable domain guide that can be loaded on demand:

- `skills/ai-engineering/SKILL.md` - agentic systems, LangChain, LangGraph, RAG, observability, and production AI patterns
- `skills/frontend-dev/SKILL.md` - React/Vue, CSS, performance, testing, and accessibility
- `skills/golang/SKILL.md` - idiomatic Go structure, errors, interfaces, concurrency, and testing
- `skills/k8s-devops/SKILL.md` - Kubernetes, Helm, GitOps, chart design, and troubleshooting
- `skills/postgresql/SKILL.md` - query tuning, indexing, schema design, and Alembic-safe migrations
- `skills/python/SKILL.md` - modern Python stack, FastAPI, SQLAlchemy, async, and type safety
- `skills/rust/SKILL.md` - ownership, error handling, idioms, and production Rust patterns
- `skills/security-audit/SKILL.md` - vulnerability classes, severity guidance, and remediation structure
- `skills/terraform/SKILL.md` - Terraform/OpenTofu modules, state, validation, and IaC practices
- `skills/testing-patterns/SKILL.md` - pytest and Go testing patterns, fixtures, mocks, async, and property testing

## External Skills

`skills-install.json` declares extra skills to pull from external repositories:

- `frontend-design` from `https://github.com/anthropics/skills`
- `find-skills` from `https://github.com/vercel-labs/skills`
- `agent-browser` from `https://github.com/vercel-labs/agent-browser`

These are not stored in this repo directly. They are installed during setup if the required tooling is available.

## Configuration Details

`opencode.jsonc` currently defines:

- plugins:
  - `opencode-gemini-auth`
  - `opencode-anthropic-auth`
  - `opencode-openai-codex-auth`
  - `opencode-ignore`
- disabled local MCP entries for:
  - Alpha Vantage via `uvx av-mcp`
  - Playwright via `npx @playwright/mcp@latest`
  - `helm-package-readme-mcp-server`
  - `uvx pypi-query-mcp-server`

Some MCP entries expect environment variables when enabled, including:

- `ALPHA_VANTAGE_API_KEY`
- `GITHUB_TOKEN`

## Requirements

Required or effectively required for the full install flow:

- `bash`
- `git`
- `cp`, `mkdir`, and standard Unix utilities
- `npx`

Optional but recommended:

- `just` - convenient task runner for the repo
- `jq` - required for parsing `skills-install.json`; if missing, external skill installation is skipped with a warning

## Installation

### Quick Start

```bash
just install
```

If you do not use `just`:

```bash
./install.sh
```

### Install Only External Skills

```bash
just install-skills
```

or:

```bash
./scripts/install-external-skills.sh
```

## Available `just` Recipes

The repository currently exposes:

```text
default
install
install-skills
```

## Installer Behavior

`install.sh` performs these steps:

1. Resolves the repository root from the script location.
2. Attempts `git pull` to refresh the checkout, but continues if pull fails.
3. Counts local agents, commands, and skills so it can print an install summary.
4. Creates `~/.config/opencode` if needed.
5. Removes old `agent/` and `command/` directories from earlier layouts.
6. Copies local config assets into `~/.config/opencode`.
7. Runs external skill installation.
8. Prints a concise summary of what was installed.

## Development Notes

- This repo is mostly content-driven; changes are usually edits to markdown prompts or config.
- The install scripts are written defensively and continue through some non-fatal failures, especially around optional external skill installation.
- Recent commit history suggests the repo evolves around install improvements and agent/command prompt refinements rather than compiled application code.

## Customization

Common ways to adapt this repo for your own setup:

- edit `AGENTS.md` to change global behavior rules
- add or remove prompts in `agents/` and `commands/`
- add new local skills under `skills/<name>/SKILL.md`
- change plugin and MCP settings in `opencode.jsonc`
- update `skills-install.json` to manage which external skills are installed

If you rename directories or add new top-level config assets, update `install.sh` so they are copied during installation.

## Troubleshooting

### External skills are not installing

Check the following:

- `jq` is installed
- `npx` is available
- the configured skill repositories are reachable
- the `skills` CLI invoked by `npx skills add ...` works in your environment

The script will continue on individual skill failures and report how many installs succeeded.

### My local config did not update

Re-run:

```bash
./install.sh
```

Then verify the copied files under `~/.config/opencode` match the repository contents.

### The installer removed old directories

That is expected. The installer intentionally cleans up deprecated `agent/` and `command/` directories before copying the current `agents/` and `commands/` layout.

## Who This Is For

This repository is best suited for someone who:

- uses `opencode` regularly
- wants repeatable personal agent/command/skill setup
- prefers prompt-driven workflows for planning, review, git, and codebase analysis
- wants a mix of local skill content plus curated externally installed skills
