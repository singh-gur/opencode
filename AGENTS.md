# Global Rules

These rules apply to all agents and sessions.

## Communication Style

- **Concise & Professional**: Keep responses short and to the point - this is a CLI interface
- **No Emojis**: Only use emojis if explicitly requested
- **Code References**: Use `file_path:line_number` format when referencing code (e.g., `src/main.py:78`)
- **Direct Output**: Communicate directly to the user; never use bash echo or comments for communication
- **Markdown**: Use Github-flavored markdown for formatting
- **No Unnecessary Files**: Never create documentation files (*.md, README, etc.) unless explicitly requested

## Tool Usage

- **Use Opencode-Native Tools First**: Prefer opencode tools over shell workarounds whenever the needed tool is available
- **Parallel Calls**: When making multiple independent tool calls, invoke them in parallel in a single message
- **Sequential Only When Needed**: Chain bash commands with `&&` only when operations depend on each other
- **Prefer Specialized Tools**:
  - Read instead of cat/head/tail
  - Edit instead of sed/awk
  - Write instead of echo/cat heredoc
  - Glob instead of find/ls
  - Grep instead of grep/rg
- **Task Tool**: For complex exploration or multi-step research, delegate to the Task tool with an appropriate subagent
- **Read Before Modify**: Always read files before editing or overwriting them
- **Use Edit for Precise Changes**: Prefer targeted edits for existing files and keep replacements minimal
- **Use Write Only for New Files or Full Rewrites**: Do not use write for small in-place changes
- **Batch Related Edits**: When changing multiple separate locations in one file, prefer one edit operation with multiple replacements

## Security & Sensitive Data

- **Never Access Kubernetes Secrets**: Do not read, fetch, decode, or inspect secrets from Kubernetes clusters using `kubectl` or any other method.
- **Never Access Sensitive Local Data**: Do not read or expose sensitive values from local files or configs, including but not limited to `.env`, `.env.*`, kubeconfig files, system configuration files, credential stores, SSH keys, or cloud auth files.
- **Use User-Provided Values Only**: If a task requires a secret or sensitive value, ask the user to provide a sanitized placeholder instead of retrieving it directly.

## Task Management

- **Use TodoWrite** for complex multi-step tasks (3+ steps) to plan and track progress when available
- **Immediate Updates**: Mark todos as completed immediately after finishing each task
- **Single Focus**: Only have ONE todo in_progress at a time
- **Skip for Simple Tasks**: Don't use TodoWrite for single straightforward tasks
- For complex multi-step tasks, keep a clear internal plan and execute methodically
- Give concise progress updates during longer tasks

## Project Automation

- Prefer adding a `justfile` to repositories or projects where it can provide useful, repeatable workflows
- When creating a `justfile`, include usage details for tasks and add a default task that lists available `just` tasks

## Dependency Management

- Use the project's package manager to add, update, or remove dependencies instead of editing manifest files directly
- For Python projects, prefer commands like `uv add`, `uv remove`, or the project's configured dependency workflow rather than manually editing `pyproject.toml`
- For Node.js projects, prefer commands like `pnpm add`, `pnpm remove`, `npm install`, or `yarn add` according to the project's existing lockfile and tooling rather than manually editing `package.json`
- Preserve and update lockfiles through the package manager so dependency versions stay resolved and reproducible
- Only edit dependency manifest files directly when the package manager cannot express the needed change, and explain why

## Documentation & Usage Accuracy

- When building with or advising on specs, interfaces, CLI tools, APIs, frameworks, or libraries, verify expected usage against available documentation, schemas, source definitions, or built-in help text before making assumptions
- Prefer project-local docs and installed version help first, then official upstream documentation when local sources are insufficient
- When exact behavior is uncertain or docs are unavailable, state the uncertainty, ask the user for clarification or source material when needed, and avoid presenting guesses as facts

## Code Quality

- Prefer established patterns and libraries over custom solutions
- Analyze requirements thoroughly before implementing
- Consider edge cases and failure scenarios
- Optimize for readability first, performance when necessary
- Implement comprehensive error handling and logging
- Preserve existing style unless asked to refactor

## Bug Fixes

- When working on bug fixes, focus only on fixing the reported bug and keep changes limited to the smallest safe scope
- Avoid broad rewrites, unrelated refactors, or opportunistic cleanup while fixing bugs
- If a larger rewrite or wider change is absolutely necessary to fix the bug, explain why, outline the intended changes, and ask the user for approval before proceeding

## Repo-Scoped AGENTS Sync

- If working inside another repository that has its own repo-scoped `AGENTS.md`, treat that file as part of the maintained codebase and keep it aligned with meaningful workflow, policy, command, tooling, or expectation changes made during the session.
- Check whether the repo-scoped `AGENTS.md` should change whenever your work introduces or finalizes:
  - new or renamed workflows, scripts, commands, agents, or skills
  - changed build, test, lint, deploy, or review expectations
  - updated safety, approval, security, or environment handling rules
  - new repository conventions that future agents should follow
- When user-approved changes are finalized, update the repo-scoped `AGENTS.md` in the same unit of work if the instructions would otherwise become stale, misleading, or incomplete.
- Prefer updating the repo-scoped `AGENTS.md` before wrapping up the task, rather than leaving follow-up documentation drift for later.
- Treat repo-scoped `AGENTS.md` updates like normal documentation edits: read before modifying, keep changes minimal, preserve the file's structure and tone, and do not change unrelated guidance.
- Do not make speculative policy edits. Only document behavior, constraints, and workflows that are actually present in the repository after the finalized changes.
- If no repo-scoped `AGENTS.md` exists, do not create one unless the user explicitly asks for it.
