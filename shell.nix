{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Basic shell configuration
  shellHook = ''
    echo "Welcome to your dotfiles development environment!"
  '';

  # All CLI tools from the Dockerfile
  packages = with pkgs; [
    # System tools and utilities
    p7zip
    cmake
    clang
    curl
    fd
    ffmpeg
    git
    imagemagick
    jq
    poppler-utils
    python3
    python3Packages.pip
    ripgrep
    the_silver_searcher
    vim
    
    # Development libraries (as packages, not dev versions)
    atk
    cairo
    gtk2
    lua52
    ncurses
    perl
    xorg.libX11
    xorg.libXpm
    xorg.libXt
    
    # Rust-based tools
    starship
    zoxide
    zellij
    yazi
    
    # Python tools - uv is available in nixpkgs
    uv
    
    # Build essentials
    gnumake
    gcc
    pkg-config
    
    # Ruby development
    ruby
  ];

  # Environment variables if needed
  # shellHook can be extended for PATH modifications
}