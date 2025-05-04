#!/usr/bin/env bash

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
