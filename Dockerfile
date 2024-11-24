# Use the official Nix image as base
FROM nixos/nix:latest

# Install basic Unix tools
RUN nix-env -iA \
    nixpkgs.coreutils \
    nixpkgs.gnused \
    nixpkgs.gnugrep \
    nixpkgs.bash

# Copy Nix configuration files
COPY flake.nix /app/
COPY .bashrc /root/.bashrc

# Enable flakes
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

WORKDIR /app

# Install dependencies using flake
RUN nix develop -c true

# Default command
CMD ["nix", "develop"]
