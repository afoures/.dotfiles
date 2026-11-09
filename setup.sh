#!/usr/bin/env bash

set -euo pipefail

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
  local new_key=false

  # a fresh macOS has no ~/.ssh, and ssh-keygen -f won't create it
  mkdir -p -m 700 "$HOME/.ssh"

  if [ ! -f "$SSH_KEY" ]; then
    echo "generating a new ssh key..."
    read -rp "enter your github email: " EMAIL
    # ssh-keygen prompts for the passphrase; it is stored in the macOS keychain
    # below, so it only has to be typed once
    while ! ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY"; do
      echo "key generation failed (passphrases must match), try again."
    done
    echo "ssh key generated."
    new_key=true
  else
    echo "ssh key already exists. skipping generation."
  fi

  eval "$(ssh-agent -s)"
  ssh-add --apple-use-keychain "$SSH_KEY"

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

  # an existing key is assumed to already be on github
  if [ "$new_key" = "true" ]; then
    echo ""
    echo "your public ssh key (already copied to your clipboard):"
    cat "${SSH_KEY}.pub"
    pbcopy < "${SSH_KEY}.pub"

    read -rp "add it to github, then press enter to continue"
  fi
}

clone_and_update_repository() {
  local repository=$1
  local git_repo="git@github.com:$repository.git"
  local path="$2"
  local update_submodules=$3

  # check if the directory exists
  if [ -d "$path" ]; then
    # check if directory is empty
    if [ ! "$(ls -A "$path")" ]; then
      echo "directory exists but is empty. removing and cloning '$repository'..."
      rm -rf "$path"
      git clone "$git_repo" "$path" >/dev/null 2>&1
    else
      echo "repository '$repository' already exists. pulling latest changes..."
      (cd "$path" && git pull)
    fi
  else
    echo "cloning repository '$repository'..."
    git clone "$git_repo" "$path" >/dev/null 2>&1
  fi

  if [ ! -d "$path" ]; then
    echo "warning: failed to clone the '$repository' repo. check this manually."
    return 1
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
    
    eval "$(/opt/homebrew/bin/brew shellenv)"

    brew bundle --file="$DOTFILES/brew/default-setup"

    # optionally uninstall packages not listed in the brewfile.
    # note: cleanup is per-file, so when using extra brewfiles for non-default
    # setups, running this against default-setup will flag their packages too.
    read -p "remove brew packages not in default-setup? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      brew bundle cleanup --force --file="$DOTFILES/brew/default-setup"
    fi
  fi
}

# mise is installed with its standalone installer (not brew) into ~/.local/bin,
# then installs the tools pinned in config/mise/config.toml
setup_mise() {
  local mise_bin="$HOME/.local/bin/mise"

  if ! command -v mise &>/dev/null && [ ! -x "$mise_bin" ]; then
    echo "installing mise..."
    curl -fsSL https://mise.run | sh
    echo "mise installed."
  else
    echo "mise is already installed."
  fi

  if [ -x "$mise_bin" ]; then
    "$mise_bin" install
  else
    mise install
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
    mkdir -p "$HOME/Pictures/screenshots"
    defaults write com.apple.screencapture "location" -string "$HOME/Pictures/screenshots"

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

    for app in Safari Finder Dock Mail SystemUIServer ControlCenter; do killall "$app" >/dev/null 2>&1 || true; done
  fi
}

setup_fonts() {
  if [ "$(uname)" == "Darwin" ]; then
    local font_src
    font_src=$(mktemp -d "/tmp/fonts.XXXXXX")
    local font_dst="$HOME/Library/Fonts"

    if ! clone_and_update_repository afoures/fonts "$font_src" false; then
      echo "warning: skipping font installation."
      rm -rf "$font_src"
      return
    fi

    mkdir -p "$font_dst"
    find "$font_src" -type f \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' \) -print0 \
      | while IFS= read -r -d '' font; do
          cp -f "$font" "$font_dst/"
          echo "installed font: $(basename "$font")"
        done

    rm -rf "$font_src"
  fi
}

# move an existing path into a fresh backup snapshot before it gets replaced,
# so `setup.sh symlinks` is safe to run without the full bootstrap backup
backup_path() {
  local target_path=$1
  local backup_subdir=$2
  local backup_dir="$DOTFILES/.backups/backup_$(date +%s)/$backup_subdir"

  mkdir -p "$backup_dir"
  mv "$target_path" "$backup_dir/"
  echo "backed up ${target_path/#$HOME/~} to ${backup_dir/#$HOME/~}"
}

setup_symlinks() {
  echo "this will create symlinks for all config directories"
  read -p "confirm (y/n)? " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    echo "skipping symlinks."
    return 0
  fi

  # Create .config directory if it doesn't exist
  if [[ ! -d "$HOME/.config" ]]; then
    mkdir -p "$HOME/.config"
    echo "created $HOME/.config directory"
  fi

  # Symlink each config directory individually
  for config_dir in "$DOTFILES/config"/*/; do
    if [[ -d "$config_dir" ]]; then
      # the glob adds a trailing slash; links are stored without it
      config_dir="${config_dir%/}"
      config_name=$(basename "$config_dir")
      target_path="$HOME/.config/$config_name"

      if [[ -L "$target_path" ]]; then
        current_target="$(readlink "$target_path")"
        if [[ "$current_target" == "$config_dir" ]]; then
          echo "symlink for $config_name already exists and is correct, skipping"
          continue
        fi
        # our own link, written with a trailing slash by older versions
        if [[ "${current_target%/}" == "$config_dir" ]]; then
          ln -sfn "$config_dir" "$target_path"
          echo "healed symlink for $config_name - removed trailing slash"
          continue
        fi
      fi

      if [[ -e "$target_path" || -L "$target_path" ]]; then
        backup_path "$target_path" ".config"
      fi

      ln -s "$config_dir" "$target_path"
      echo "created symlink for $config_name"
    fi
  done

  # Handle .zshenv separately
  if [[ -L "$HOME/.zshenv" && "$(readlink "$HOME/.zshenv")" == "$HOME/.config/zsh/.zshenv" ]]; then
    echo ".zshenv symlink already correct, skipping"
  else
    if [[ -e "$HOME/.zshenv" || -L "$HOME/.zshenv" ]]; then
      backup_path "$HOME/.zshenv" ""
    fi
    ln -s "$HOME/.config/zsh/.zshenv" "$HOME/.zshenv"
    echo "created symlink for $HOME/.zshenv"
  fi
}


usage() {
  cat <<EOF
usage: setup.sh [command]

  (no arg)   run the full bootstrap
  fonts      install fonts only
  macos      apply macOS defaults only
  brew       install Homebrew + run brew bundle only
  mise       install mise + the tools in config/mise/config.toml only
  symlinks   link config dirs into ~/.config only
  help       show this message
EOF
}

run_all() {
  mkdir -p "$WORKSPACE"
  setup_xcode_select
  setup_github_ssh_key
  clone_and_update_repository afoures/.dotfiles "$DOTFILES" true || exit 1
  backup_current_config
  setup_homebrew
  setup_symlinks
  setup_mise
  setup_fonts
  setup_osx
}

case "${1:-all}" in
  all)            run_all ;;
  fonts)          setup_fonts ;;
  macos)          setup_osx ;;
  brew)           setup_homebrew ;;
  mise)           setup_mise ;;
  symlinks)       setup_symlinks ;;
  help|-h|--help) usage ;;
  *)              echo "unknown command: $1" >&2; usage; exit 1 ;;
esac
