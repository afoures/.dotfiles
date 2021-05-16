#!/bin/bash

# Simple aliases to edit and source this file
alias ez="vim $HOME/.config/zsh/.zshrc"
alias sz="source $HOME/.config/zsh/.zshrc"

setopt caseglob
setopt globdots
setopt autocd

# case-insensitive (uppercase from lowercase) completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# partial completion suggestions
zstyle ':completion:*' list-suffixes zstyle ':completion:*' expand prefix suffix 

# git completion suggestions
#zstyle ':completion:*:*:git:*' script $HOME/.config/zsh/auto-completions/.git-completion.sh

#fpath=($HOME/.config/zsh/auto-completions $fpath)

# Auto-completion
autoload -Uz compinit
compinit

# Better history management
HISTFILE="$HOME/.cache/zsh/history"
SAVEHIST=10000
HISTSIZE=10000

setopt extendedhistory
# share history across multiple zsh sessions
setopt sharehistory
# adds commands as they are typed, not at shell exit
setopt incappendhistory
# do not store duplications
setopt histignoredups
# ignore duplicates when searching
setopt histfindnodups
# removes blank lines from history
setopt histreduceblanks
# provide a way to verify the history substitution before running a command
setopt histverify

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' on %B%F{207} %b'
 
setopt promptsubst
PROMPT='%B%F{81}%~%f%b${vcs_info_msg_0_}%f%b ${EMOJI}'$'\n'"%B> %b"
RPROMPT='%F{244}%*%f'

function set_emoji {
  EMOJI="$*"
}

function random_emoji {
  EMOJIS=(🔥 🚀 👻 🤖 🦄 🥓 🌮 🎉 💯 🐳 🦁 🦊 🐙 🦖 🦕 🐍 🐢 ✨ ☄️ ⚡️ 💥)
  set_emoji "${EMOJIS[$RANDOM % ${#EMOJIS[@]}]}"
}

random_emoji

alias blastoff="set_emoji 🚀"
alias trex="set_emoji 🦖"
alias octopus="set_emoji 🐙"
alias rde="random_emoji"


[ -f "$HOME/.config/zsh/aliases" ] && source "$HOME/.config/zsh/aliases"
[ -f "$HOME/.config/zsh/private" ] && source "$HOME/.config/zsh/private"

# Custom bins
PATH="$PATH:$HOME/.bin";
PATH="/usr/local/sbin:$PATH"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
