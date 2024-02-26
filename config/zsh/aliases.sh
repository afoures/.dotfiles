#!/bin/bash

## common aliases
alias vi="nvim"
alias vim="nvim"

alias python="python3"
alias pip="pip3"

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagacad
alias ls="ls -Ap" 
alias ll="ls -lahp"

## git aliases
alias gu="git undo"
function gc { git commit -m "$@" }
alias gs="git status"
alias gss="git status -s"
alias gcl="git clone"
alias gpush="git push"
alias gpull="git pull"

## custom aliases
function archive {
  mv $@ $WORKSPACE/.archives/
}
alias delete_DSfiles="find . -name '.DS_Store' -type f -delete"
