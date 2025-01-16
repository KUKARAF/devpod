
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
    curl \
    git \
    vim-nox \
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
    tmux 

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y


RUN mv /root/.local/bin/uv /usr/bin/
RUN mv /root/.local/bin/uvx /usr/bin/


#RUN curl -sS https://starship.rs/install.sh | sh
RUN cargo install starship
RUN cargo install zoxide

# Install asdf and Node.js
#RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf \



WORKDIR /

# Copy bashrc


CMD ["/bin/bash"]
