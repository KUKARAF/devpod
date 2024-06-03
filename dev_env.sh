if ! command -v nix-env >/dev/null; then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi
exec $SHELL
nix-env -iA \
 nixpkgs.asdf \
 nixpkgs.git \
 nixpkgs.fzf \
 nixpkgs.zoxide \
 nixpkgs.vimHugeX \
 nixpkgs.tmsu \
 nixpkgs.silver-searcher

#pip install aider

#git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
#source ~/.fzf/shell/key-bindings.bash
#source ~/.fzf/shell/completion.bash
