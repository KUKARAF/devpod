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

# Install latest Vim from source
RUN git clone https://github.com/vim/vim.git /tmp/vim \
    && cd /tmp/vim \
    && ./configure --with-features=huge \
            --enable-python3interp=yes \
            --enable-rubyinterp=yes \
            --enable-luainterp=yes \
            --enable-perlinterp=yes \
            --enable-multibyte \
            --enable-cscope \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/vim

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install asdf and Node.js
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf \


# Install zoxide
RUN curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash \
    && echo 'eval "$(zoxide init bash)"' >> ~/.bashrc

WORKDIR /app

# Copy bashrc
COPY .bashrc /root/.bashrc

CMD ["/bin/bash"]
