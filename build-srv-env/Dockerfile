# Yocto development environment
# Base: Ubuntu 24.04 (Noble)
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=1000
# GID of the host's docker group (owns /var/run/docker.sock). Check with
# `getent group docker` on the build server and set DOCKER_GID accordingly.
ARG DOCKER_GID=999

# https://docs.yoctoproject.org/ref-manual/system-requirements.html
# `universe` is not enabled by default on the minimal ubuntu:24.04 image and
# is needed for dnf/dnf-plugins-core below.
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository -y universe \
    && apt-get update && apt-get install -y --no-install-recommends \
    gawk wget git git-lfs diffstat unzip texinfo gcc g++ build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect python3-venv \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 \
    python3-subunit zstd liblz4-tool file locales libacl1 \
    lz4 procps mesa-common-dev libsdl1.2-dev iproute2 \
    ca-certificates curl sudo vim nano less tree bash-completion \
    openssh-client rsync screen tmux \
    ripgrep fd-find bat strace xxd \
    linux-tools-common linux-tools-generic \
    docker.io \
    dnf dnf-plugins-core \
    && locale-gen en_US.UTF-8 \
    && ln -sf "$(command -v fdfind)" /usr/local/bin/fd \
    && ln -sf "$(command -v batcat)" /usr/local/bin/bat \
    && rm -rf /var/lib/apt/lists/*

# --- Reconcile the "docker" group (created by the docker.io package) with ---
# --- the host's docker.sock GID, so the non-root user can use it directly ---
RUN if getent group ${DOCKER_GID} >/dev/null; then \
        : ; \
    elif getent group docker >/dev/null; then \
        groupmod -g ${DOCKER_GID} docker; \
    else \
        groupadd --gid ${DOCKER_GID} docker; \
    fi

# --- Neovim: Ubuntu 24.04 only ships 0.9.5, install upstream's official ---
# --- prebuilt release instead of compiling from source (much faster). ---
ARG NVIM_VERSION=v0.12.4
# SHA256 of nvim-linux-x86_64.tar.gz for NVIM_VERSION above (from GitHub's
# release API). Update this together with NVIM_VERSION when bumping.
ARG NVIM_SHA256=012bf3fcac5ade43914df3f174668bf64d05e049a4f032a388c027b1ebd78628
RUN curl -fsSL -o /tmp/nvim-linux-x86_64.tar.gz \
        https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz \
    && echo "${NVIM_SHA256}  /tmp/nvim-linux-x86_64.tar.gz" | sha256sum -c - \
    && tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz \
    && mv /opt/nvim-linux-x86_64 /opt/nvim \
    && ln -sf /opt/nvim/bin/nvim /usr/bin/nvim \
    && rm /tmp/nvim-linux-x86_64.tar.gz

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && usermod -aG $(getent group ${DOCKER_GID} | cut -d: -f1) ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# --- Dotfiles: baked into the image from ./dotfiles/, seeded into $HOME at
# --- container start (see entrypoint.sh) rather than COPY'd directly into
# --- /home/${USERNAME}, since that path is a named volume and would shadow
# --- anything placed there at build time.
COPY dotfiles/ /opt/dotfiles-skel/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chown -R ${USER_UID}:${USER_GID} /opt/dotfiles-skel \
    && chmod +x /usr/local/bin/entrypoint.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}/yocto

RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
RUN cp -ra ~/.bashrc ~/.fzf /opt/dotfiles-skel

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
