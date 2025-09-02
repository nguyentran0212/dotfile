# ------------------------------------------------------------
# 0️⃣  Builder stage – compile yay (AUR helper)
# ------------------------------------------------------------
FROM archlinux:base-devel@sha256:15d3106aaf0e01eaeabf8ad9ba90924152f12848aaf6721bcecabaed16ee8523 AS builder

# Update base, install git & base-devel, then build yay as a non‑root user
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm git base-devel && \
    useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
    sudo -u builder git clone https://aur.archlinux.org/yay.git /tmp/yay && \
    cd /tmp/yay && \
    sudo -u builder makepkg -si --noconfirm && \
    pacman -Scc --noconfirm && \
    rm -rf /tmp/yay /var/cache/pacman/pkg/*

# ------------------------------------------------------------
# 1️⃣  Runtime image
# ------------------------------------------------------------
FROM archlinux:base-devel@sha256:15d3106aaf0e01eaeabf8ad9ba90924152f12848aaf6721bcecabaed16ee8523

# ------------------------------------------------------------
#   1️⃣  Copy yay from builder stage
# ------------------------------------------------------------
COPY --from=builder /usr/bin/yay /usr/bin/yay

# ------------------------------------------------------------
#   2️⃣  Install system‑wide tools (pacman)
# ------------------------------------------------------------
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
        sudo git openssh xclip wl-clipboard go gcc-fortran openblas unzip curl tar ripgrep \
        python uv nodejs npm nvm pnpm nnn neovim zsh eza tmux ruby \
        texlive-basic texlive-bibtexextra texlive-binextra texlive-fontsrecommended \
        texlive-latex texlive-latexrecommended texlive-mathscience texlive-pictures \
        texlive-publishers texlive-latexextra && \
    pacman -Scc --noconfirm && \
    rm -rf /tmp/*

# ------------------------------------------------------------
#   3️⃣  Create the non‑root user that will own everything
# ------------------------------------------------------------
ARG USERNAME=devcontainer
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/zsh ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

# ------------------------------------------------------------
#   4️⃣  Copy dot‑files & scripts **as the new user**
# ------------------------------------------------------------
COPY --chown=${USERNAME}:${USERNAME} .zshrc .zshrc
COPY --chown=${USERNAME}:${USERNAME} .p10k.zsh .p10k.zsh
COPY --chown=${USERNAME}:${USERNAME} .config/nvim .config/nvim
COPY --chown=${USERNAME}:${USERNAME} .config/tmux .config/tmux
COPY --chown=${USERNAME}:${USERNAME} setup_tpm.sh setup_tpm.sh

# ------------------------------------------------------------
#   5️⃣  Global environment for the user
# ------------------------------------------------------------
ENV HOME=/home/${USERNAME} \
    SHELL=/bin/zsh \
    # Ruby gems – use the per‑user directory
    GEM_HOME=${HOME}/.gem \
    # pnpm global tools – default location under $HOME
    PNPM_HOME=${HOME}/.local/share/pnpm \
    # Add the important bin folders to PATH *once* for the rest of the build
    PATH=${GEM_HOME}/bin:${PNPM_HOME}:${HOME}/.local/bin:/home/${USERNAME}/.uv/tools/aider-chat/latest/bin:${PATH}

# ------------------------------------------------------------
#   6️⃣  Switch to the non‑root user – **all following RUNs are as devcontainer**
# ------------------------------------------------------------
USER ${USERNAME}
WORKDIR ${HOME}

# ------------------------------------------------------------
#   7️⃣  Oh‑My‑Zsh + Powerlevel10k + plugins (user‑owned)
# ------------------------------------------------------------
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/.zsh-theme-powerlevel10k && \
    ZSH_PLUGINS=${HOME}/.oh-my-zsh/custom/plugins && \
    mkdir -p ${ZSH_PLUGINS}/{zsh-autosuggestions,zsh-syntax-highlighting,zsh-256color} && \
    cd /tmp && \
      curl -L https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.tar.gz | \
        tar -xzf - --strip-components=1 -C ${ZSH_PLUGINS}/zsh-autosuggestions && \
      curl -L https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.tar.gz | \
        tar -xzf - --strip-components=1 -C ${ZSH_PLUGINS}/zsh-syntax-highlighting && \
      curl -L https://github.com/chrissicool/zsh-256color/archive/refs/heads/master.tar.gz | \
        tar -xzf - --strip-components=1 -C ${ZSH_PLUGINS}/zsh-256color && \
    rm -rf /tmp/*

# ------------------------------------------------------------
#   8️⃣  pnpm – set up the global bin dir and install the tools you need
# ------------------------------------------------------------
RUN mkdir -p "${PNPM_HOME}" && \
    pnpm setup && \
    # `pnpm setup` writes the export to ~/.profile; we also prepend it now
    export PATH="${PNPM_HOME}:$PATH" && \
    pnpm add -g @qwen-code/qwen-code@latest @google/gemini-cli

# ------------------------------------------------------------
#   9️⃣  Python 3.12 & aider‑chat (via uv, all in the user’s $HOME)
# ------------------------------------------------------------
RUN uv python install 3.12 && \
    uv tool install --force --python python3.12 aider-chat@latest && \
    uv tool update-shell >> ${HOME}/.zprofile

# ------------------------------------------------------------
#  🔟  Ruby – install Bundler in the user gem home
# ------------------------------------------------------------
RUN gem install bundler && \
    # Persist the same env vars for interactive shells
    { echo; echo '# Ruby environment'; echo "export GEM_HOME='${GEM_HOME}'"; \
      echo "export PATH='${GEM_HOME}/bin:$PATH'"; } >> ${HOME}/.zprofile

# ------------------------------------------------------------
# 1️⃣1️⃣  Neovim – sync plugins and install LSPs via Mason
# ------------------------------------------------------------
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonInstallAll" +qa

# ------------------------------------------------------------
# 1️⃣2️⃣  tmux plugin manager (TPM) – run the helper script
# ------------------------------------------------------------
RUN chmod +x setup_tpm.sh && ./setup_tpm.sh

# ------------------------------------------------------------
#  🎉  Default entry point
# ------------------------------------------------------------
CMD ["/bin/zsh"]
