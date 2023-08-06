#!/bin/bash
export SETUP_FOLDER=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

setup_osx() {
  if [ "$(uname)" == "Darwin" ]; then
    source setup/osx.sh
  fi
}

setup_homebrew() {
  if [ "$(uname)" == "Darwin" ]; then
    source setup/brew.sh
  fi
}

setup_symlinks() {
  source setup/symlink.sh
}

setup_default_shel() {
  # chsh -s $(which zsh)
  echo ""
}

case "$1" in
  homebrew)
    setup_homebrew
    ;;
  osx)
    setup_osx
    ;;
  symlinks)
    setup_symlinks
    ;;
  *)
    setup_symlinks
    setup_homebrew
    setup_osx
    setup_default_shell
    ;;
esac
