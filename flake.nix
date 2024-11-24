{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Development tools
            git
            curl
            gcc
            rustc
            cargo
            
            # Vim and dependencies
            (vim_configurable.customize {
              name = "vim";
              vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
                start = [ 
                  vim-nix
                  vim-lastplace
                  vim-fugitive
                  vim-commentary
                  ctrlp-vim
                  fzf-vim
                ];
                opt = [];
              };
              vimrcConfig.customRC = ''
                " Basic settings
                set nocompatible
                set backspace=indent,eol,start
                set hidden
                set mouse=a
                set number
                set ignorecase
                set smartcase
                set colorcolumn=80
                
                " Turn on syntax highlighting
                syntax on
                
                " Indentation settings
                set autoindent
                set expandtab
                set shiftwidth=2
                set softtabstop=2
                
                " Search settings
                set hlsearch
                set incsearch
                
                " File type detection
                filetype plugin indent on
              '';
            })
            
            # Python dependencies
            (python3.withPackages (ps: [
              ps.python-lsp-server
              ps.python-lsp-black
              ps.python-lsp-mypy
              ps.python-lsp-isort
              ps.python-lsp-ruff
            ]))
            
            # System libraries
            ncurses
            gdbm
            xz
            zlib
            sqlite
            tk
            openssl
            libffi
            
            # Additional tools
            silver-searcher
            podman
            nodejs
            fzf
            zoxide
            vim
            tmsu
            
            # Shell utilities
            bash
          ];

          shellHook = ''
            # Setup environment variables
            export PATH="$PATH:/env/bin:/env/aider/bin"
            
            # Initialize tools
            eval "$(zoxide init bash)"
            source ${pkgs.fzf}/share/fzf/key-bindings.bash
            source ${pkgs.fzf}/share/fzf/completion.bash
          '';
        };
      });
}
