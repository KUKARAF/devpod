
#FROM golang:latest as go-build
       
# Install packages
#RUN go install github.com/x/y@latest \
# && cp $GOPATH/bin/package /usr/local/bin/
 

##laer in actal container: 
## COPY --from=go-build /usr/local/bin/package /usr/src/toolkit/toolkit/scripts/webapp/


# Use Debian latest as base
FROM debian:latest

# Install basic tools and dependencies
RUN apt-get update && apt-get install -y \
    7zip \
    build-essential \
    cmake \
    curl \
    fd-find \
    ffmpeg \
    git \
    imagemagick \
    jq \
    libatk1.0-dev \
    libcairo2-dev \
    libgtk2.0-dev \
    liblua5.2-dev \
    libncurses5-dev \
    libperl-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    lua5.2 \
    poppler-utils \
    python3 \
    python3-dev \
    python3-pip \
    ripgrep \
    ripgrep \ 
    ruby-dev \
    silversearcher-ag \
    tmux \
    vim-nox


# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN mv /root/.local/bin/uv /usr/bin/
RUN mv /root/.local/bin/uvx /usr/bin/


#RUN curl -sS https://starship.rs/install.sh | sh
RUN cargo install starship --path /usr/bin/
RUN cargo install zoxide --path /usr/bin/
#RUN cargo install memos-cli
RUN cargo install --locked zellij --path /usr/bin/
RUN cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli --path /usr/bin/


# Install asdf and Node.js
#RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf \



WORKDIR /

# Copy bashrc


CMD ["/bin/bash"]
