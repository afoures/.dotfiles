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

export CLICOLOR=1

export BUN_INSTALL="$HOME/.bun"

export FZF_DEFAULT_OPTS='
  --color=fg:-1,fg+:-1,bg:-1,bg+:-1
  --color=hl:5,hl+:5,info:15,marker:3
  --color=prompt:7,spinner:8,pointer:3,header:15
  --color=border:15,separator:8,scrollbar:8,label:15,query:15
  --border="rounded" --preview-window="border-rounded" --prompt="󰩉 "
  --marker="" --pointer="" --separator="─" --scrollbar="│"
  --layout="reverse" --cycle
  --info="right" --border-label-pos="4"
'

# ~~~~~~~~~~~~~~~ path configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob              # extended globbing (use `**` for recursive globbing)
setopt null_glob                  # ignore non-matching glob patterns
setopt globdots                   # allow globbing to match filenames starting with a dot (e.g., `.file`)
setopt nocaseglob                 # case-insensitive globbing

path=(
  $path                           # keep existing PATH entries
  $DOTFILES/bin                   # dotfiles scripts
  $BUN_INSTALL/bin                # bun script
  $HOME/.opencode/bin
)

# remove duplicate entries and non-existent directories
typeset -U path
path=($^path(N-/))

export PATH

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
