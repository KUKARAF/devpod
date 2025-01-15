# Use Debian latest as base
FROM debian:latest

# Install basic tools and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    fzf \
    silversearcher-ag \
    python3 \
    python3-pip \
    build-essential \
    libncurses5-dev \
    libgtk2.0-dev \
    libatk1.0-dev \
    libcairo2-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    python3-dev \
    ruby-dev \
    lua5.2 \
    liblua5.2-dev \
    libperl-dev \
    ripgrep \
    fd-find \
    tmux \
    && rm -rf /var/lib/apt/lists/*


# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

RUN mv /root/.local/bin/uv /usr/bin/
RUN mv /root/.local/bin/uvx /usr/bin/


#RUN curl -sS https://starship.rs/install.sh | sh
RUN cargo install starship

# Install asdf and Node.js
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf \


# Install zoxide
RUN curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash 

WORKDIR /

# Copy bashrc


CMD ["/bin/bash"]
