#!/usr/bin/env zsh
#zmodload zsh/zprof

# ~~~~~~~~~~~~~~~ aliases ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

alias reload_zshrc="source $ZDOTDIR/.zshrc"

function archive {
  mkdir -p $WORKSPACE/.archives
  mv $@ $WORKSPACE/.archives/
}
alias delete_DSfiles="find . -name '.DS_Store' -type f -delete"

alias g="git"
alias gu="git undo"
function gc { git commit -m "$@" }
alias gs="git status"
alias gss="git status -s"
alias gcl="git clone"
alias gpush="git push"
alias gpull="git pull"

alias ls="ls -Ap" 
alias ll="ls -lahp"

alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# ~~~~~~~~~~~~~~~ history ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local HISTORY_DIR="$XDG_CACHE_HOME/zsh"
HISTFILE="$HISTORY_DIR/history"

[[ -d $HISTORY_DIR ]] || mkdir -p "$HISTORY_DIR"

SAVEHIST=100000              # number of commands to save to HISTFILE
HISTSIZE=100000              # number of commands to keep in memory

setopt extendedhistory       # record timestamp + duration for each command
setopt sharehistory          # share history across all sessions
setopt incappendhistory      # write commands to history file immediately
setopt histignoredups        # ignore duplicate commands
setopt histignorespace       # ignore commands starting with space
setopt histfindnodups        # skip duplicates during history search
setopt histreduceblanks      # remove superfluous blanks
setopt histverify            # verify history expansions before running
setopt histnofunctions       # do not save function definitions
setopt histnostore           # do not store 'history' commands themselves

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# ~~~~~~~~~~~~~~~ prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function set_emoji {
  current_emoji="$1"
}

function random_emoji {
  local emojis=(🚀 👻 🦄 🐳 🐙 🦖 🦕 🐢 👀 🧠 💭 🐉 🍉 🌈)
 
  local filtered_emojis=()
  for emoji in "${emojis[@]}"; do
    if [[ "$emoji" != "$current_emoji" ]]; then
      filtered_emojis+=("$emoji")
    fi
  done

  set_emoji "${filtered_emojis[RANDOM % $#filtered_emojis + 1]}"
}

alias blastoff="set_emoji 🚀"
alias trex="set_emoji 🦖"
alias octopus="set_emoji 🐙"
alias rde="random_emoji"

random_emoji

autoload -Uz vcs_info

zmodload zsh/datetime

get_visible_length() {
  local input=$1
  local invisible='%([BSUbfksu]|([FK]|){*})' # (1)
  local length=${#${(S%%)input//$~invisible/}}
  echo $length
}

compute_execution_time() {
  if (( execution_start_realtime )); then
    local -rF elapsed_realtime=$(( EPOCHREALTIME - execution_start_realtime ))
    local -rF s=$(( elapsed_realtime%60 ))
    local -ri elapsed_s=${elapsed_realtime}
    local -ri m=$(( (elapsed_s/60)%60 ))
    local -ri h=$(( elapsed_s/3600 ))
    if (( h > 0 )); then
      printf -v execution_time '%ih%02im' ${h} ${m}
    elif (( m > 0 )); then
      printf -v execution_time '%im%02is' ${m} ${s}
    elif (( s >= 10 )); then
      printf -v execution_time '%.2fs' ${s} # 12.34s
    elif (( s >= 1 )); then
      printf -v execution_time '%.3fs' ${s} # 1.234s
    else
      printf -v execution_time '%ims' $(( s*1000 ))
    fi
    execution_time="${execution_time} "
    unset execution_start_realtime
  else
    # clear previous result when hitting ENTER with no command to execute
    unset execution_time
  fi
}

make_prompt() {
  XX='╭╮╰╯─'
  local current_dir="%F{6}%~%f"
  local vcs_branch=""
  local return_code="%(?.%f.%F{1})•%f"
  local current_nvim_config="%F{8}(${$(cat "$XDG_CONFIG_HOME/nvim/appname")//nvim-/})%f"

  if [[ -z $TMUX ]]; then 
    # only add git infos outside of tmux
    vcs_branch="%b${vcs_info_msg_0_}%f%b"
  fi

  left_prompt="╭─ ${current_dir}${vcs_branch} ${current_emoji} "
  right_prompt=" ${current_nvim_config} ${execution_time}${return_code}"

  local terminal_width=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))
  fill_bar="${(l:$(( terminal_width - $(get_visible_length $left_prompt) - $(get_visible_length $right_prompt) ))::─:)}"

  PROMPT='${left_prompt}${fill_bar}${right_prompt}
╰─ %b$ '
  RPROMPT=''
  PS2='.... '
}

prompt_preexec() {
  execution_start_realtime=${EPOCHREALTIME}
}

prompt_precmd() {
  vcs_info
  compute_execution_time
  make_prompt
  export NVIM_APPNAME=$(cat $XDG_CONFIG_HOME/nvim/appname)
}

# making sure prompt is correctly extended
setopt prompt_subst
setopt nopromptbang prompt{cr,percent,sp,subst}

# format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' on %F{5} %b'

preexec_functions+=(prompt_preexec)
precmd_functions+=(prompt_precmd)

# ~~~~~~~~~~~~~~~ completion ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[[ -d $ZDOTDIR/.zfunc ]] || mkdir -p "$ZDOTDIR/.zfunc"

fpath+=$DOTFILES/zsh/.zfunc

if type brew &>/dev/null; then
  fpath+=$(brew --prefix)/share/zsh-completions
fi

autoload -Uz compinit

local ZCOMPDUMP_DIR="$XDG_CACHE_HOME/zsh"
local ZCOMPDUMP_FILE="$ZCOMPDUMP_DIR/.zcompdump"

[[ -d $ZCOMPDUMP_DIR ]] || mkdir -p "$ZCOMPDUMP_DIR"

# use -C (compile if needed) and -u (unsecure)
compinit -C -d "$ZCOMPDUMP_FILE" -u

zstyle ':completion:*' menu select

# example to install completion:
# talosctl completion zsh > $ZDOTDIR/.zfunc/_talosctl
[ -s "/Users/afoures/.bun/_bun" ] && source "/Users/afoures/.bun/_bun"

# ~~~~~~~~~~~~~~~ sourcing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[[ -f "$ZDOTDIR/.privaterc" ]] && source "$ZDOTDIR/.privaterc"

eval "$(fnm env --use-on-cd --corepack-enabled)"

# ~~~~~~~~~~~~~~~ auto-sync dotfiles ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# activate this after extensive testing of the sync-dotfiles script

# # Run dotfiles sync once per hour in the background (quiet mode)
# # Uses timestamp file for persistence across shell sessions
# SYNC_TIMESTAMP_FILE="${DOTFILES}/.last-sync"
# SYNC_INTERVAL=18000  # 5 hours in seconds

# if [[ -f "$SYNC_TIMESTAMP_FILE" ]]; then
#   LAST_SYNC=$(stat -f%m "$SYNC_TIMESTAMP_FILE" 2>/dev/null || stat -c%Y "$SYNC_TIMESTAMP_FILE" 2>/dev/null)
# else
#   LAST_SYNC=0
# fi

# CURRENT_TIME=$(date +%s)
# if (( CURRENT_TIME - LAST_SYNC >= SYNC_INTERVAL )); then
#   touch "$SYNC_TIMESTAMP_FILE"
#   ("$DOTFILES/bin/sync-dotfiles" --quiet --unattended &) 2>/dev/null
# fi

#zprof
