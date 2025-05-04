#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
  echo "installing brew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "homebrew installed successfully."
else
  echo "homebrew is already installed."
fi

brew bundle --file=$DOTFILES/brew/default-setup
