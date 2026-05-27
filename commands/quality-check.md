---
description: Multi-agent code quality review for local files or directories
allowed-tools: Bash(git diff *), Bash(git log *), Bash(git blame *), Bash(find *), Read, Glob, Grep
---

Review the code quality of the target path provided as argument. If no argument, review files changed in the current git branch vs main. 

Follow these steps:

1. Determine the target:
   - If argument provided: use that file or directory
   - If no argument: run `git diff main...HEAD --name-only` to get changed files

2. Read the relevant CLAUDE.md files (root + any in target directories) to understand project standards.

3. Launch 4 parallel Sonnet agents to independently audit the target code:

   **Agent 1 — Bug Detector**
   Read the target files and scan for:
   - Null/undefined dereferences
   - Off-by-one errors
   - Race conditions or async mistakes
   - Unhandled error paths
   - Incorrect logic or wrong conditions
   Return: list of bugs with file:line and severity (critical/high/medium)

   **Agent 2 — Standards Checker**
   Read the target files and the CLAUDE.md files. Check for:
   - Violations of CLAUDE.md conventions
   - Security anti-patterns (hardcoded secrets, SQL injection, XSS, missing input validation)
   - Architecture violations (global state, wrong layer dependencies, missing DI)
   Return: list of violations with file:line and which standard was violated

   **Agent 3 — Code Smell Detector**
   Read the target files and scan for:
   - Functions doing more than one thing
   - Deeply nested logic (>3 levels)
   - Magic numbers/strings without constants
   - Duplicate logic that should be extracted
   - Dead code
   Return: list of smells with file:line and suggested fix

   **Agent 4 — Test Coverage Auditor**
   Read the target files and any co-located test files. Check:
   - Business logic with no tests
   - Edge cases not covered
   - Error paths not tested
   Return: list of untested paths with file:line

4. For each finding from all agents, score confidence 0-100:
   - 80+: Report it
   - <80: Drop it (false positive / nitpick)

5. Output a single consolidated report grouped by severity:

```
## Quality Report: <target>

### Critical
- file:line — problem. fix.

### High  
- file:line — problem. fix.

### Medium
- file:line — problem. fix.

### Info
- file:line — problem. fix.

---
X issues found across 4 agents. (Y filtered as low-confidence)
```

Rules:
- One line per issue: `file:line — problem. fix.`
- No praise, no summaries of what the code does correctly
- No issues a linter/typechecker would catch
- No pre-existing issues if reviewing a diff
- If zero issues ≥80 confidence: output "No high-confidence issues found."
