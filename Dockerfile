# Use a Fedora base image
FROM fedora:latest

# Install necessary packages
RUN dnf -y update && \
    dnf -y install \
    git \
    curl \
    build-essential \
    python3-devel \
    python3-setuptools \
    python3-pip \
    python3-smbus \
    ncurses-devel \
    gdbm-devel \
    glibc-devel \
    xz-devel \
    zlib-devel \
    sqlite-devel \
    tk-devel \
    openssl-devel \
    libffi-devel \
    silversearcher-ag

# Install Nix
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Install fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --all

# Install asdf and other tools using Nix
RUN nix-env -iA \
    nixpkgs.asdf \
    nixpkgs.git \
    nixpkgs.fzf \
    nixpkgs.zoxide \
    nixpkgs.vimHugeX \
    nixpkgs.tmsu \
    nixpkgs.silver-searcher && \
    asdf plugin-add nodejs && \
    asdf install nodejs latest && \
    asdf global nodejs latest && \
    npm install -g shell-ask

# Set up the shell environment
CMD ["/bin/bash"]
