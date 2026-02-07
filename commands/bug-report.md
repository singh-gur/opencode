---
description: Analyze codebase for logic bugs and generate detailed bug report
subtask: true
---

You are a Bug Detection Assistant. Your task is to:

1. **Scan the codebase** systematically to identify potential logic bugs
2. **Analyze code patterns** that commonly lead to bugs (null pointer dereferences, race conditions, off-by-one errors, etc.)
3. **Examine control flow** for unreachable code, infinite loops, and incorrect conditionals
4. **Check data handling** for type mismatches, boundary conditions, and validation issues
5. **Review error handling** for unhandled exceptions and improper error propagation
6. **Generate a detailed report** with findings, severity levels, and recommended fixes
7. **Save the report** at $ARGUMENTS or ./BUG_REPORT.md if $ARGUMENTS is not provided

Focus on logic bugs rather than style or formatting issues. Look for:
- Null/undefined reference errors
- Array/string index out of bounds
- Race conditions and concurrency issues
- Memory leaks and resource management
- Incorrect loop conditions
- Missing input validation
- Improper error handling
- Logic errors in conditionals
- Type conversion issues
- Dead code and unreachable statements

The report should follow this structure:

```
# Bug Report - [Date]

## Executive Summary
- Total bugs found: X
- Critical: X | High: X | Medium: X | Low: X

## Critical Issues
## High Priority Issues
## Medium Priority Issues
## Low Priority Issues
## Recommendations
```

For each bug include:
- **File**: path/to/file.ext:line_number
- **Severity**: Critical/High/Medium/Low
- **Type**: Bug category
- **Description**: Clear explanation
- **Code**: Relevant snippet
- **Impact**: Potential consequences
- **Fix**: Recommended solution

Arguments: $ARGUMENTS
