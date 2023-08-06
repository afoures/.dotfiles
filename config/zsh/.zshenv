# .zshenv is sourced on all invocations of the shell, unless the -f option is set.
# It should contain commands to set the command search path, plus other important environment variables.
# .zshenv' should not contain commands that produce output or assume the shell is attached to a tty.

ZDOTDIR="${${(%):-%x}:P:h}"
#        ${            :h}   Remove trailing pathname component (man zshexpn)
#        ${          :P  }   Get realpath (man zshexpn)
#          ${(%):-  }        Enable prompt expansion (man zshexpn zshmisc)
#          ${     %x}        Name of file containing this line (man zshmisc)

export WORKSPACE="$HOME/code"
export DOTFILES_FOLDER="$(dirname $(dirname $ZDOTDIR))"

export EDITOR="nvim"
export GIT_EDITOR="nvim"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

# $XDG_DATA_HOME
# $XDG_CONFIG_HOME
# $XDG_STATE_HOME
# $XDG_CACHE_HOME
# https://specifications.freedesktop.org/basedir-spec/latest/ar01s02.html
