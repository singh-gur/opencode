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

## Security & Sensitive Data

- **Never Access Kubernetes Secrets**: Do not read, fetch, decode, or inspect secrets from Kubernetes clusters using `kubectl` or any other method.
- **Never Access Sensitive Local Data**: Do not read or expose sensitive values from local files or configs, including but not limited to `.env`, `.env.*`, kubeconfig files, system configuration files, credential stores, SSH keys, or cloud auth files.
- **Use User-Provided Values Only**: If a task requires a secret or sensitive value, ask the user to provide a sanitized placeholder instead of retrieving it directly.

## Task Management

- **Use TodoWrite** for complex multi-step tasks (3+ steps) to plan and track progress
- **Immediate Updates**: Mark todos as completed immediately after finishing each task
- **Single Focus**: Only have ONE todo in_progress at a time
- **Skip for Simple Tasks**: Don't use TodoWrite for single straightforward tasks

## Code Quality

- Prefer established patterns and libraries over custom solutions
- Analyze requirements thoroughly before implementing
- Consider edge cases and failure scenarios
- Optimize for readability first, performance when necessary
- Implement comprehensive error handling and logging

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
