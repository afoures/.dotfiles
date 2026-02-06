# .zshenv is sourced on all invocations of the shell, unless the -f option is set.
# it should contain commands to set the command search path, plus other important environment variables.
# .zshenv' should not contain commands that produce output or assume the shell is attached to a tty.

ZDOTDIR="${${(%):-%x}:P:h}"
#        ${            :h}   remove trailing pathname component (man zshexpn)
#        ${          :P  }   get realpath (man zshexpn)
#          ${(%):-  }        enable prompt expansion (man zshexpn zshmisc)
#          ${     %x}        name of file containing this line (man zshmisc)

export WORKSPACE="$HOME/code"
export DOTFILES="$(dirname $(dirname $ZDOTDIR))"

# XDG base directory specification
export XDG_CONFIG_HOME="$HOME/.config"         # config files
export XDG_CACHE_HOME="$HOME/.cache"           # cache files
export XDG_DATA_HOME="$HOME/.local/share"      # application data
export XDG_STATE_HOME="$HOME/.local/state"     # logs and state files

export NVIM_APPNAME=$(cat $XDG_CONFIG_HOME/nvim/appname)
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

