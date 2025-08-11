# It is recommended to pin this to a specific digest for reproducible builds.
# e.g., FROM archlinux:base-devel@sha256:....
FROM archlinux:base-devel@sha256:15d3106aaf0e01eaeabf8ad9ba90924152f12848aaf6721bcecabaed16ee8523 AS builder

# Build yay AUR Helper in a separate builder stage
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm git base-devel && \
    useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
    sudo -u builder git clone https://aur.archlinux.org/yay.git /tmp/yay && \
    cd /tmp/yay && \
    sudo -u builder makepkg -si --noconfirm && \
    pacman -Scc --noconfirm && \
    rm -rf /tmp/yay /var/cache/pacman/pkg/*

FROM archlinux:base-devel@sha256:15d3106aaf0e01eaeabf8ad9ba90924152f12848aaf6721bcecabaed16ee8523

# Copy yay binary from builder stage
COPY --from=builder /usr/bin/yay /usr/bin/yay

# Install core tools, LaTeX, and pnpm
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
      sudo git go gcc-fortran openblas unzip curl tar \
      python uv nodejs npm nvm pnpm nnn neovim zsh eza \
      texlive-core texlive-latexextra texlive-bibtexextra biber && \
    pacman -Scc --noconfirm && \
    rm -rf /tmp/*

# Create devcontainer user & install oh-my-zsh, theme & plugins
RUN useradd --create-home --shell /bin/zsh devcontainer && \
    echo "devcontainer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/devcontainer && \
    yay -S --noconfirm oh-my-zsh-git zsh-theme-powerlevel10k-git && \
    ZSH_PLUGINS=/usr/share/oh-my-zsh/plugins && \
    mkdir -p $ZSH_PLUGINS/{zsh-autosuggestions,zsh-syntax-highlighting,zsh-256color} && \
    cd /tmp && \
      curl -L https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.tar.gz | \
        tar -xzf - --strip-components=1 -C $ZSH_PLUGINS/zsh-autosuggestions && \
      curl -L https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.tar.gz | \
        tar -xzf - --strip-components=1 -C $ZSH_PLUGINS/zsh-syntax-highlighting && \
      curl -L https://github.com/chrissicool/zsh-256color/archive/refs/heads/master.tar.gz | \
        tar -xzf - --strip-components=1 -C $ZSH_PLUGINS/zsh-256color && \
    pacman -Scc --noconfirm && \
    rm -rf /tmp/*

USER devcontainer
WORKDIR /home/devcontainer
ENV HOME=/home/devcontainer \
    SHELL=/bin/zsh \
    PATH=/home/devcontainer/.local/bin:/home/devcontainer/.uv/tools/aider-chat/latest/bin:$PATH

COPY --chown=devcontainer:devcontainer .zshrc .zshrc
COPY --chown=devcontainer:devcontainer .config/nvim .config/nvim

# Install Python 3.12 and aider-chat via uv (no AUR builds, no pipx)
RUN uv python install 3.12 && \
    uv tool install --force --python python3.12 aider-chat@latest && \
    uv tool update-shell >> ~/.zprofile

# Automate Neovim setup.
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonInstallAll" +qa

CMD ["/bin/zsh"]
