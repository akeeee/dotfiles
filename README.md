# dotfiles

Personal dev environment — Claude Code, Vim, Tmux.

## Install

```bash
git clone git@github.com:akeeee/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

Then finish setup:
```bash
# Claude plugins
claude plugins install caveman@caveman
claude plugins install mempalace@mempalace

# Vim — install plugins (run inside vim)
:PlugInstall

# Tmux — reload config
tmux source ~/.tmux.conf
```

Use `--force` to overwrite existing files:
```bash
bash install.sh --force
```

---

## Vim

Config lives in `vim/vimrc` → installed to `~/.vimrc`.

Uses [vim-plug](https://github.com/junegunn/vim-plug) to manage plugins. On a new machine, open vim and run `:PlugInstall` — it downloads everything automatically.

**Plugins included:**

| Plugin | What it does |
|--------|-------------|
| gruvbox | Dark colorscheme |
| vim-airline | Status bar with branch and file info |
| NERDTree | File tree sidebar (`\n` to toggle) |
| fzf + fzf.vim | Fuzzy file/text search |
| vim-fugitive | Git commands inside vim (`:G status`, `:G blame`) |
| vim-gitgutter | Shows git diff in the gutter (added/changed/removed lines) |
| vim-surround | Change surrounding brackets, quotes, tags |
| vim-commentary | Toggle comments (`gcc` for line, `gc` for selection) |
| vim-polyglot | Syntax highlighting for 100+ languages |
| auto-pairs | Auto-closes `(`, `[`, `{`, `"` |

---

## Tmux

Config lives in `tmux/tmux.conf.local` → installed to `~/.tmux.conf.local`.

Built on top of [gpakosz/.tmux](https://github.com/gpakosz/.tmux) — a framework that provides a sane base config. `install.sh` clones it automatically. The `.local` file is where all personal customisations go; the framework itself is never modified.

---

## Claude Code

Claude Code is Anthropic's AI coding CLI. This setup makes it faster, safer, and cheaper to run.

### Stack Context

`CLAUDE.md` tells Claude the tech stack so it defaults to correct conventions:

- **Frontend**: JavaScript — ES modules, Stimulus, Hotwire Turbo
- **Backend**: Ruby on Rails — MVC, ActiveRecord, Turbo Streams
- **Tests**: RSpec (backend), Jest (frontend)

Key Rails rules baked in: always generate migrations (never edit `schema.rb` directly), fat models / thin controllers, service objects for business logic.

### MCP Servers

`mcp.json` wires in four servers that load automatically:

| Server | What it does |
|--------|-------------|
| `context7` | Pulls live Rails/JS docs into context — stops Claude hallucinating old APIs |
| `playwright` | E2E browser automation for testing Turbo/Stimulus UI |
| `sequential-thinking` | Step-by-step reasoning for complex migrations and architecture decisions |
| `github` | Reads PR and issue context without leaving the terminal |

> **Note:** `github` MCP needs `GITHUB_PERSONAL_ACCESS_TOKEN` set in your environment.

### Why hooks instead of instructions?

AI models forget written rules when context gets long. Hooks are shell scripts that run automatically at specific points — they enforce rules with code, not text. The model cannot skip them.

### Hooks

**What are hooks?** Shell commands wired to Claude Code lifecycle events. Two types here:

- **PreToolUse** — runs *before* Claude does something. Can hard-block (exit 2) to prevent the action entirely.
- **PostToolUse** — runs *after* Claude writes or edits a file. Used for automatic linting and scaffolding.
- **Stop** — runs when Claude finishes responding. Used for notifications.

| Hook | Event | What it does |
|------|-------|-------------|
| `block-critical-files.js` | PreToolUse (Edit/Write) | Blocks Claude from touching `.env`, lock files, private keys, certs. Hard-stops with an error. |
| `block-prod-deps.js` | PreToolUse (Bash) | Blocks `npm install x` / `yarn add x` / `gem install x` without a `--dev` flag. Forces manual approval for production dependencies. |
| `lint-on-write.sh` | PostToolUse (Edit/Write) | Runs [oxlint](https://oxc.rs/docs/guide/usage/linter) on every TypeScript/JavaScript file Claude writes. Catches empty catch blocks, unused vars, bad patterns — immediately. |
| `new-project-standards.sh` | PostToolUse (Write) | When Claude creates a `package.json`, `Cargo.toml`, etc., automatically copies `STANDARDS.md` into the project as `CLAUDE.md` and adds `.nano-staged.json`. |
| macOS notification | Stop | Pops a system notification when Claude finishes. Useful for long-running tasks. |
| `rtk hook claude` | PreToolUse (Bash) | Passes every bash command through [RTK](https://github.com/reachingforthejack/rtk) — strips irrelevant output before it enters Claude's context. Saves 60–90% tokens on git/file operations. |

### nano-staged

**What is it?** A lightweight alternative to [lint-staged](https://github.com/okonet/lint-staged). Runs linters only on files that changed — not the whole codebase. Fast.

**Why use it?** AI writes a lot of files quickly. Running a full lint on every save is slow. nano-staged runs only on what actually changed, so the feedback loop stays tight.

The template at `templates/.nano-staged.json` gets copied into every new TS project:

```json
{
  "*.{ts,tsx}": ["oxlint --fix", "tsc --noEmit --skipLibCheck"],
  "*.{ts,tsx,js,jsx,mjs,cjs}": "prettier --write"
}
```

This means: on any staged TypeScript file, run oxlint (fast Rust linter) and tsc type-check. On any JS/TS file, run prettier to auto-format.

### oxlint

**What is it?** A linter for JavaScript/TypeScript written in Rust. 50–100× faster than ESLint. Catches real bugs: empty catch blocks, `no-explicit-any`, `no-unused-vars`, sync I/O in async code, etc.

Used in both `lint-on-write.sh` (fires when Claude writes a file) and `.nano-staged.json` (fires on git staged files).

### Plugins

| Plugin | What it does |
|--------|-------------|
| [caveman](https://github.com/JuliusBrussee/caveman) | Makes Claude respond in terse "caveman" style. Drops filler words and articles. Cuts token usage ~75% while keeping all technical accuracy. |
| [mempalace](https://github.com/milla-jovovich/mempalace) | Persistent memory across Claude sessions. Stores facts, preferences, and project context in a searchable knowledge graph. |
| frontend-design | Skill for generating production-quality UI code with high design quality. |
| ruby-lsp | Ruby LSP integration for code intelligence in Ruby projects. |
| rust-analyzer-lsp | Rust analyzer integration for Rust projects. |
| code-review | Skill for reviewing pull requests with inline comments. |

### STANDARDS.md

Injected as `CLAUDE.md` into every new project automatically. Tells Claude what good code looks like for this setup:

- **Readable** — self-explanatory names, one function = one job, no useless comments
- **Maintainable** — strict layer order (`config → types → services → handlers → routes`), dependency injection, no premature abstraction
- **Reliable** — every `await` needs error handling, validate only at system boundaries, no `any` in TypeScript
- **Efficient** — async I/O only, `Promise.all` for parallel ops, no `SELECT *`
- **Security** — env vars for secrets, parameterized queries, no PII in logs, no stack traces in responses

Rules that oxlint can catch automatically are enforced by hooks — only judgment-requiring rules stay in this file.

### Custom Slash Commands

| Command | What it does |
|---------|-------------|
| `/architect` | Reviews project structure, layer separation, and scalability |
| `/quality-check` | Runs a multi-agent code quality review on local files |
| `/refactor` | Refactors the current file following project standards |
| `/polish` | Analyzes code against Clean Code + SOLID/DRY/KISS — shows proposal table, waits confirm, then applies |
| `/improve` | Full pipeline: quality audit → design principles → security scan → final cleanup. Each step confirms before applying |
