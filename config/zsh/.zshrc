#!/usr/bin/env zsh
#zmodload zsh/zprof

# ~~~~~~~~~~~~~~~ aliases ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

alias philippe='CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude/matters" command claude'

function reload() {
  # only works for zsh
  if [[ -o login ]]; then
    exec "$SHELL" -l
  else
    exec "$SHELL"
  fi
}

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
  local emojis=(🚀 🦄 🐳 🐙 🦖 🦕 🐢 👀 🧠 💭 🦝 🧙🏻‍♂️ 🐸 🪐 🍪 🤖)
 
  local filtered_emojis=()
  for emoji in "${emojis[@]}"; do
    if [[ "$emoji" != "$current_emoji" ]]; then
      filtered_emojis+=("$emoji")
    fi
  done

  set_emoji "${filtered_emojis[RANDOM % $#filtered_emojis + 1]}"
}

alias e_blastoff="set_emoji 🚀"
alias e_trex="set_emoji 🦖"
alias e_octopus="set_emoji 🐙"
alias e_frog="set_emoji 🐸"
alias rde="random_emoji"

random_emoji

zmodload zsh/datetime

# fast pure-zsh branch reader — replaces vcs_info, which forks git (~20ms/prompt)
prompt_git_branch() {
  vcs_branch_raw=""
  local dir=$PWD gitdir head ref
  while [[ -n $dir ]]; do
    if [[ -d $dir/.git ]]; then
      gitdir=$dir/.git; break
    elif [[ -f $dir/.git ]]; then            # worktree/submodule: .git is a file
      gitdir=${$(<$dir/.git)#gitdir: }
      [[ $gitdir != /* ]] && gitdir=$dir/$gitdir
      break
    fi
    dir=${dir%/*}
  done
  [[ -n $gitdir && -r $gitdir/HEAD ]] || return
  head=$(<$gitdir/HEAD)
  if [[ $head == ref:* ]]; then
    ref=${head#ref: refs/heads/}             # normal branch (keeps slashes)
  else
    ref=${head[1,7]}                         # detached HEAD: short sha
  fi
  vcs_branch_raw=${git_prompt_format/\%b/${ref//\%/%%}}
}

# sets REPLY instead of echoing, so callers avoid a subshell fork
get_visible_length() {
  local input=$1
  local invisible='%([BSUbfksu]|([FK]|){*})' # (1)
  REPLY=${#${(S%%)input//$~invisible/}}
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
  local current_nvim_config="%F{8}(${nvim_appname//nvim-/})%f"

  if [[ -z $TMUX ]]; then
    # only add git infos outside of tmux
    vcs_branch="%b${vcs_branch_raw}%f%b"
  fi

  left_prompt="╭─ ${current_dir}${vcs_branch} ${current_emoji} "
  right_prompt=" ${current_nvim_config} ${execution_time}${return_code}"

  local terminal_width=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))
  local left_len right_len
  get_visible_length "$left_prompt";  left_len=$REPLY
  get_visible_length "$right_prompt"; right_len=$REPLY
  fill_bar="${(l:$(( terminal_width - left_len - right_len ))::─:)}"

  PROMPT='${left_prompt}${fill_bar}${right_prompt}
╰─ %b$ '
  RPROMPT=''
  PS2='.... '
}

prompt_preexec() {
  execution_start_realtime=${EPOCHREALTIME}
}

prompt_precmd() {
  nvim_appname=$(<"$XDG_CONFIG_HOME/nvim/appname")
  export NVIM_APPNAME=$nvim_appname
  [[ -z $TMUX ]] && prompt_git_branch    # branch only shown outside tmux
  compute_execution_time
  make_prompt
}

# making sure prompt is correctly extended
setopt prompt_subst
setopt nopromptbang prompt{cr,percent,sp,subst}

# branch segment template; %b is replaced with the branch name by prompt_git_branch
git_prompt_format=' on %F{5} %b'

preexec_functions+=(prompt_preexec)
precmd_functions+=(prompt_precmd)

# ~~~~~~~~~~~~~~~ completion ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[[ -d $ZDOTDIR/.zfunc ]] || mkdir -p "$ZDOTDIR/.zfunc"

fpath+=$ZDOTDIR/.zfunc

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

[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"

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
