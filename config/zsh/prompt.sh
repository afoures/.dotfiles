# Load version control information
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
    # Clear previous result when hitting ENTER with no command to execute
    unset execution_time
  fi
}

make_prompt() {
  XX='╭╮╰╯─'
  local current_dir="%F{81}%~%f"
  local vcs_branch="%b${vcs_info_msg_0_}%f%b"
  local return_code="%(?.%f.%F{202})•%f"

  left_prompt="╭─ ${current_dir}${vcs_branch} ${current_emoji} "
  right_prompt=" ${execution_time}${return_code}"

  local terminal_width=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))
  fill_bar="${(l:$(( terminal_width - $(get_visible_length $left_prompt) - $(get_visible_length $right_prompt) ))::─:)}"

  PROMPT='${left_prompt}${fill_bar}${right_prompt}
╰─ %b$ '
  RPROMPT=''
  PS2='.... '
}

set_cursor() {
  # 3 is blincking underline cursor
  echo -ne '\e[3 q'
}

preexec() {
  execution_start_realtime=${EPOCHREALTIME}
}

precmd() {
  vcs_info
  compute_execution_time
  make_prompt
  set_cursor
}

# making sure prompt is correctly extended
setopt prompt_subst
setopt nopromptbang prompt{cr,percent,sp,subst}

# format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' on %B%F{207} %b'
