#!/bin/bash
SETUP_FOLDER=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BACKUP_FOLDER="$SETUP_FOLDER/.backups"
CURRENT_BACKUP="$BACKUP_FOLDER/backup_$(date +%s)"

echo "everything will be saved in ~${CURRENT_BACKUP#$HOME}"

mkdir -p "$CURRENT_BACKUP"
mkdir -p "$CURRENT_BACKUP/.config"

for config in $SETUP_FOLDER/config/*; do
  target="$HOME/.config/$(basename "$config")"
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
