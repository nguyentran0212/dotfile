✦ Dotfiles Configuration Project

Overview

This repository contains configuration files and scripts for setting up development environments, primarily focused on Arch Linux systems. It includes dotfiles managed with yadm along
with configurations for various tools like Neovim, tmux, zsh with Powerlevel10k theme, and more.

The repository also contains a Dockerfile and devcontainer templates that create reproducible development environments using these same configuration files.

Project Structure

1 .
2 ├── README.md          # Main documentation
3 ├── setup_mac.sh       # macOS setup script (not used in primary Arch Linux workflow)
4 ├── setup_tpm.sh       # Setup script for tmux plugin manager
5 ├── setup_ubuntu.sh    # Ubuntu setup script (not used in primary Arch Linux workflow)
6 ├── .zshrc             # ZSH configuration file with custom aliases and functions
7 ├── .p10k.zsh          # Powerlevel10k theme configuration
8 ├── Dockerfile         # Devcontainer image definition
9 ├── devcontainer-templates/  # Templates for devcontainer.json files
10 ├── .config/           # Configuration directory with various tool configs
11 │   ├── nvim/          # Neovim configuration (based on NvChad)
12 │   ├── tmux/          # Tmux configuration
13 │   └── ...             # Other tool configurations
14 └── ...

Key Features

- Dotfile Management: Uses yadm for managing dotfiles in the home directory, primarily used with Arch Linux systems
- Arch Linux Optimized: Designed specifically for Arch Linux environments with solid bootstrap scripts (not included in this repo)
- Devcontainer Support: Includes Dockerfile and devcontainer templates to create reproducible development environments using these same configurations
- Cross-platform Development: Enables consistent development environment across different machines through containerization
- Custom ZSH Configuration: Includes Powerlevel10k theme with custom aliases, functions for package management, and taskwarrior integration

Usage Instructions

Prerequisites:
- yadm: Used to manage dotfiles in the home directory (primary Arch Linux workflow)
- tmux: Required for workspace management
- jq: Utility for parsing JSON files
- zsh and oh-my-zsh
- Powerlevel10k theme

Basic Usage:

1. Clone repository using yadm to your home directory:
 
yadm clone git@github.com:nguyentran0212/dotfile.git

2. Setup tmux plugin manager (first time only):

./setup_tpm.sh

3. Create configuration file from example:

cp .configs.example.json configs.json

4. Start a workspace:

./start_workspace.sh workspace_name

Devcontainer Usage:

1. Use the devcontainer templates in devcontainer-templates/ to create .devcontainer/devcontainer.json
2. Build and run using VS Code or other compatible IDEs that support devcontainers

Development Conventions

ZSH Configuration:
The .zshrc file includes:
- Powerlevel10k theme with custom aliases
- Custom functions for package management (in, aurhelper)
- Aliases for common tasks like navigation and taskwarrior integration
- Integration with nvm (Node Version Manager)
- Custom functions for directory navigation

Neovim Configuration:
Based on NvChad, using lazy loading for plugins. The configuration includes:
- Plugin management via lazy.nvim
- Base46 theme caching system
- Custom mappings and options

Building and Running

This is a dotfiles repository that doesn't require building in the traditional sense:

1. Clone with yadm to your home directory (primary Arch Linux workflow)
2. For containerized development:
  - Use Dockerfile to build devcontainer image
  - Create .devcontainer/devcontainer.json using templates from devcontainer-templates/
  - Run in VS Code or compatible IDE

Contributing

To add support for more project types:

1. Copy the script ./scripts/start_workspace_template.sh
2. Modify to add your tmux workspace configuration inside
3. Modify ./start_workspace.sh to add your script to the switch-case statement
4. Add your workspace in ./configs.json

Notes

- The repository is primarily optimized for Arch Linux systems with solid bootstrap scripts (not included)
- Configuration files are organized under .config/ directory for various tools
- Custom aliases and functions are included to enhance productivity
- Devcontainer support enables consistent development environments across different machines

Additional Bash Scripts

- devc.sh: A wrapper around the devcontainer CLI that simplifies working with devcontainers from the command line, ideal for developers who use Neovim and other CLI tools instead of VS Code.