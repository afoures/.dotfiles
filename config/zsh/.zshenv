# .zshenv is sourced on all invocations of the shell, unless the -f option is set.
# it should contain commands to set the command search path, plus other important environment variables.
# .zshenv' should not contain commands that produce output or assume the shell is attached to a tty.

ZDOTDIR="${${(%):-%x}:P:h}"
#        ${            :h}   remove trailing pathname component (man zshexpn)
#        ${          :P  }   get realpath (man zshexpn)
#          ${(%):-  }        enable prompt expansion (man zshexpn zshmisc)
#          ${     %x}        name of file containing this line (man zshmisc)

export WORKSPACE="$HOME/code"
export DOTFILES="${ZDOTDIR:h:h}"             # <dotfiles>/config/zsh -> <dotfiles>

# XDG base directory specification
export XDG_CONFIG_HOME="$HOME/.config"         # config files
export XDG_CACHE_HOME="$HOME/.cache"           # cache files
export XDG_DATA_HOME="$HOME/.local/share"      # application data
export XDG_STATE_HOME="$HOME/.local/state"     # logs and state files
export XDG_BIN_DIR="$HOME/.local/bin"

[[ -r $XDG_CONFIG_HOME/nvim/appname ]] && export NVIM_APPNAME=$(<$XDG_CONFIG_HOME/nvim/appname)
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

export CLICOLOR=1
export SHELL_SESSIONS_DISABLE=1

export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude/default"

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

# Homebrew (sets HOMEBREW_PREFIX, fpath, MANPATH, INFOPATH, ...)
# `brew shellenv` costs ~17ms, so its output is cached and regenerated only when
# brew updates the script that produces it.
# it is generated with a minimal PATH: shellenv prints nothing when PATH already
# starts with homebrew's dirs, which would cache an empty file.
if [[ -x /opt/homebrew/bin/brew ]]; then
  () {
    local cache=$XDG_CACHE_HOME/zsh/brew-shellenv.zsh
    local src=/opt/homebrew/Library/Homebrew/cmd/shellenv.sh
    if [[ ! -s $cache || $src -nt $cache ]]; then
      mkdir -p ${cache:h}
      PATH=/usr/bin:/bin /opt/homebrew/bin/brew shellenv zsh >| $cache.$$ 2>/dev/null \
        && mv -f $cache.$$ $cache
    fi
    if [[ -s $cache ]]; then
      source $cache
    else
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"   # cache unusable: fall back
    fi
  }
fi

# order: dotfiles scripts > user binaries > mise shims > homebrew > system.
# defined as a function because login shells must re-apply it: /etc/zprofile
# runs macOS's path_helper after this file, which moves system dirs to the front.
# mise shims make pinned tools (node, pnpm, ...) available to non-interactive
# shells too (tmux run-shell, popups, editor jobs); interactive shells still get
# `mise activate` from .zshrc, which puts the real tool dirs ahead of the shims.
set_path_order() {
  typeset -gU path                # keep first occurrence of duplicates
  path=(
    $DOTFILES/bin
    $XDG_BIN_DIR
    ${MISE_DATA_DIR:-$XDG_DATA_HOME/mise}/shims
    ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
    ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}
    $path                         # keep existing PATH entries
  )
  path=($^path(N-/))              # drop non-existent directories
  export PATH
}
set_path_order
