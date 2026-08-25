#!/usr/bin/env bash
# Install vim plugins system-wide using vim's native pack directory.
set -euo pipefail

PACK_DIR="/usr/share/vim/vimfiles/pack/plugins/start"
mkdir -p "$PACK_DIR"

clone_or_update() {
    local repo="$1"
    local name="$2"
    local dir="$PACK_DIR/$name"
    if [ -d "$dir" ]; then
        git -C "$dir" pull --ff-only
    else
        git clone --depth=1 "https://github.com/$repo" "$dir"
    fi
}

clone_or_update "farmergreg/vim-lastplace"  "vim-lastplace"
clone_or_update "tpope/vim-fugitive"        "vim-fugitive"
clone_or_update "tpope/vim-commentary"      "vim-commentary"
clone_or_update "ctrlpvim/ctrlp.vim"        "ctrlp-vim"
clone_or_update "junegunn/fzf.vim"          "fzf-vim"
clone_or_update "vimwiki/vimwiki"           "vimwiki"
clone_or_update "mileszs/ack.vim"           "ack-vim"
clone_or_update "chriszarate/yazi.vim"      "yazi-vim"
clone_or_update "KUKARAF/diary"             "diary-vim"
