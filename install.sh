#!/bin/bash
# Install dotfiles → ~/.claude, ~/.zshrc, ~/.gitconfig, ~/.ssh, ~/.vimrc, ~/.tmux
# Safe: never overwrites existing files unless --force passed

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
FORCE=""
CLAUDE_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --force)       FORCE="--force" ;;
    --claude-only) CLAUDE_ONLY=true ;;
  esac
done

symlink() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] && [ "$FORCE" != "--force" ]; then
    echo "  skip (exists): $dest"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
  echo "  linked: $dest → $src"
}

copy_file() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] && [ "$FORCE" != "--force" ]; then
    echo "  skip (exists): $dest"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  installed: $dest"
}

if $CLAUDE_ONLY; then
  echo "=== Installing Claude config only ==="
else
  echo "=== Installing dotfiles ==="
fi
echo ""

if $CLAUDE_ONLY; then
  echo "[claude]"
  copy_file "$DOTFILES/settings.json"   "$CLAUDE_DIR/settings.json"
  copy_file "$DOTFILES/mcp.json"        "$CLAUDE_DIR/mcp.json"
  copy_file "$DOTFILES/CLAUDE.md"       "$CLAUDE_DIR/CLAUDE.md"
  copy_file "$DOTFILES/STANDARDS.md"    "$CLAUDE_DIR/STANDARDS.md"
  copy_file "$DOTFILES/RTK.md"          "$CLAUDE_DIR/RTK.md"

  for f in "$DOTFILES"/hooks/*; do
    copy_file "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
  done
  chmod +x "$CLAUDE_DIR"/hooks/*.sh "$CLAUDE_DIR"/hooks/*.js 2>/dev/null || true

  for f in "$DOTFILES"/commands/*; do
    copy_file "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
  done

  for f in "$DOTFILES"/templates/.* "$DOTFILES"/templates/*; do
    [ -f "$f" ] && copy_file "$f" "$CLAUDE_DIR/templates/$(basename "$f")"
  done

  echo ""
  echo "=== Done. ==="
  exit 0
fi

# ── SSH → GitHub ──────────────────────────────────────────
echo "[ssh]"
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "akkwut@gmail.com" -f "$SSH_KEY" -N ""
  ssh-add --apple-use-keychain "$SSH_KEY"
  pbcopy < "$SSH_KEY.pub"
  echo "  generated: $SSH_KEY"
  echo "  public key copied to clipboard"
  echo "  opening GitHub SSH settings..."
  open "https://github.com/settings/ssh/new"
  echo ""
  echo "  Paste key in GitHub, save, then press Enter..."
  read -r
  ssh -T git@github.com 2>&1 || true
else
  echo "  skip (exists): $SSH_KEY"
fi
symlink "$DOTFILES/ssh/config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config" 2>/dev/null || true

# ── Shell ─────────────────────────────────────────────────
echo "[shell]"
symlink "$DOTFILES/shell/.zshrc" "$HOME/.zshrc"

if [ ! -f "$HOME/.secrets" ]; then
  cp "$DOTFILES/shell/.secrets.example" "$HOME/.secrets"
  echo "  created: ~/.secrets (fill in values)"
else
  echo "  skip (exists): ~/.secrets"
fi

# ── Git ───────────────────────────────────────────────────
echo "[git]"
symlink "$DOTFILES/git/.gitconfig"       "$HOME/.gitconfig"
symlink "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"

# ── Claude ────────────────────────────────────────────────
echo "[claude]"
copy_file "$DOTFILES/settings.json"   "$CLAUDE_DIR/settings.json"
copy_file "$DOTFILES/mcp.json"        "$CLAUDE_DIR/mcp.json"
copy_file "$DOTFILES/CLAUDE.md"       "$CLAUDE_DIR/CLAUDE.md"
copy_file "$DOTFILES/STANDARDS.md"    "$CLAUDE_DIR/STANDARDS.md"
copy_file "$DOTFILES/RTK.md"          "$CLAUDE_DIR/RTK.md"

for f in "$DOTFILES"/hooks/*; do
  copy_file "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
done
chmod +x "$CLAUDE_DIR"/hooks/*.sh "$CLAUDE_DIR"/hooks/*.js 2>/dev/null || true

for f in "$DOTFILES"/commands/*; do
  copy_file "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
done

for f in "$DOTFILES"/templates/.* "$DOTFILES"/templates/*; do
  [ -f "$f" ] && copy_file "$f" "$CLAUDE_DIR/templates/$(basename "$f")"
done

# ── Homebrew ──────────────────────────────────────────────
echo "[brew]"
if ! command -v brew &>/dev/null; then
  echo "  installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle --file="$DOTFILES/Brewfile"

# ── Vim ───────────────────────────────────────────────────
echo "[vim]"
symlink "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
echo "  → run :PlugInstall inside vim on first launch"

# ── Tmux ──────────────────────────────────────────────────
echo "[tmux]"
if [ ! -d "$HOME/.tmux" ]; then
  git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
  echo "  cloned gpakosz/.tmux"
else
  echo "  skip (exists): $HOME/.tmux"
fi
symlink "$DOTFILES/tmux/tmux.conf.local" "$HOME/.tmux.conf.local"

# ── macOS defaults ────────────────────────────────────────
echo "[macos]"
read -rp "  Apply macOS defaults (dock, finder, keyboard)? [y/N] " apply_macos
if [[ "$apply_macos" =~ ^[Yy]$ ]]; then
  bash "$DOTFILES/macos/defaults.sh"
fi

echo ""
echo "=== Done. Re-run with --force to overwrite existing files. ==="
echo ""
echo "Post-install checklist:"
echo "  ssh       → ssh -T git@github.com"
echo "  secrets   → fill in ~/.secrets"
echo "  vim       → :PlugInstall"
echo "  tmux      → prefix + r to reload"
echo "  claude    → claude plugins install caveman@caveman"
echo "  claude    → claude plugins install mempalace@mempalace"
echo "  claude    → claude plugins install impeccable@impeccable"
echo "  claude    → claude plugins install andrej-karpathy-skills@karpathy-skills"
echo "  claude    → claude plugins install mattpocock-skills@mattpocock"
echo "  claude    → claude plugins install grammar-fix@grammar-fix"
echo "  claude    → mcp.json.example has MCP servers (github/context7/seq-thinking/playwright), disabled by default — copy to mcp.json to re-enable"
echo "  shell     → source ~/.zshrc"
