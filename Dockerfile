# It is recommended to pin this to a specific digest for reproducible builds.
# e.g., FROM archlinux:base-devel@sha256:....
FROM archlinux:base-devel

# Update system, populate package file database, and install all required packages.
# `unzip` is a dependency for mason.nvim. `pacman -Fy` is for command-not-found handler.
RUN pacman -Syu --noconfirm && \
    pacman -Fy && \
    pacman -S --noconfirm \
    sudo \
    git \
    go \
    gcc-fortran \
    openblas \
    unzip \
    python \
    uv \
    nodejs \
    npm \
    nvm \
    nnn \
    neovim \
    zsh \
    eza

# Install pnpm globally via npm.
RUN npm install -g pnpm

# Install yay AUR Helper. It must be built as a non-root user.
RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
    cd /tmp && \
    sudo -u builder git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    sudo -u builder makepkg -si --noconfirm && \
    cd / && rm -rf /tmp/yay && \
    userdel -r builder && rm /etc/sudoers.d/builder

# Create a non-root user 'devcontainer', set its shell to zsh, and grant passwordless sudo.
RUN useradd --create-home --shell /bin/zsh devcontainer && \
    echo "devcontainer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/devcontainer

# Switch to the new user.
USER devcontainer
WORKDIR /home/devcontainer
ENV HOME=/home/devcontainer

# Install Oh-My-Zsh and Powerlevel10k from AUR using the correct package names
RUN yay -S --noconfirm oh-my-zsh-git zsh-theme-powerlevel10k-git

# Switch to root to install plugins into system directory
USER root

# Install zsh plugins by cloning them directly to conform to .zshrc
RUN ZSH_PLUGINS_DIR=/usr/share/oh-my-zsh/plugins && \
    git -c credential.helper= clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_PLUGINS_DIR}/zsh-autosuggestions && \
    git -c credential.helper= clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting && \
    git -c credential.helper= clone https://github.com/Tarrasch/zsh-256color ${ZSH_PLUGINS_DIR}/zsh-256color

# Switch back to the devcontainer user
USER devcontainer

# Copy user configuration files from the local machine into the container.
COPY --chown=devcontainer:devcontainer .zshrc /home/devcontainer/.zshrc
COPY --chown=devcontainer:devcontainer .config/nvim /home/devcontainer/.config/nvim

# Ensure uv’s shim dir is on PATH and tell uv we’re in zsh
ENV SHELL=/bin/zsh \
    PATH=/home/devcontainer/.local/bin:$PATH

# Install Python 3.12 and aider-chat via uv (no AUR builds, no pipx)
RUN uv python install 3.12 && \
    uv tool install --force --python python3.12 aider-chat@latest && \
    uv tool update-shell >> /home/devcontainer/.zprofile

# Finally, include the aider binary dir in the default PATH
ENV PATH=/home/devcontainer/.uv/tools/aider-chat/latest/bin:$PATH

# Automate Neovim setup.
# 1. Install all plugins defined in the configuration via lazy.nvim.
RUN nvim --headless "+Lazy! sync" +qa

# 2. Install all LSPs, formatters, and linters managed by Mason, using NvChad's custom command.
RUN nvim --headless "+MasonInstallAll" +qa

# Set the default command for the container to launch the zsh shell.
CMD ["/bin/zsh"]
