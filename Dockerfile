# Use a Fedora base image
FROM fedora:latest

# Install necessary packages
RUN dnf -y update && \
    dnf -y install \
    git \
    curl \
    @development-tools \                                                                                                                                                                               
    rust \
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


# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2 && \
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

# Install fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --all

# Create env directory for CLI tools
RUN mkdir -p /env

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install nodejs using asdf and install shell-ask in /env
RUN . ~/.asdf/asdf.sh && \
    asdf plugin-add nodejs && \
    asdf install nodejs latest && \
    asdf global nodejs latest && \
    cd /env && \
    uv pip install shell-ask

# Install zoxide
RUN dnf -y install zoxide
#RUN asdf plugin-add rust && \
#    asdf install rust latest && \
#    asdf global rust latest && \
#    cargo install starship --locked

# Install vim and setup plugins
RUN dnf -y install vim
COPY setup_vim_plugins.sh /root/
RUN chmod +x /root/setup_vim_plugins.sh && /root/setup_vim_plugins.sh

# Add /env/bin to PATH
ENV PATH="/env/bin:/env/aider/bin:${PATH}"

# Create and setup aider virtualenv
RUN uv venv /env/aider && \
    uv pip install --venv /env/aider aider-chat

# Install tmsu
# Commented out as no direct installation method is provided
# RUN dnf -y install tmsu

# Install the_silver_searcher
RUN dnf -y install the_silver_searcher

# Install YAI
RUN curl -sS https://raw.githubusercontent.com/ekkinox/yai/main/install.sh | bash

# Copy the config.json file into the Docker image
COPY config.json /root/.config/shell-ask/config.json
COPY .bashrc /root/.bashrc
# Copy the .env file into the Docker image
#COPY .env /root/.env
#RUN echo 'source /root/.env' >> /root/.bashrc
# Load environment variables from .env

CMD ["/bin/bash"]
