# zsh-defer
source $HOME/.zsh/zsh-defer/zsh-defer.plugin.zsh

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
setopt APPEND_HISTORY
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Default editor
export EDITOR=nvim
export VISUAL="$EDITOR"

# Language settings
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Aliases
alias vim="nvim"
alias vi="nvim"
alias cd="z"

# PATH
export PATH="$HOME/.local/bin:$PATH"
# gaurded neovim for custom installation
[ -d /opt/nvim-linux-x86_64/bin ] && export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Tool Init

# nvm
export NVM_DIR="$HOME/.nvm"
() {
  local versions=$NVM_DIR/versions/node default
  [[ -r $NVM_DIR/alias/default ]] && default=$(<$NVM_DIR/alias/default)
  if [[ ! -d $versions/$default ]]; then
    local -a installed=($versions/*(N/n))
    default=${installed[-1]:t}
  fi
  [[ -d $versions/$default/bin ]] && path=($versions/$default/bin $path)
}
zsh-defer -c '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use'
zsh-defer -c '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
zsh-defer -c '[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"'

# go
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PATH"

# zoxide
eval "$(zoxide init zsh)"
