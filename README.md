# dotfiles

Personal dev environment — SSH, shell, git, Claude Code, Vim, Tmux.

---

## Quick Install

**New Mac (first time):**
```bash
# Clone via HTTPS first — SSH doesn't exist yet
git clone https://github.com/akeeee/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

**Existing Mac (Claude config only):**
```bash
bash install.sh --claude-only
```

**Force overwrite existing files:**
```bash
bash install.sh --force
bash install.sh --claude-only --force
```

**After install — finish manually:**
```bash
# Fill in project secrets
nano ~/.secrets

# Verify GitHub SSH
ssh -T git@github.com

# Claude plugins
claude plugins install caveman@caveman
claude plugins install mempalace@mempalace
claude plugins install ecc@ecc

# Vim plugins (run inside vim)
:PlugInstall

# Tmux reload
tmux source ~/.tmux.conf
```

---

## What Gets Installed

| Section | Files | Destination |
|---------|-------|-------------|
| SSH | `ssh/config` | `~/.ssh/config` |
| Shell | `shell/.zshrc`, `shell/.p10k.zsh` | `~/.zshrc`, `~/.p10k.zsh` |
| Git | `git/.gitconfig`, `git/.gitignore_global` | `~/.gitconfig`, `~/.gitignore_global` |
| Claude | `settings.json`, `mcp.json`, `CLAUDE.md`, `STANDARDS.md`, `RTK.md`, hooks, commands, templates | `~/.claude/` |
| Homebrew | `Brewfile` | installs packages |
| Vim | `vim/vimrc` | `~/.vimrc` |
| Tmux | `tmux/tmux.conf.local` | `~/.tmux.conf.local` |
| macOS | `macos/defaults.sh` | prompts before applying |

---

## Structure

```
dotfiles/
  install.sh              # bootstrap — runs everything
  Brewfile                # all brew packages and casks

  shell/
    .zshrc                # shell config (no secrets)
    .p10k.zsh             # Powerlevel10k prompt config
    .secrets.example      # template — copy to ~/.secrets and fill in

  git/
    .gitconfig            # user, aliases, global ignore
    .gitignore_global     # .DS_Store, .env, .secrets blocked globally

  ssh/
    config                # GitHub SSH settings

  macos/
    defaults.sh           # dock, finder, keyboard preferences

  vim/
    vimrc                 # vim config + plugins via vim-plug

  tmux/
    tmux.conf.local       # tmux personalisation on gpakosz/.tmux base

  hooks/                  # Claude Code lifecycle hooks
  commands/               # Claude Code custom slash commands
  templates/              # scaffolding files copied into new projects
  CLAUDE.md               # Claude stack context
  STANDARDS.md            # code quality rules injected into new projects
  RTK.md                  # RTK token-saver docs
  mcp.json                # MCP server config
  settings.json           # Claude Code settings
