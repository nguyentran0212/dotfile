# ------------------------------------------------------------
# 1️⃣  Runtime image (single‑stage – no AUR, direct Ubuntu base)
# ------------------------------------------------------------
FROM ubuntu:25.04
# ------------------------------------------------------------
# 2️⃣  Install system‑wide packages (apt-get) – must be root
# ------------------------------------------------------------
RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        sudo \
        git \
        openssh-client \
        openssl \
        xclip \
        wl-clipboard \
        ripgrep \
        unzip \
        curl \
        tar \
        nnn \
        zsh \
        eza \
        tmux \
        inetutils-tools \
        dnsutils \
        traceroute \
        tcpdump \
        golang-go \
        gfortran \
        libopenblas-dev \
        python3 \
        ruby \
        texlive-latex-extra \
        fonts-powerline \
        fonts-firacode \
        fonts-hack-ttf \
        && mkdir -p /usr/local/share/fonts \
        && curl -L -o /usr/local/share/fonts/NerdFontsSymbols.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip \
        && unzip /usr/local/share/fonts/NerdFontsSymbols.zip -d /usr/local/share/fonts \
        && fc-cache -fv
# ------------------------------------------------------------
# Install latest Neovim (replaces older Ubuntu version) – must be root
# ------------------------------------------------------------
# FIX: Old Ubuntu Neovim lacks 'uv' module, causing errors with your init.lua. Download and install latest stable from official releases.
RUN curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | \
    tar zx -C /opt && \
    ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim
# ------------------------------------------------------------
# Install UV (Python tool manager) system-wide (matching original's uv installation)
# ------------------------------------------------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | UV_UNMANAGED_INSTALL="1" UV_INSTALL_DIR="/usr/local/bin" sh -s -- -q
# Install NVM system-wide (matching original's nvm via pacman, using official installer for Ubuntu)
# ------------------------------------------------------------
RUN mkdir -p /usr/share/nvm && export NVM_DIR=/usr/share/nvm && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
# ------------------------------------------------------------
# Install Oh‑My‑Zsh & Powerlevel10k **system‑wide**
# ------------------------------------------------------------
RUN cd /tmp && \
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /usr/share/oh-my-zsh && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k
# ------------------------------------------------------------
# Install Zsh plugins **system‑wide** (split for reliable tar extraction)
# ------------------------------------------------------------
RUN ZSH_PLUGINS=/usr/share/oh-my-zsh/custom/plugins && \
    mkdir -p ${ZSH_PLUGINS}/zsh-autosuggestions ${ZSH_PLUGINS}/zsh-syntax-highlighting ${ZSH_PLUGINS}/zsh-256color && \
    cd /tmp && \
    curl -L -o zsh-autosuggestions.tar.gz https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.tar.gz && \
    tar -xzf zsh-autosuggestions.tar.gz --strip-components=1 -C ${ZSH_PLUGINS}/zsh-autosuggestions && \
    curl -L -o zsh-syntax-highlighting.tar.gz https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.tar.gz && \
    tar -xzf zsh-syntax-highlighting.tar.gz --strip-components=1 -C ${ZSH_PLUGINS}/zsh-syntax-highlighting && \
    curl -L -o zsh-256color.tar.gz https://github.com/chrissicool/zsh-256color/archive/refs/heads/master.tar.gz && \
    tar -xzf zsh-256color.tar.gz --strip-components=1 -C ${ZSH_PLUGINS}/zsh-256color && \
    rm -rf zsh-*.tar.gz
# ------------------------------------------------------------
# 5️⃣  Create the non‑root developer user (must be before any COPY)
# ------------------------------------------------------------
ARG USERNAME=devcontainer
ARG USER_UID=1000
ARG USER_GID=1000
RUN userdel -r ubuntu
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --create-home --uid ${USER_UID} --gid ${USER_GID} --shell /bin/zsh ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

# ------------------------------------------------------------
# 6️⃣  Global environment for the user (defined step‑by‑step)
# ------------------------------------------------------------
ENV HOME=/home/${USERNAME}
ENV SHELL=/bin/zsh
ENV NVM_DIR=/usr/share/nvm
ENV GEM_HOME=${HOME}/.gem
ENV PNPM_HOME=${HOME}/.local/share/pnpm
ENV PATH=/usr/local/bin:${GEM_HOME}/bin:${PNPM_HOME}:${HOME}/.local/bin:${HOME}/.uv/tools/aider-chat/latest/bin:${PATH}
# Add NVM to bash profile (for sourcing in RUN steps)
RUN echo 'source /usr/share/nvm/nvm.sh' >> /etc/bash.bashrc
# 👇 NEW: Add UTF-8/Australian locale exports to ~/.zprofile for tmux glyph support (overrides en_IN with correct Australia setting)
RUN echo 'export LANG=en_AU.UTF-8' >> ${HOME}/.zprofile && \
    echo 'export LC_ALL=en_AU.UTF-8' >> ${HOME}/.zprofile && \
    echo 'export TERM=screen-256color' >> ${HOME}/.zprofile  # Keep TERM override for good measure
