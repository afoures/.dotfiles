#!/usr/bin/env bash
BACKUP_FOLDER="$DOTFILES/.backups"
CURRENT_BACKUP="$BACKUP_FOLDER/backup_$(date +%s)"

echo "everything will be saved in ~${CURRENT_BACKUP#$HOME}"

mkdir -p "$CURRENT_BACKUP"
mkdir -p "$CURRENT_BACKUP/.config"

for target in $HOME/.config/*; do
  if [ -e "$target" ]; then
    echo "creating backup for ~${target#$HOME}"
    cp -rf "$target" "$CURRENT_BACKUP/.config/$(basename "$target")"
  fi
done

if [ -e "$HOME/.zshenv" ]; then
  echo "creating backup for ~/.zshenv"
  cp "$HOME/.zshenv" "$CURRENT_BACKUP/.zshenv"
fi

if test "$(command -v brew)"; then
  echo "creating backup for brew"
  brew bundle dump --file="$CURRENT_BACKUP/brewfile" &> /dev/null
fi
