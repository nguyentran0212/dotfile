# ------------------------------------------------------------
# 0️⃣  Builder stage – compile yay (AUR helper)
# ------------------------------------------------------------
FROM archlinux:base-devel@sha256:15d3106aaf0e01eaeabf8ad9ba90924152f12848aaf6721bcecabaed16ee8523 AS builder

# Update the base, install the few tools we need to build yay,
# then compile it as a temporary non‑root user.
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
# 1️⃣  Runtime image (single‑stage – we keep the builder only for yay)
# ------------------------------------------------------------
FROM archlinux:base-devel@sha256:15d3106aaf0e01eaeabf8ad9ba90924152f12848aaf6721bcecabaed16ee8523

# ------------------------------------------------------------
#   1️⃣  Copy yay from the builder stage (still root‑owned – that’s fine)
# ------------------------------------------------------------
COPY --from=builder /usr/bin/yay /usr/bin/yay

# ------------------------------------------------------------
#   2️⃣  Install system‑wide packages (pacman) – must be root
# ------------------------------------------------------------
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
        sudo git openssh xclip wl-clipboard go gcc-fortran openblas \
        unzip curl tar ripgrep \
        python uv nodejs npm nvm pnpm nnn neovim zsh eza tmux ruby \
        texlive-basic texlive-bibtexextra texlive-binextra texlive-fontsrecommended \
        texlive-latex texlive-latexrecommended texlive-mathscience texlive-pictures \
        texlive-publishers texlive-latexextra && \
    pacman -Scc --noconfirm && \
    rm -rf /tmp/*

# ------------------------------------------------------------
#   3️⃣  Create the non‑root developer user (must be before any COPY)
# ------------------------------------------------------------
ARG USERNAME=devcontainer
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/zsh ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

# ------------------------------------------------------------
#   5️⃣  Global environment for the user (defined step‑by‑step)
# ------------------------------------------------------------
ENV HOME=/home/${USERNAME}
ENV SHELL=/bin/zsh

# Ruby‑gem home (per‑user)
ENV GEM_HOME=${HOME}/.gem

# pnpm global home (per‑user)
ENV PNPM_HOME=${HOME}/.local/share/pnpm

# PATH – we prepend the two per‑user bin dirs *once*,
# the rest of the build (and any interactive shell) will inherit it.
ENV PATH=${GEM_HOME}/bin:${PNPM_HOME}:${HOME}/.local/bin:${HOME}/.uv/tools/aider-chat/latest/bin:${PATH}

# ------------------------------------------------------------
#   6️⃣  Switch to the non‑root user – **everything below runs as devcontainer**
# ------------------------------------------------------------
USER ${USERNAME}
WORKDIR ${HOME}

# ------------------------------------------------------------
#   4️⃣  Copy configuration files **as the new user**
# ------------------------------------------------------------
COPY --chown=${USERNAME}:${USERNAME} .zshrc .zshrc
COPY --chown=${USERNAME}:${USERNAME} .p10k.zsh .p10k.zsh
COPY --chown=${USERNAME}:${USERNAME} .config/nvim .config/nvim
COPY --chown=${USERNAME}:${USERNAME} .config/tmux .config/tmux
COPY --chown=${USERNAME}:${USERNAME} setup_tpm.sh setup_tpm.sh

# ------------------------------------------------------------
#   7️⃣  Oh‑My‑Zsh + Powerlevel10k + plugins (owned by the user)
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
#   8️⃣  pnpm – create the global dir, run `pnpm setup`, then install the tools you need
# ------------------------------------------------------------
RUN mkdir -p "${PNPM_HOME}" && \
    pnpm add -g @qwen-code/qwen-code@latest @google/gemini-cli && \
    # Persist the same PATH for later RUNs / interactive shells
    echo "export PATH='${PNPM_HOME}:$PATH'" >> ${HOME}/.zprofile

# ------------------------------------------------------------
#   9️⃣  Python 3.12 + aider‑chat (via uv – everything stays in $HOME)
# ------------------------------------------------------------
RUN uv python install 3.12 && \
    uv tool install --force --python python3.12 aider-chat@latest && \
    uv tool update-shell >> ${HOME}/.zprofile

# ------------------------------------------------------------
#  🔟  Ruby – install Bundler in the per‑user gem directory
# ------------------------------------------------------------
RUN gem install bundler && \
    { echo; echo '# Ruby environment'; \
      echo "export GEM_HOME='${GEM_HOME}'"; \
      echo "export PATH='${GEM_HOME}/bin:$PATH'"; } >> ${HOME}/.zprofile

# ------------------------------------------------------------
# 1️⃣1️⃣  Neovim – sync plugins (Lazy) and install LSPs via Mason
# ------------------------------------------------------------
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonInstallAll" +qa

# ------------------------------------------------------------
# 1️⃣2️⃣  tmux plugin manager (TPM) – run the helper script
# ------------------------------------------------------------
RUN chmod +x setup_tpm.sh && ./setup_tpm.sh

# ------------------------------------------------------------
#   🎉  Default entry point – you land straight into a configured Zsh
# ------------------------------------------------------------
CMD ["/bin/zsh"]
