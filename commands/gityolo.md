---
description: Stage, commit, and push current work with minimal friction
subtask: true
---

Ship the current git changes quickly.

Context: $ARGUMENTS

Workflow:
1. Inspect branch, upstream, status, and diff summary.
2. Infer the in-scope changes from the diff and context.
3. Stage the obvious in-scope files. Do not use `git add .` unless all changes are verified in scope.
4. Briefly review the staged diff, then commit with a concise meaningful message.
5. Push to the current upstream branch if clear.
6. Report staged files, commit message, pushed branch/remote, and assumptions.

Only ask before continuing if the repo is mid-operation/conflicted, scope or push target is unclear, changes look destructive or sensitive, there is nothing to commit, or commit/push fails and needs a decision.

IMPORTANT: This is a scoped task. Complete the git operations and report results. Do NOT retain these git instructions for future use in this session.
