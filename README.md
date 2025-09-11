# dotfile of GenTran0212

This repository is my deliberate approach to computer use - a carefully selected set of tools and configurations that I use across all my development machines. It contains my personal dotfiles for setting up a consistent development environment on Arch Linux, Fedora, and macOS machines, ensuring that any machine I pick up has an identical development environment.

The repository also includes my own utilities stored in `.local/bin` and defines a development container (devcontainer) based on Arch Linux, pre-installed with necessary development tools and configured using these same dotfiles.

## Philosophy

Rather than adapting to different environments on different machines, I've chosen to create one environment that follows me everywhere. This approach allows me to:
- Be more efficient by not having to relearn different tool configurations
- Maintain consistency in my development workflow
- Extend this environment to new projects through devcontainer templates

## List of Supported Tool Configurations

- **Neovim** (`.config/nvim/`): Configuration based on the NvChad starter setup.
- **tmux** (`.config/tmux/`): Includes custom keybindings, appearance settings, and plugin configurations (TPM, Dracula theme, Pomodoro).
- **zsh** (`.zshrc`, `.p10k.zsh`): Configured with Oh-My-Zsh, Powerlevel10k theme, syntax highlighting, autosuggestions, and numerous productivity aliases.
- **Other tools**: Configurations for Kitty terminal, Hyprland window manager, Sketchybar, Skhd, Taskwarrior, and Yabai are also included in `.config/`.

## How to Use

### Prerequisites (Using Dotfiles Natively)

Before applying these dotfiles on a host machine, ensure the following tools are installed:

- `yadm`: For managing dotfiles. We need it because we cannot simply `git clone` the dotfile repository into the home directory.
- `tmux`: For terminal multiplexing.
- `jq`: Utility for parsing JSON (used by some scripts).
- `zsh`: The preferred shell.
- `oh-my-zsh`: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

### Basic Usage (Using Dotfiles Natively)

This repository has been tested on various Linux distributions (Ubuntu, RedHat, Arch Linux) and macOS.

1.  **Clone the repository to your home directory using `yadm`**:
    ```bash
    yadm clone git@github.com:nguyentran0212/dotfile.git
    ```
2.  **(First time) Run `./setup_tpm.sh` to setup the tmux package manager (TPM)**.
3.  After cloning, `yadm` should have placed the configuration files in their respective locations. Start a new `zsh` session or reload your shell to apply the configurations. You might need to start a `tmux` session and use the TPM install keybinding (often `Prefix + I`) to install the plugins listed in the tmux configuration.

### Using the Devcontainer

This repository also defines a development container based on Arch Linux.

#### Prerequisites (Using Devcontainer)

- Docker (or Podman)
- `devcontainer-cli`: Install globally using `npm install -g @vscode/devcontainers-cli`. (Optional if only using VS Code)

#### Building the Devcontainer Image

1.  Navigate to the root of this repository.
2.  Build the Docker image:
    ```bash
    docker build -t dotfile-devcontainer:latest .
    ```

#### Running the Devcontainer

You can run the devcontainer interactively, use it with VS Code Dev Containers, or use the provided helper script.

1.  **Run Interactively (Docker command)**:
    ```bash
    # Run the container interactively with a zsh shell
    docker run -it --rm dotfile-devcontainer:latest zsh
    ```

2.  **Using with VS Code Dev Containers**:
    -   Ensure you have the "Dev Containers" extension installed in VS Code.
    -   Open the repository folder in VS Code.
    -   Use the command palette (`Ctrl+Shift+P` or `Cmd+Shift+P`) and run "Dev Containers: Reopen in Container".

3.  **Using the `devc.sh` Script (Terminal Focused Workflow)**:
    For a more streamlined terminal experience, especially if not using VS Code, use the helper script `~/.local/bin/devc.sh`.
    -   **Start the container**: `~/.local/bin/devc.sh up`
    -   **Open a shell**: `~/.local/bin/devc.sh shell`
    -   **Stop the container**: `~/.local/bin/devc.sh stop` or `~/.local/bin/devc.sh down`
    -   See `~/.local/bin/devc.sh` or run `~/.local/bin/devc.sh` for more available commands.

4.  **Using Devcontainer Templates**:
    Pre-configured templates for new projects are available in `devcontainer-templates/`. These templates are set up to build the image defined by this repository's `Dockerfile` and include configurations for sharing display/clipboard between host and container.
    -   Copy `devcontainer-templates/devcontainer.wayland.json` or `devcontainer-templates/devcontainer.x11.json` to your new project's `.devcontainer/devcontainer.json`.
    -   Use `devc.sh` or VS Code Dev Containers from within your project directory.