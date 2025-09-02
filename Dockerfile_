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

# Install core tools, LaTeX, pnpm, and man pages
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
      sudo git openssh xclip wl-clipboard go gcc-fortran openblas unzip curl tar ripgrep \
      python uv nodejs npm nvm pnpm nnn neovim zsh eza tmux ruby \
      texlive-basic	texlive-bibtexextra texlive-binextra texlive-fontsrecommended texlive-latex texlive-latexrecommended texlive-mathscience texlive-pictures texlive-publishers texlive-latexextra \
      man-db man-pages && \
    pacman -Scc --noconfirm && \
    rm -rf /tmp/*

# Create devcontainer user & install oh-my-zsh, theme & plugins
RUN useradd --create-home --shell /bin/zsh devcontainer && \
    echo "devcontainer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/devcontainer && \
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /usr/share/oh-my-zsh && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k && \
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
    PATH=$GEM_HOME/bin:/home/devcontainer/.local/bin:/home/devcontainer/.uv/tools/aider-chat/latest/bin:$PATH

COPY --chown=devcontainer:devcontainer .zshrc .zshrc
COPY --chown=devcontainer:devcontainer .p10k.zsh .p10k.zsh
COPY --chown=devcontainer:devcontainer .config/nvim .config/nvim
COPY --chown=devcontainer:devcontainer .config/tmux .config/tmux
COPY --chown=devcontainer:devcontainer setup_tpm.sh setup_tpm.sh

# Install Python 3.12 and aider-chat via uv (no AUR builds, no pipx)
RUN uv python install 3.12 && \
    uv tool install --force --python python3.12 aider-chat@latest && \
    uv tool update-shell >> ~/.zprofile

# Automate Neovim setup.
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonInstallAll" +qa

# Run tmux plugin setup
RUN chmod +x setup_tpm.sh && \
    ./setup_tpm.sh

# Setup Ruby and bundler
RUN \
    # Step 1: Discover the correct GEM_HOME path at build time.
    GEM_HOME="$(ruby -e 'puts Gem.user_dir')" && \
    \
    # Step 2: Export the variables for the *current* RUN command.
    # This ensures 'gem install' uses the correct paths right now.
    export GEM_HOME="$GEM_HOME" && \
    export PATH="$GEM_HOME/bin:$PATH" && \
    \
    # Step 3: Persist these variables for the *runtime* interactive shell.
    # This writes the dynamic export commands to the Zsh profile.
    echo '' >> ~/.zprofile && \
    echo '# Set up Ruby environment' >> ~/.zprofile && \
    echo 'export GEM_HOME="$(ruby -e '\''puts Gem.user_dir'\'')"' >> ~/.zprofile && \
    echo 'export PATH="$GEM_HOME/bin:$PATH"' >> ~/.zprofile && \
    \
    # Step 4: Now, run the gem installation.
    # It will succeed because the environment is correctly configured for this layer.
    gem install bundler

# Preinstall pnpm tools
RUN pnpm add -g @qwen-code/qwen-code@latest @google/gemini-cli

# Entry point
CMD ["/bin/zsh"]
