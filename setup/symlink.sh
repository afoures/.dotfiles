#!/usr/bin/env bash

echo "this will remove your current config files"
read -p "confirm (y/n)? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  exit 1
fi

rm "$HOME/.config"
ln -s "$DOTFILES/config" "$HOME/.config"
echo "created symlink for $HOME/.config"

rm "$HOME/.zshenv"
ln -s ".config/zsh/.zshenv" "$HOME/.zshenv"
echo "created symlink for $HOME/.zshenv"
