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
