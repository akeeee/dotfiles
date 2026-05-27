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

# Vim plugins (inside vim)
:PlugInstall

# Tmux — reload config
tmux source ~/.tmux.conf
```

Use `--force` to overwrite existing files:
```bash
bash install.sh --force
```

---

## Structure

```
~/dotfiles/
├── vim/
│   └── vimrc              → ~/.vimrc (vim-plug, gruvbox, NERDTree, fzf, fugitive)
├── tmux/
│   └── tmux.conf.local    → ~/.tmux.conf.local (gpakosz/.tmux customisations)
└── claude/                (installed to ~/.claude)
    ├── settings.json          # Hook wiring, plugins, theme
├── CLAUDE.md              # Global Claude instructions (points to RTK.md)
├── STANDARDS.md           # Code quality standards injected into new projects
├── RTK.md                 # RTK token proxy documentation
├── hooks/
│   ├── block-critical-files.js   # PreToolUse — blocks edits to .env, lock files, keys
│   ├── block-prod-deps.js        # PreToolUse — blocks prod npm/gem installs
│   ├── lint-on-write.sh          # PostToolUse — runs oxlint on every TS/JS file Claude writes
│   ├── new-project-standards.sh  # PostToolUse — scaffolds CLAUDE.md + .nano-staged.json on new projects
│   └── [caveman plugin hooks]    # Installed by caveman plugin, not committed
├── commands/
│   ├── architect.md       # /architect slash command
│   ├── quality-check.md   # /quality-check slash command
│   └── refactor.md        # /refactor slash command
└── templates/
    └── .nano-staged.json  # Default linter config for new TS projects
```

---

## Hooks

### Security / Safety (PreToolUse — hard blocks, exit 2)

| Hook | Trigger | Blocks |
|------|---------|--------|
| `block-critical-files.js` | Edit or Write | `.env`, `*.lock`, `master.key`, certs |
| `block-prod-deps.js` | Bash | `npm install x`, `yarn add x`, `gem install x` without `-D`/`--dev` |

Both exit code 2 = Claude Code hard-stops and shows the error message.

### Quality (PostToolUse — feedback, no block)

| Hook | Trigger | Does |
|------|---------|------|
| `lint-on-write.sh` | Write or Edit on `*.ts`, `*.tsx`, `*.js` | Runs `oxlint --fix` on the file |
| `new-project-standards.sh` | Write on `package.json`, `Cargo.toml`, etc. | Copies `STANDARDS.md` → `CLAUDE.md`, `.nano-staged.json` into new project |

### Notifications (Stop)

macOS notification when Claude finishes a task. Useful for long-running sessions.

### Token proxy (PreToolUse/Bash)

All Bash commands pass through `rtk hook claude` — the RTK proxy strips irrelevant output before it hits Claude's context. Saves 60–90% tokens on git/file operations.

---

## Plugins

| Plugin | What it does |
|--------|-------------|
| [caveman](https://github.com/JuliusBrussee/caveman) | Caveman mode — terse responses, ~75% token reduction |
| [mempalace](https://github.com/milla-jovovich/mempalace) | Persistent semantic memory palace across sessions |
| frontend-design | Production-grade UI generation |
| ruby-lsp | Ruby LSP integration |
| rust-analyzer-lsp | Rust analyzer integration |
| code-review | PR review skill |

---

## Per-project setup

When Claude writes a `package.json` in a new project, `new-project-standards.sh` automatically:
1. Creates `CLAUDE.md` from `STANDARDS.md`
2. Creates `.nano-staged.json` for oxlint + prettier on staged TS files

To add to an existing project manually:
```bash
cp ~/.claude/STANDARDS.md ./CLAUDE.md
cp ~/.claude/templates/.nano-staged.json ./.nano-staged.json
```

---

## Code Standards (`STANDARDS.md`)

Injected as `CLAUDE.md` into every new project. Covers:

- **Readable** — naming conventions, single-responsibility functions, no useless names
- **Maintainable** — layer order, dependency injection, no premature abstraction
- **Reliable** — async error handling, boundary validation, no `any` in TypeScript
- **Efficient** — async I/O, `Promise.all`, no `SELECT *`
- **Security** — no hardcoded secrets, parameterized queries, no PII in logs

Rules automatable by oxlint are enforced by hooks — only judgment-requiring rules live in this file.

---

## Custom Commands

| Command | Does |
|---------|------|
| `/architect` | Review project structure and layer separation |
| `/quality-check` | Multi-agent code quality review |
| `/refactor` | Refactor current file following project standards |
