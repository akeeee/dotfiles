---
title: Polish
description: Analyze code against Clean Code principles, propose improvements with rationale, then refactor
---

Perform a principled code review and refactor on $ARGUMENTS (or current file if no arg).

## Step 1 — Analyze

Read the code thoroughly. Always check **Clean Code** principles first:
- **Naming** — do names reveal intent? No abbreviations, no misleading names
- **Small functions** — does each function do exactly one thing?
- **No side effects** — functions should do what their name says, nothing hidden
- **Pure functions** — avoid mutating state where not needed
- **No magic numbers/strings** — extract to named constants
- **Error handling** — errors handled explicitly, not swallowed
- **No dead code** — unused variables, functions, imports

Also check these if violations are obvious:
- **SRP** — one class/module owns one responsibility
- **DRY** — no duplicated logic
- **KISS** — simplest solution that works
- **YAGNI** — no unused abstractions or premature generalization

## Step 2 — Propose

Before changing anything, output a proposal table:

| # | Principle | Violation Found | File:Line | Proposed Fix | Risk |
|---|-----------|----------------|-----------|--------------|------|
| 1 | Naming | `d` used as date variable | `user.js:12` | Rename to `createdAt` | None |
| 2 | SRP | `saveUser` also sends email | `user.js:45` | Extract `sendWelcomeEmail` | Low |

Then state: **"Apply these changes? Reply: yes / skip N,M / cancel"**

Wait for user response before making any changes.

## Step 3 — Apply

Apply only confirmed changes:
- State which principle each change enforces
- Do NOT change behavior — structure and clarity only
- Do NOT add features or abstractions not needed now

## Step 4 — Summary

Report:
- Principles applied and where
- Behavior-risk areas to verify with tests
- Suggested next steps
