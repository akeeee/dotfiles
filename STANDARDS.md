## Code Quality Standards

### Readable
- Names self-explanatory: verbs for functions (`fetchUserBets`, `parseLineMessage`), `is/has/can` prefix for booleans
- One function = one job, ~30 lines max — if you need "and" to describe it, split it
- Never: `data`, `info`, `obj`, `temp`, `x` as names
- Comment only non-obvious WHY — never restate what code does

### Maintainable
- Layer order: `config → types → services → handlers → routes` — never skip or reverse
- Dependency injection — no module-level mutable state, no singletons
- Extract abstraction only after 3rd duplication — not before
- Delete dead code — never comment it out

### Reliable
- Every `await` needs try/catch or `.catch()` — `catch (e) {}` is forbidden
- Validate only at system boundaries (HTTP request body, external APIs, env vars at startup)
- No `any` in TypeScript — use `unknown` for external data, narrow with type guards
- Guard all nullable values before access — never assume optional is present
- Unit test all business logic: calculations, parsers, transformers

### Efficient
- All I/O async — no `readFileSync` etc. in server code
- `Promise.all()` for independent async ops — never serial `await` when parallel is safe
- Fetch only needed columns — no `SELECT *` in production queries
- No abstractions for hypothetical future needs

### Security
- No hardcoded secrets — env vars only
- Parameterize all DB queries — no string concatenation in SQL
- Never log passwords, tokens, or PII
- Never expose stack traces to external responses

### Violations
If forced to violate a standard: state why, mark with `// FIXME:` comment.
