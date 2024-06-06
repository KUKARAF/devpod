if ! command -v nix-env >/dev/null; then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    exec $SHELL
fi
if ! command -v fzf >/dev/null; then
   git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
   ~/.fzf/install
   exec $SHELL
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


#asdf built env 

sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo apt-get install build-essential python-dev python-setuptools python-pip python-smbus
sudo apt-get install libncursesw5-dev libgdbm-dev libc6-dev
sudo apt-get install zlib1g-dev libsqlite3-dev tk-dev
sudo apt-get install libssl-dev openssl
sudo apt-get install libffi-dev

#pip install aider

#git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
#source ~/.fzf/shell/key-bindings.bash
#source ~/.fzf/shell/completion.bash
