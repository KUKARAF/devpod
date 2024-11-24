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
            
            # Python dependencies
            python3
            python3Packages.pip
            python3Packages.setuptools
            python3Packages.wheel
            
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
