# Powerlevel10k instant prompt — keep at top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=~/.npm-global/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.rvm/bin:$PATH"
export PATH="$HOME/.clawlinked/bin:$PATH"
export PATH="/Applications/Cursor.app/Contents/MacOS:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Android
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"

# Docker
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Python
alias python3="python3.9"
alias pip="pip3.9"

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
