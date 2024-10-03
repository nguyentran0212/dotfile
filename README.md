# dotfile of GenTran0212

This folder contains tool configurations and scripts to start workspaces.

List of supported tool configurations:

- Neovim (`./nvim/`): this dotfile is based on the starter config of NvChad

## How to use

### Prerequisites: 

`tmux`: workspace is created as tmux session and windows. Therefore, tmux must be present on the computer.
`jq`: this utility is used to parse `configs.json`. `start_workspace.sh` script would not work without this utility. 

### Basic usage

This repository has only been tested on Mac and Linux

1. Clone the repository to home directory
2. (First time) Run `./set_symlinks.sh` to symlink the configurations from this repository to the necessary folders 
3. (First time, on a new computer) `cp configs.example.json configs.json` to create an env file and add workspace name, working directory, workspace type, and other necessary parameters
4. Run `./start_workspace.sh workspace_name` to start a workspace

### Modification

Do the following to add support for more types of projects:

1. Copy the script `./scripts/start_workspace_template.sh` 
2. Modify to add your tmux workspace configuration inside
3. Modify `./start_workspace.sh` to add your script to the switch-case statement
4. Add your workspace in `./configs.json`

