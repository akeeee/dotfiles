# Powerlevel10k instant prompt — keep at top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# PATH — brew is set in ~/.zprofile; each dir listed once (typeset -U drops repeats)
typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/.clawlinked/bin"
  /opt/homebrew/opt/libpq/bin
  /Applications/Cursor.app/Contents/MacOS
  $path
)

# mise — ruby, node, bun, pnpm, python, go and global npm CLIs (see ~/.config/mise/config.toml)
eval "$(/opt/homebrew/bin/mise activate zsh)"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"

# Docker
export DOCKER_DEFAULT_PLATFORM=linux/amd64


# Aliases
alias zshconfig="cursor ~/.zshrc"
alias myip='ipconfig getifaddr en0'
alias t="tmux new -s main || tmux attach -t main"
alias yw="yarn build --watch"
alias rw="bin/rails dartsass:watch"
alias rs="rails s"

# Cursor
function cursor {
  open -a "/Applications/Cursor.app" "$@"
}

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Secrets (not committed — copy manually on new Mac)
[[ -f ~/.secrets ]] && source ~/.secrets

# Thai input: keep combining vowels/tone marks as separate editable units so
# backspace strips the mark (อิ -> อ) instead of deleting the whole syllable.
unsetopt COMBINING_CHARS

# opusfund local Lima runtime host (docs/operations/lima-runtime-host.md).
# OPUSFUND_NGROK_URL lives in ~/.secrets; the authtoken is read from the
# existing ngrok config so it is never duplicated into a dotfile.
opusfund-runtime() {
  local root="$HOME/claude/projects/office/opusfund"
  local ngrok_config="$HOME/Library/Application Support/ngrok/ngrok.yml"

  if [[ -z "$OPUSFUND_NGROK_URL" ]]; then
    print -u2 "set OPUSFUND_NGROK_URL='https://<reserved-domain>' in ~/.secrets"
    return 1
  fi

  local -x NGROK_AUTHTOKEN
  NGROK_AUTHTOKEN="$(awk '/^[[:space:]]*authtoken:[[:space:]]*/{print $2; exit}' "$ngrok_config")"
  if [[ -z "$NGROK_AUTHTOKEN" ]]; then
    print -u2 "no agent.authtoken in $ngrok_config; run: ngrok config add-authtoken <token>"
    return 1
  fi

  # Resolve python3 through mise so the repo's mise.toml pin wins over the
  # Homebrew python3 symlink, whose 3.14 bottle has a broken pyexpat.
  local -x PATH="$HOME/.local/share/mise/shims:$PATH"

  local -x RUNTIME_PUBLIC_URL="$OPUSFUND_NGROK_URL"
  local -x OPUSFUND_LOCAL_IMAGE_NAME="${OPUSFUND_LOCAL_IMAGE_NAME:-dev}"
  local -x OPUSFUND_LOCAL_VM_NAMES="${OPUSFUND_LOCAL_VM_NAMES:-opusfund-arm64-dev-1}"
  local -x OPUSFUND_LOCAL_ALLOW_DIRTY="${OPUSFUND_LOCAL_ALLOW_DIRTY:-false}"
  local -x OPUSFUND_LOCAL_VM_MEMORY_GIB="${OPUSFUND_LOCAL_VM_MEMORY_GIB:-1}"
  local -x OPUSFUND_LOCAL_CONTAINER_MEMORY_MB="${OPUSFUND_LOCAL_CONTAINER_MEMORY_MB:-500}"
  local -x OPUSFUND_LOCAL_VM_DISK_GIB="${OPUSFUND_LOCAL_VM_DISK_GIB:-15}"

  (cd "$root" && bin/run-runtime-lima-local "$@")
}

# Interactive claude in a git repo: Claude left 70%, live git diff (hunk) right 30%.
# Skipped for -p/--print, piped output, or outside git. Bypass with `command claude`.
claude() {
  local is_print=$(( ${@[(I)-p]} + ${@[(I)--print]} ))
  if [[ ! -t 1 ]] || (( is_print )) || ! git rev-parse --is-inside-work-tree &>/dev/null; then
    command claude "$@"
    return
  fi

  # Session dies when the terminal window closes, so nothing keeps running in the background
  if [[ -z $TMUX ]]; then
    tmux new-session -c "$PWD" \; set-option destroy-unattached on \; \
      send-keys "claude ${(j: :)${(q)@}}; exit" C-m
    return
  fi

  # Diff pane runs hunk directly (no shell), and is killed when claude exits
  local diff_pane
  diff_pane=$(tmux split-window -h -d -l 30% -c "$PWD" -P -F '#{pane_id}' "hunk diff --watch")
  command claude "$@"
  tmux kill-pane -t "$diff_pane" 2>/dev/null
}
