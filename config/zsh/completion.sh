# case-insensitive (uppercase from lowercase) completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# git completion suggestions
#zstyle ':completion:*:*:git:*' script $HOME/.config/zsh/auto-completions/.git-completion.sh

#fpath=($HOME/.config/zsh/auto-completions $fpath)

# auto-completion
autoload -Uz compinit
compinit -d $HOME/.cache/zsh/.zcompdump

# bun completions
[ -s "/Users/afoures/.bun/_bun" ] && source "/Users/afoures/.bun/_bun"
