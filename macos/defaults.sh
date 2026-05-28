#!/usr/bin/env bash
# macOS system preferences — run once on new Mac
# Restart required for some settings to take effect

echo "==> Applying macOS defaults..."

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48

# Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"  # list view
defaults write com.apple.finder AppleShowAllFiles -bool true          # show hidden files
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Screenshots
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false  # natural scroll off

# Safari
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Restart affected apps
killall Dock Finder 2>/dev/null || true

echo "==> macOS defaults applied. Restart for full effect."
