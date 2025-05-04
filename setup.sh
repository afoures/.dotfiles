#!/usr/bin/env bash

export WORKSPACE="$HOME/code"
export DOTFILES="$WORKSPACE/.dotfiles"

setup_xcode_select() {
  if ! xcode-select -p &>/dev/null; then
    echo "installing xcode-select, this will take some time, please wait..."
    xcode-select --install
    echo "waiting for xcode-select installation to complete..."
    while ! xcode-select -p &>/dev/null; do
      sleep 20
    done
    echo "xcode-select installed."
  else
    echo "xcode-select is already installed."
  fi
}

backup_current_config() {
  source backup.sh
}

setup_github_ssh_key() {
  source setup/github-ssh.sh
}

setup_homebrew() {
  if [ "$(uname)" == "Darwin" ]; then
    source setup/brew.sh
  fi
}

clone_dotfiles() {
  source setup/clone-dotfiles.sh
}

setup_osx() {
  if [ "$(uname)" == "Darwin" ]; then
    source setup/osx.sh
  fi
}

setup_symlinks() {
  source setup/symlink.sh
}


mkdir -p $WORKSPACE

setup_xcode_select
setup_github_ssh_key
clone_dotfiles
backup_current_config
setup_homebrew
setup_symlinks
setup_osx
