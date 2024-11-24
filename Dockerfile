# Use the official Nix image as base
FROM nixos/nix:latest

# Install basic Unix tools
RUN nix-env -iA nixpkgs.coreutils nixpkgs.gnused nixpkgs.grep

# Copy Nix configuration files
COPY flake.nix /app/
COPY setup_vim_plugins.sh /app/
COPY config.json /root/.config/shell-ask/config.json
COPY .bashrc /root/.bashrc

# Enable flakes
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

WORKDIR /app

# Install dependencies using flake
RUN nix develop -c true

# Create necessary directories
RUN mkdir -p /env/bin /env/aider/bin /root/.config/shell-ask

# Setup vim plugins
RUN nix develop -c bash /app/setup_vim_plugins.sh

# Install YAI
RUN nix develop -c bash -c 'curl -sS https://raw.githubusercontent.com/ekkinox/yai/main/install.sh | bash'

# Set environment variables
ENV PATH="/env/bin:/env/aider/bin:${PATH}"

# Default command
CMD ["nix", "develop"]
