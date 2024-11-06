# dotfile of GenTran0212

This folder contains tool configurations and scripts to start workspaces.

List of supported tool configurations:

- Neovim (`./nvim/`): this dotfile is based on the starter config of NvChad
- tmux (`./tmux/`)

## How to use

### Prerequisites: 

- `yadm`: this tool is used to manage dotfiles in the home directory. We need it because we cannot simply `git clone` the dotfile repository into the home directory
- `tmux`: workspace is created as tmux session and windows. Therefore, tmux must be present on the computer.
- `jq`: this utility is used to parse `configs.json`. `start_workspace.sh` script would not work without this utility. 
- `zsh`
- `oh-my-zsh`: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`



### Basic usage

This repository has only been tested on MacOS 14, MacOS 13, Ubuntu 20.04, and PopOS.

1. Clone the repository to home directory **using yadm**: `yadm clone git@github.com:nguyentran0212/dotfile.git`
2. (First time) Run `./setup_tpm.sh` to setup tmux package manager. 
3. (First time, on a new computer) `cp .configs.example.json configs.json` to create an env file and add workspace name, working directory, workspace type, and other necessary parameters
4. Run `./start_workspace.sh workspace_name` to start a workspace

### Modification

Do the following to add support for more types of projects:

1. Copy the script `./scripts/start_workspace_template.sh` 
2. Modify to add your tmux workspace configuration inside
3. Modify `./start_workspace.sh` to add your script to the switch-case statement
4. Add your workspace in `./configs.json`

