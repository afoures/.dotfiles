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
  source $DOTFILES/backup.sh
}

setup_github_ssh_key() {
  SSH_KEY="$HOME/.ssh/id_ed25519_github"
  SSH_CONFIG="$HOME/.ssh/config"

  if [ ! -f "$SSH_KEY" ]; then
    echo "generating a new ssh key..."
    read -rp "enter your github email: " EMAIL
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N ""
    echo "ssh key generated."
  else
    echo "ssh key already exists. skipping generation."
  fi

  eval "$(ssh-agent -s)"
  ssh-add -K "$SSH_KEY"

  if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    echo "setting up ssh config for GitHub..."
    {
      echo ""
      echo "Host github.com"
      echo "  HostName github.com"
      echo "  User git"
      echo "  IdentityFile $SSH_KEY"
      echo "  AddKeysToAgent yes"
      echo "  UseKeychain yes"
    } >> "$SSH_CONFIG"
    echo "ssh config updated."
  else
      echo "ssh config for GitHub already exists. skipping."
  fi

  echo ""
  echo "your public ssh key (already copied to your clipboard):"
  cat "${SSH_KEY}.pub"
  cat "${SSH_KEY}.pub" | pbcopy

  read -rp "make sure to add it to github"
}

clone_and_update_repository() {
  local repository=$1
  local git_repo="git@github.com:$repository.git"
  local path="$2"
  local update_submodules=$3

  # check if the directory exists
  if [ -d "$path" ]; then
    # check if directory is empty
    if [ "$(ls -A "$path")" ]; then
      echo "repository directory exists but is effectively empty. removing and cloning '$repo_name'..."
      rm -rf "$path"
      git clone "$git_repo" "$path" >/dev/null 2>&1
    elif [ "$(ls -A "$path")" ]; then
      echo "repository '$repository' already exists. pulling latest changes..."
      cd "$path" && git pull
    fi
  else
    echo "cloning repository '$repository'..."
    git clone "$git_repo" "$path" >/dev/null 2>&1
  fi

  if [ ! -d "$path" ]; then
    echo "warning: failed to clone the '$repository' repo. check this manually."
    exit 1
  fi

  if [ "$update_submodules" = "true" ]; then
    if [ -f "$path/.gitmodules" ]; then
      echo "submodules detected. initializing and updating..."
      git -C "$path" submodule update --init --recursive
    else
      echo "warning: submodules were requested, but no '.gitmodules' file found in '$path'."
    fi
  fi
}

setup_homebrew() {
  if [ "$(uname)" == "Darwin" ]; then
    if ! command -v brew &>/dev/null; then
      echo "installing brew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo "homebrew installed successfully."
    else
      echo "homebrew is already installed."
    fi
    
    echo >> $DOTFILES/config/zsh/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $DOTFILES/config/zsh/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    brew bundle --file=$DOTFILES/brew/default-setup
  fi
}

setup_osx() {
  if [ "$(uname)" == "Darwin" ]; then
    # used https://macos-defaults.com as reference
    # you can see all macos defaults with `defaults read`
    # make sure that your terminal has full disk access for it to work

    # dock
    defaults write com.apple.dock "orientation" -string "bottom"
    defaults write com.apple.dock "tilesize" -int "40"
    defaults write com.apple.dock "autohide" -bool "true"
    defaults write com.apple.dock "autohide-time-modifier" -float "0.5"
    defaults write com.apple.dock "autohide-delay" -float "0"
    defaults write com.apple.dock "show-recents" -bool "false"
    defaults write com.apple.dock "magnification" -float "0"

    # screenshots
    defaults write com.apple.screencapture "include-date" -bool "true"
    mkdir -p "~/Pictures/screenshots"
    defaults write com.apple.screencapture "location" -string "~/Pictures/screenshots"

    # safari
    defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool "true"
    defaults write com.apple.Safari "IncludeDevelopMenu" -bool "true"
    defaults write com.apple.Safari "AlwaysRestoreSessionAtLaunch" -bool "true"
    defaults write com.apple.Safari "AlwaysShowTabBar" -bool "true"
    defaults write com.apple.Safari "AutoOpenSafeDownloads" -bool "false"
    defaults write com.apple.Safari "EnableNarrowTabs" -bool "false"
    defaults write com.apple.Safari "WebKitPreferences.tabFocusesLinks" -bool "true"

    # finder
    defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
    defaults write NSGlobalDomain "NSNavPanelExpandedStateForSaveMode" -bool "true"
    defaults write com.apple.finder "AppleShowAllFiles" -bool "true"
    defaults write com.apple.finder "ShowPathbar" -bool "true"
    defaults write com.apple.finder "ShowStatusBar" -bool "true"
    defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"
    defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
    defaults write com.apple.finder "FinderSpawnTab" -bool "false"
    defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"
    defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "false"
    defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false"
    defaults write com.apple.universalaccess "showWindowTitlebarIcons" -bool "true"

    chflags nohidden ~/Library

    # menu bar
    defaults write com.apple.menuextra.clock "FlashDateSeparators" -bool "false"
    defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm:ss\""

    # control center
    defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool "true"
    defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool "true"
    defaults -currentHost write com.apple.controlcenter "BatteryShowPercentage" -bool "true"
    defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool "true"
    defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool "true"

    # keyboard
    defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "false"
    defaults write NSGlobalDomain "AppleKeyboardUIMode" -int "2"
    defaults write NSGlobalDomain "InitialKeyRepeat" -int "15"
    defaults write NSGlobalDomain "KeyRepeat" -int "1"

    # external screens
    defaults write NSGlobalDomain AppleFontSmoothing -int 2

    for app in Safari Finder Dock Mail SystemUIServer ControlCenter; do killall "$app" >/dev/null 2>&1; done
  fi
}

setup_symlinks() {
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
}


mkdir -p $WORKSPACE

setup_xcode_select
setup_github_ssh_key
clone_and_update_repository afoures/.dotfiles $DOTFILES true
backup_current_config
setup_homebrew
setup_symlinks
setup_osx
