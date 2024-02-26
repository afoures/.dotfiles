#!/bin/bash
#zmodload zsh/zprof

mkdir -p $HOME/.cache/zsh

# simple aliases to edit and source this file
alias ez="vim $HOME/.config/zsh/.zshrc"
alias sz="source $HOME/.config/zsh/.zshrc"

# ..
setopt caseglob
# allow hidden files
setopt globdots
# allow to cd with only the path
setopt autocd

# custom bins
PATH="$PATH:$HOME/.bin";
PATH="/usr/local/sbin:$PATH"

source $ZDOTDIR/completion.sh
source $ZDOTDIR/history.sh

source $ZDOTDIR/aliases.sh
source $ZDOTDIR/emoji.sh
source $ZDOTDIR/prompt.sh

source $ZDOTDIR/node.sh

#zprof
