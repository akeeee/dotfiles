---
title: Improve
description: Full code improvement pipeline — quality audit, design principles, security scan, then final cleanup
---

Run a full improvement pipeline on $ARGUMENTS (or current file if no arg).

## Step 1 — Quality Audit

Run a thorough review. Find all issues:
- Correctness bugs (logic errors, edge cases, wrong assumptions)
- Code smells (god functions, deep nesting, long parameter lists)
- Reuse opportunities (duplicated logic that can be extracted)
- Efficiency issues (unnecessary loops, redundant computation)

Output findings as a numbered list with file:line and severity (high/medium/low).
Ask: **"Proceed to design principles check? (yes / cancel)"**

## Step 2 — Design Principles (Clean Code first)

Analyze against Clean Code principles:
- **Naming** — intent-revealing names, no abbreviations
- **Small functions** — one thing per function
- **No side effects** — functions do what their name says
- **Pure functions** — avoid unnecessary state mutation
- **No magic numbers/strings** — named constants
- **Error handling** — explicit, not swallowed
- **No dead code** — remove unused variables, functions, imports

Also check if obviously violated:
- **SRP** — one responsibility per class/module
- **DRY** — no duplicated logic
- **KISS** — simplest solution that works
- **YAGNI** — no premature abstractions

Show proposal table:

| # | Principle | Violation | File:Line | Fix | Risk |
|---|-----------|-----------|-----------|-----|------|

Ask: **"Apply these changes? (yes / skip N,M / cancel)"**
Wait for response. Apply only confirmed changes.

## Step 3 — Security Scan

Scan for security issues:
- Injection vulnerabilities (SQL, command, XSS)
- Auth weaknesses
- Hardcoded secrets or credentials
- Missing input validation
- Insecure dependencies

Report findings in CWE-tagged table with file:line and severity.
Ask: **"Apply security fixes? (yes / skip N,M / cancel)"**
Wait for response. Apply only confirmed fixes.

## Step 4 — Final Cleanup

Review all changes made so far. Apply final simplifications:
- Remove any new redundancy introduced during fixes
- Ensure consistent style throughout
- Verify no behavior was changed

## Step 5 — Summary

Report:
- Issues found vs fixed per step
- Principles applied
- Behavior-risk areas — verify these with tests
- Suggested next steps (tests to write, further splits, etc.)
