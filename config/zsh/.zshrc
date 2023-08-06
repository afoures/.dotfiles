#!/bin/bash
#zmodload zsh/zprof

mkdir -p $HOME/.cache/zsh

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
compinit -d $HOME/.cache/zsh/.zcompdump

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

# Custom bins
PATH="$PATH:$HOME/.bin";
PATH="/usr/local/sbin:$PATH"

# bun completions
[ -s "/Users/afoures/.bun/_bun" ] && source "/Users/afoures/.bun/_bun"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# look for all .sh files and source them
config_files=($ZDOTDIR/**/*.sh)
for file in $config_files[@]; do
  source "$file"
done

#zprof
