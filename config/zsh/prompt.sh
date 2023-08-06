# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' on %B%F{207} %b'

setopt promptsubst
PROMPT='%B%F{81}%~%f%b${vcs_info_msg_0_}%f%b ${EMOJI}'$'\n'"%B> %b"
RPROMPT='%F{244}%*%f'
