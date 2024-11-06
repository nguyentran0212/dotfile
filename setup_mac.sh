#!/usr/bin/env zsh

# Install xCode cli tools
echo "Installing commandline tools..."
xcode-select --install

# Homebrew
## Install
echo "Installing Brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

## Taps
echo "Tapping Brew..."
brew tap homebrew/cask-fonts
brew tap FelixKratz/formulae
brew tap koekeishiya/formulae

## Formulae
echo "Installing Brew Formulae..."
### Essentials
brew install jq
brew install ripgrep
brew install gh
brew install ifstat
brew install switchaudio-osx
brew install skhd
brew install sketchybar
brew install borders
brew install yabai

### Terminal
brew install neovim
brew install starship
brew install zsh-autosuggestions
brew install zsh-fast-syntax-highlighting

### Nice to have
brew install htop
brew install svim
brew install lazygit
brew install dooit

## Casks
echo "Installing Brew Casks..."
### Terminals & Browsers
# brew install --cask alacritty
brew install --cask kitty
# brew install --cask orion

### Office
# brew install --cask inkscape
# brew install --cask libreoffice
# brew install --cask zoom
# brew install --cask meetingbar
# brew install --cask skim
# brew install --cask vlc

### Reversing
# brew install --cask machoview
# brew install --cask hex-fiend
# brew install --cask cutter
# brew install --cask sloth

### Nice to have
# brew install --cask alfred

### Fonts
brew install --cask sf-symbols
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono
brew install --cask font-fira-code

# Mac App Store Apps
echo "Installing Mac App Store Apps..."
# mas install 1451685025 #Wireguard
# mas install 497799835 #xCode
# mas install 1480933944 #Vimari

# macOS Settings
echo "Changing macOS defaults..."
# defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1
# defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# defaults write com.apple.spaces spans-displays -bool false
# defaults write com.apple.dock autohide -bool true
# defaults write com.apple.dock "mru-spaces" -bool "false"
# defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
# defaults write com.apple.LaunchServices LSQuarantine -bool false
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# defaults write NSGlobalDomain KeyRepeat -int 1
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# defaults write NSGlobalDomain _HIHideMenuBar -bool true
# defaults write NSGlobalDomain AppleHighlightColor -string "0.65098 0.85490 0.58431"
# defaults write NSGlobalDomain AppleAccentColor -int 1
# defaults write com.apple.screencapture location -string "$HOME/Desktop"
# defaults write com.apple.screencapture disable-shadow -bool true
# defaults write com.apple.screencapture type -string "png"
# defaults write com.apple.finder DisableAllAnimations -bool true
# defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
# defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
# defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
# defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
# defaults write com.apple.Finder AppleShowAllFiles -bool true
# defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# defaults write com.apple.finder ShowStatusBar -bool false
# defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool YES
# defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
# defaults write com.apple.Safari IncludeDevelopMenu -bool true
# defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
# defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
# defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
# defaults write -g NSWindowShouldDragOnGesture YES


source $HOME/.zshrc

# Start Services
echo "Starting Services (grant permissions)..."
brew services start skhd
brew services start yabai
brew services start sketchybar
brew services start borders

csrutil status
echo "(optional) Disable SIP for advanced yabai features."
# TODO: check if the line exist in sudoer and skip if it exists
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
echo "Installation complete...\n"

