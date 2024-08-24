# Use a Fedora base image
FROM fedora:latest

# Install necessary packages
RUN dnf -y update && \
    dnf -y install \
    git \
    curl \
    @development-tools \                                                                                                                                                                               
    ncurses-devel \
    gdbm-devel \
    glibc-devel \
    xz-devel \
    zlib-devel \
    sqlite-devel \
    tk-devel \
    openssl-devel \
    libffi-devel \
    the_silver_searcher \                                                                                                                                                                              
    podman


# Install Nix
RUN sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Install fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --all

# Install asdf and other tools using Nix
RUN . /root/.nix-profile/etc/profile.d/nix.sh && \
    nix-env -iA \
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

# Install YAI
RUN curl -sS https://raw.githubusercontent.com/ekkinox/yai/main/install.sh | bash

# Copy the config.json file into the Docker image
COPY config.json /root/.config/shell-ask/config.json
COPY .bashrc /root/.bashrc
CMD ["/bin/bash"]
