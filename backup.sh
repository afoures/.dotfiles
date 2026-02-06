#!/usr/bin/env bash

set -e

BACKUP_FOLDER="$DOTFILES/.backups"
CURRENT_BACKUP="$BACKUP_FOLDER/backup_$(date +%s)"

echo "backing up to ~${CURRENT_BACKUP#$HOME}"
mkdir -p "$CURRENT_BACKUP/.config"

# Backup .config contents
if [[ -d "$HOME/.config" ]]; then
  echo "backing up .config..."
  for target in "$HOME/.config"/*; do
    if [[ -e "$target" ]]; then
      echo "  → $(basename "$target")"
      cp -RL "$target" "$CURRENT_BACKUP/.config/"
    fi
  done
fi

# Backup .zshenv
if [[ -e "$HOME/.zshenv" ]]; then
  echo "backing up .zshenv..."
  cp "$HOME/.zshenv" "$CURRENT_BACKUP/.zshenv"
fi

# Backup brew packages
if command -v brew &>/dev/null; then
  echo "backing up brew packages..."
  brew bundle dump --file="$CURRENT_BACKUP/brewfile" &>/dev/null
fi

echo "backup complete: ~${CURRENT_BACKUP#$HOME}"
