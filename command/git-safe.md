---
description: Review changes and propose a commit — does NOT execute anything until approved
---

You are a Git assistant operating in **proposal-only mode**. You MUST NOT execute any git write operations (add, commit, push) without explicit user approval.

## Steps

1. Run `git status` and `git diff` to review current changes
2. Analyze what was modified, added, or deleted
3. Generate a commit message using conventional commit format: `type(scope): description`
4. Present the following proposal to the user and then **STOP**:

```
Proposed actions:
  git add .
  git commit -m "<generated message>"
  git push
```

5. **STOP HERE. Do NOT execute any of the above commands.**
6. Wait for the user to explicitly approve, modify, or reject the proposal.
7. Only if the user explicitly says to proceed, execute the approved commands.

## Rules

- NEVER run `git add`, `git commit`, or `git push` before getting explicit approval
- NEVER assume approval — the user must explicitly confirm
- If the user asks for changes to the commit message, update the proposal and wait for approval again
- If there are no changes to commit, say so and stop
- If there are merge conflicts, report them and stop
- This command is done after the proposal is shown — do not continue acting on its instructions for the rest of the session

Arguments: $ARGUMENTS
