#!/bin/bash

# Create vim plugin directory if it doesn't exist
PLUGIN_DIR="$HOME/.vim/pack/plugins/start"
mkdir -p "$PLUGIN_DIR"

# Function to clone or update a plugin
clone_or_update_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    local plugin_path="$PLUGIN_DIR/$plugin_name"

    if [ -d "$plugin_path" ]; then
        echo "Updating $plugin_name..."
        cd "$plugin_path" && git pull
    else
        echo "Installing $plugin_name..."
        git clone "$repo_url" "$plugin_path"
    fi
}

# Install/update all plugins
clone_or_update_plugin "vim-fugitive" "https://github.com/tpope/vim-fugitive"
clone_or_update_plugin "jedi-vim" "https://github.com/davidhalter/jedi-vim"
clone_or_update_plugin "fzf" "https://github.com/junegunn/fzf.vim"
clone_or_update_plugin "ctrlp" "https://github.com/kien/ctrlp.vim"
clone_or_update_plugin "commentary" "https://github.com/tpope/vim-commentary"
#clone_or_update_plugin "vim-ai" "https://github.com/madox2/vim-ai.git"
clone_or_update_plugin "vimwiki.git" "https://github.com/vimwiki/vimwiki.git"
clone_or_update_plugin "taskwiki.git" "https://github.com/tools-life/taskwiki.git"

echo "Vim plugins setup complete!"
