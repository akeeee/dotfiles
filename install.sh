#!/bin/bash
# Install claude-dotfiles → ~/.claude
# Safe: never overwrites existing files unless --force passed

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
FORCE=${1:-""}

link_or_copy() {
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

echo "Installing claude-dotfiles to $CLAUDE_DIR"
echo ""

# Core config
link_or_copy "$DOTFILES_DIR/settings.json"   "$CLAUDE_DIR/settings.json"
link_or_copy "$DOTFILES_DIR/CLAUDE.md"       "$CLAUDE_DIR/CLAUDE.md"
link_or_copy "$DOTFILES_DIR/STANDARDS.md"    "$CLAUDE_DIR/STANDARDS.md"
link_or_copy "$DOTFILES_DIR/RTK.md"          "$CLAUDE_DIR/RTK.md"

# Hooks
for f in "$DOTFILES_DIR"/hooks/*; do
  link_or_copy "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
done
chmod +x "$CLAUDE_DIR"/hooks/*.sh "$CLAUDE_DIR"/hooks/*.js 2>/dev/null || true

# Commands (custom slash commands)
for f in "$DOTFILES_DIR"/commands/*; do
  link_or_copy "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
done

# Templates
for f in "$DOTFILES_DIR"/templates/.*  "$DOTFILES_DIR"/templates/*; do
  [ -f "$f" ] && link_or_copy "$f" "$CLAUDE_DIR/templates/$(basename "$f")"
done

echo ""
echo "Done. Re-run with --force to overwrite existing files."
echo "Caveman plugin: claude plugins install caveman@caveman"
echo "MemPalace plugin: claude plugins install mempalace@mempalace"
