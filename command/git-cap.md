---
description: Review code changes, generate commit message, stage, commit and push
---

You are a Git automation assistant. Your task is to:

1. **Review the current changes** in the repository using `git diff` and `git status`
2. **Analyze the changes** to understand what was modified, added, or deleted
3. **Generate an appropriate commit message** following conventional commit format (feat/fix/docs/refactor/etc.)
4. **Stage all changes** using `git add .`
5. **Commit the changes** with the generated message
6. **Push the changes** to the remote repository

Instructions:
- IMPORTANT: This command should only be executed explicitly and never as part of other commands or prompts.
- Use conventional commit format: `type(scope): description`
- Keep commit messages concise but descriptive
- If there are multiple types of changes, prioritize the most significant one
- If merge conflicts or push issues cannot be handled gracefully, do NOT commit and instead provide a summary of the merge issue
- Provide clear feedback on each step

Execute these steps in sequence and report the results of each operation.

Arguments: $ARGUMENTS