```

---

## Secrets

Secrets **never live in dotfiles**. They live in `~/.secrets` which is gitignored globally.

`install.sh` copies `shell/.secrets.example` → `~/.secrets` on first run. Fill in the values:

```bash
nano ~/.secrets
```

`~/.zshrc` sources it at the bottom:
```bash
[[ -f ~/.secrets ]] && source ~/.secrets
```

**On a new Mac:** transfer `~/.secrets` via 1Password, AirDrop, or encrypted USB — never via git or email.

---

## SSH → GitHub

`install.sh` handles this automatically:

1. Generates `~/.ssh/id_ed25519` if missing
2. Adds key to macOS Keychain (`ssh-add --apple-use-keychain`)
3. Copies public key to clipboard
4. Opens GitHub SSH settings page
5. Waits for you to paste and save
6. Verifies with `ssh -T git@github.com`

After that, all `git push/pull/clone` via SSH work silently — no password prompts ever.

---

## Vim

Config: `vim/vimrc` → `~/.vimrc`

Uses [vim-plug](https://github.com/junegunn/vim-plug). On new machine run `:PlugInstall` inside vim.

| Plugin | What it does |
|--------|-------------|
| gruvbox | Dark colorscheme |
| vim-airline | Status bar with branch and file info |
| NERDTree | File tree sidebar (`\n` to toggle) |
| fzf + fzf.vim | Fuzzy file/text search |
| vim-fugitive | Git commands inside vim (`:G status`, `:G blame`) |
| vim-gitgutter | Git diff in gutter |
| vim-surround | Change surrounding brackets, quotes, tags |
| vim-commentary | Toggle comments (`gcc` line, `gc` selection) |
| vim-polyglot | Syntax highlighting for 100+ languages |
| auto-pairs | Auto-closes `(`, `[`, `{`, `"` |

---

## Tmux

Config: `tmux/tmux.conf.local` → `~/.tmux.conf.local`

Built on [gpakosz/.tmux](https://github.com/gpakosz/.tmux). `install.sh` clones the framework automatically. Personal config goes in `.local` only — framework never modified.

---

## Claude Code

Claude Code is Anthropic's AI coding CLI. This setup makes it faster, safer, and cheaper.

### Stack Context

`CLAUDE.md` tells Claude the tech stack so it defaults to correct conventions without prompting.

**Default stack:**
- Frontend: Next.js — App Router, TypeScript, Tailwind
- Backend: Next.js API routes / Server Actions
- Database: Supabase (Postgres + Auth + Storage)
- Deploy: Vercel

**Rails stack:**
- Frontend: JavaScript — ES modules, Stimulus, Hotwire Turbo
- Backend: Ruby on Rails — MVC, ActiveRecord, Turbo Streams
- Tests: RSpec (backend), Jest (frontend)

### MCP Servers

`mcp.json` wires in servers that load automatically:

| Server | What it does |
|--------|-------------|
| `context7` | Live Rails/JS docs — stops Claude hallucinating old APIs |
| `playwright` | E2E browser automation for Turbo/Stimulus UI |
| `sequential-thinking` | Step-by-step reasoning for complex migrations and architecture |
| `github` | Reads PR and issue context without leaving the terminal |

> `github` MCP needs `GITHUB_PERSONAL_ACCESS_TOKEN` in `~/.secrets`.

### Hooks

Hooks are shell scripts wired to Claude Code lifecycle events. They enforce rules with code — the model cannot skip them.

| Hook | Event | What it does |
|------|-------|-------------|
| `block-critical-files.js` | PreToolUse (Edit/Write) | Blocks Claude touching `.env`, lock files, private keys, certs |
| `block-prod-deps.js` | PreToolUse (Bash) | Blocks `npm install x` without `--dev` — forces approval for prod deps |
| `lint-on-write.sh` | PostToolUse (Edit/Write) | Runs oxlint on every TS/JS file Claude writes |
| `new-project-standards.sh` | PostToolUse (Write) | Copies `STANDARDS.md` → `CLAUDE.md` when Claude creates a new project |
| `rtk hook claude` | PreToolUse (Bash) | Strips irrelevant output before it enters context — saves 60–90% tokens |

### Custom Slash Commands

| Command | What it does |
|---------|-------------|
| `/architect` | Reviews project structure, layer separation, scalability |
| `/quality-check` | Multi-agent code quality review |
| `/refactor` | Refactors current file per project standards |
| `/polish` | Clean Code + SOLID/DRY/KISS audit — shows proposal, waits for confirm |
| `/improve` | Full pipeline: quality → design → security → cleanup |

### STANDARDS.md

Auto-injected as `CLAUDE.md` into every new project. Rules:

- **Readable** — self-explanatory names, one function = one job
- **Maintainable** — strict layer order, dependency injection, no premature abstraction
- **Reliable** — every `await` needs error handling, validate only at system boundaries, no `any`
- **Efficient** — async I/O only, `Promise.all` for parallel ops, no `SELECT *`
- **Security** — env vars for secrets, parameterized queries, no PII in logs

### Plugins

| Plugin | What it does |
|--------|-------------|
| [caveman](https://github.com/JuliusBrussee/caveman) | Terse caveman responses — drops filler, cuts token usage ~75% |
| [mempalace](https://github.com/milla-jovovich/mempalace) | Persistent memory across sessions via knowledge graph |
| [ecc](https://github.com/affaan-m/ECC) | 200+ workflow skills — `/ecc:plan`, `/ecc:feature-dev`, `/ecc:security-scan` etc. |
