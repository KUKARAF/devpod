if ! command -v nix-env >/dev/null; then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi

nix-env -iA \
 nixpkgs.vim \
 nixpkgs.asdf \
 nixpkgs.git \
 nixpkgs.fzf \
 nixpkgs.ripgrep \
 nixpkgs.zoxide \
 nixpkgs.vimHugeX
 nixpkgs.tmsu

#pip install aider

#git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
#source ~/.fzf/shell/key-bindings.bash
#source ~/.fzf/shell/completion.bash
