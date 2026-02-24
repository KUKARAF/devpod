# TODO

## GitHub Actions — needs secrets configured
- [ ] Create PAT (repo scope) and add as `PAT` secret → needed for flake-update.yml to trigger CI on PRs
- [ ] Create Cachix personal cache and add `CACHIX_AUTH_TOKEN` + `CACHIX_CACHE_NAME` → needed for nix-vuln.yml

## Nix / Home Manager
- [ ] Add vim plugin configuration (vim-lastplace, vim-fugitive, vim-commentary, ctrlp, fzf-vim) via home-manager `programs.vim`
- [x] Add posting (HTTP client) — installable via `uvx posting` or add to nix
- [x] Manage aider via nix instead of manual binary in `.local/bin/`
- [ ] Add fzf shell integration (key bindings + completion) to shell config

## Shell
- [ ] Add `# shellcheck shell=bash` annotation to `.aliasrc` (required for security.yml to pass cleanly)

## Toolbox
- [ ] Add claude desktop entry for any additional toolboxes (ubuntu-toolbox, fedora-toolbox) if needed

## Ideas
- [ ] Extract uvx tool wrappers from `home.nix` into a separate `uvx-tools.nix` module once the list grows large enough (10+ tools)
