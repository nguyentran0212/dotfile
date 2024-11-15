#!/usr/bin/env bash

# Install software
sudo apt update -y
## Ubuntu essentials
echo "Installing essential packages..."
sudo apt install -y jq wget


## Languages
echo "Installing compilers and interpreters..."
### Java
echo "Java Runtime Environment..."
sudo apt install -y default-jre

### Conda and Python
echo "Conda and Python..."
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

### nvm
echo "NVM..."
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Install Terminal Tools
echo "Installing terminal and utilities..."
## ZSH and themes
sudo apt install -y zsh
chsh -s $(which zsh)

### Oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

## Terminal emulator kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
# Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
# your system-wide PATH)
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
# Place the kitty.desktop file somewhere it can be found by the OS
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
# If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
# Update the paths to the kitty and its icon in the kitty desktop file(s)
sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
# Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
echo 'kitty.desktop' > ~/.config/xdg-terminals.list

## Tmux
sudo apt install tmux
sh ./setup_tpm.sh

## Terminal tools
### NVIM
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.zshrc

### Dooit todo list manager
pip3 install dooit dooit-extras

### Other tools
sudo apt install htop neofetch fortune cowsay

# Reminder of manual setup steps
echo "Do the following steps to complete the setup..."
echo 'Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc'
echo 'Copy all the paths and necessary variables from .bashrc to .zshrc'
echo 'Open tmux, press Ctrl+Space, and then Shift+I to install plugins'
echo 'Open nvim, updates all packages, and then run :MasonInstallAll to install all LSP'
echo 'Run kitten choose-fonts and kitten themes to customise kitten theme'
