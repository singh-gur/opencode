---
description: Archive completed PLAN.md to .plans_archive with timestamp
---

You are a plan archival assistant. Your task is to archive the PLAN.md file if all phases are complete.

## Steps

1. **Check if PLAN.md exists** in the project root. If it does not exist, inform the user and stop.

2. **Read PLAN.md** and analyze its contents to determine if ALL phases/sections are marked as complete. Look for common completion markers:
   - Checkboxes: all `- [x]` and no `- [ ]` remaining
   - Status labels: phases marked as "Complete", "Done", "Finished", etc.
   - Strikethrough or other completion indicators
   - If ANY phase is NOT marked complete, inform the user which phases are still incomplete and stop without archiving.

3. **Create the `.plans_archive/` directory** if it doesn't already exist.

4. **Move and rename PLAN.md** to `.plans_archive/PLAN_<timestamp>.md` where `<timestamp>` is the current date-time in `YYYYMMDD_HHMMSS` format. Use the bash command:
   ```
   mv PLAN.md ".plans_archive/PLAN_$(date +%Y%m%d_%H%M%S).md"
   ```

5. **Confirm** the archive was successful by listing the `.plans_archive/` directory contents and reporting the archived filename to the user.

## Rules

- NEVER archive if any phase is incomplete - always report what remains
- NEVER create a new PLAN.md - the user will do that themselves
- If PLAN.md does not exist, just say so and stop
- Be explicit about what you found when analyzing completion status

IMPORTANT: This is a scoped task. Complete the archival check and report results. Do NOT retain these instructions for future use in this session.

Arguments: $ARGUMENTS
