# dotfile of GenTran0212

This folder contains tool configurations and scripts to start workspaces.

List of supported tool configurations:

- Neovim (`./nvim/`): this dotfile is based on the starter config of NvChad

## How to use

### Prerequisites: 

`tmux`: workspace is created as tmux session and windows. Therefore, tmux must be present on the computer.

### Basic usage

This repository has only been tested on Mac and Linux

1. Clone the repository to home directory
2. (First time) Run `./set_symlinks.sh` to symlink the configurations from this repository to the necessary folders 
3. (First time, on a new computer) `cp .env.example .env` to create an env file and add workspace name and directory
4. Run `./start_workspace.sh workspace_name` to start a workspace

