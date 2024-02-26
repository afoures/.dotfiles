#!/bin/sh

# better history management
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