RUN chown -R ${USERNAME}:${USERNAME} ${HOME}/.zprofile
RUN chown -R ${USERNAME}:${USERNAME} /usr/share/nvm
# ------------------------------------------------------------
# 7️⃣  Switch to the non‑root user – **everything below runs as devcontainer**
# ------------------------------------------------------------
USER ${USERNAME}
WORKDIR ${HOME}
# ------------------------------------------------------------
# 8️⃣  Install Node.js via nvm (removes need for system-wide nodejs) [FIXED FOR PARSE ERRORS]
# ------------------------------------------------------------
# FIX: Use /bin/bash explicitly to avoid Dash's lack of 'source' builtin. Source nvm, install latest LTS Node.js, and add it to PATH. This ensures pnpm has access to Node.js without system conflicts.
RUN /bin/bash -c "source /usr/share/nvm/nvm.sh && nvm install node"
RUN /bin/bash -c "source /usr/share/nvm/nvm.sh && NODE_VER=\$(nvm current) && NODE_PATH=\"${HOME}/.nvm/versions/node/${NODE_VER}/bin\" && echo \"export PATH=\\\"${PATH}:$NODE_PATH\\\"\" >> ~/.zprofile && echo \"Path to Node.js binaries added to ~/.zprofile: $NODE_PATH\""
# ------------------------------------------------------------
# 9️⃣  Copy configuration files **as the new user**
# ------------------------------------------------------------
COPY --chown=${USERNAME}:${USERNAME} .zshrc .zshrc
COPY --chown=${USERNAME}:${USERNAME} .p10k.zsh .p10k.zsh
COPY --chown=${USERNAME}:${USERNAME} .config/nvim .config/nvim
COPY --chown=${USERNAME}:${USERNAME} .config/tmux .config/tmux
COPY --chown=${USERNAME}:${USERNAME} setup_tpm.sh setup_tpm.sh
# ------------------------------------------------------------
# 11️⃣  Install PNPM globally via npm
# ------------------------------------------------------------
RUN /bin/bash -c "source /usr/share/nvm/nvm.sh && nvm use node && npm install -g pnpm"
# ------------------------------------------------------------
# 12️⃣  Install PNPM tools and update PATH
# ------------------------------------------------------------
RUN /bin/bash -c "source /usr/share/nvm/nvm.sh && nvm use node && mkdir -p \"${PNPM_HOME}\" && pnpm add -g @qwen-code/qwen-code@latest @google/gemini-cli && echo \"export PATH=\\\"${PNPM_HOME}:$PATH\\\"\" >> ~/.zprofile"
# ------------------------------------------------------------
# 11️⃣  Python 3.12 + aider‑chat (via uv – everything stays in $HOME)
# ------------------------------------------------------------
RUN uv python install 3.12 && \
    uv tool install --force --python python3.12 aider-chat@latest && \
    uv tool update-shell >> ${HOME}/.zprofile
# ------------------------------------------------------------
# 12️⃣  Ruby – install Bundler in the per‑user gem directory
# ------------------------------------------------------------
RUN gem install bundler
RUN /bin/bash -c "{ echo; echo '# Ruby environment'; echo \"export GEM_HOME='${GEM_HOME}'\"; echo \"export PATH='${GEM_HOME}/bin:$PATH'\"; } >> ${HOME}/.zprofile"
# ------------------------------------------------------------
# 13️⃣  Neovim – sync plugins (Lazy) and install LSPs via Mason
# ------------------------------------------------------------
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonInstallAll" +qa
# ------------------------------------------------------------
# 14️⃣  tmux plugin manager (TPM) – run the helper script
# ------------------------------------------------------------
RUN chmod +x setup_tpm.sh && ./setup_tpm.sh
# ------------------------------------------------------------
# 🎉  Default entry point – you land straight into a configured Zsh
# ------------------------------------------------------------
CMD ["/bin/zsh"]
