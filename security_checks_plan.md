# Security Checks Plan — dotfiles repo (KUKARAF/devpod)

## Context

This repo is a private personal dotfiles repo on a personal GitHub account (not an org).
It contains:
- Nix flake (`flake.nix`, `flake.lock`) managed via home-manager
- Shell scripts (`.aliasrc`, `.tools/*.sh`, `.config/zellij/plugins/get_plugins.sh`)
- Config files (zellij, starship, etc.)
- 40+ packages including ffmpeg, clang, nodejs, go, claude-code, claude-desktop (external flake)

---

## Tool Survey

### Category 1: Secret / Credential Scanning

| Tool | License | FOSS | Git History | Notes |
|---|---|---|---|---|
| **gitleaks** | MIT (CLI) | ✅ | ✅ Full | Official action free for personal accounts (no license key needed). Regex + entropy. |
| **trufflehog v3** | AGPL-3.0 | ✅ | ✅ Full | Actively *verifies* credentials against real APIs — eliminates false positives. |
| ~~detect-secrets~~ | Apache 2.0 | ✅ | ❌ None | Baseline diff only. Cannot scan existing history. **Excluded.** |
| ~~GitHub secret scanning~~ | Proprietary | ❌ | N/A | Requires GitHub Advanced Security for private repos. **Excluded.** |

**Decision:** gitleaks on every push (pattern matching) + trufflehog on schedule (live verification).

---

### Category 2: Nix Package CVE Scanning

| Tool | License | FOSS | Nix/flake.lock aware | Notes |
|---|---|---|---|---|
| **vulnix** | BSD-3-Clause | ✅ | ✅ Native | Only Nix-native CVE scanner. Requires building derivations first. |
| ~~trivy~~ | Apache 2.0 | ✅ | ❌ None | Issue #1673 open since 2022, unresolved. Zero coverage for Nix packages. **Excluded.** |
| ~~osv-scanner~~ | Apache 2.0 | ✅ | ❌ None | 19+ lockfile formats supported — flake.lock not among them. **Excluded.** |
| ~~grype~~ | Apache 2.0 | ✅ | ❌ None | Container/filesystem scanner, no Nix derivation awareness. **Excluded.** |

**Decision:** vulnix, built on top of `nix build` + Cachix binary cache to avoid cold rebuild cost.

> **Note:** Staying current on `nixos-unstable` via frequent `flake.lock` updates is *more effective*
> in practice than running vulnix alone, since the nixpkgs security team patches CVEs upstream.
> The external `k3d3/claude-desktop-linux-flake` input is the highest-risk dependency — it has
> no dedicated security team.

---

### Category 3: Shell Script Static Analysis

| Tool | License | FOSS | Notes |
|---|---|---|---|
| **shellcheck** | GPLv3 | ✅ | Industry standard. Pre-installed on `ubuntu-latest` runners. No real alternative. |
| **shfmt** | MIT | ✅ | Formatting companion to shellcheck. Optional. |

**Decision:** shellcheck via `ludeeus/action-shellcheck` (MIT action). `.aliasrc` requires
explicit `--shell=bash` flag or a `# shellcheck shell=bash` annotation since it has no extension.

---

### Category 4: Automated Flake Input Updates

| Tool | License | FOSS | Nix flake.lock | Notes |
|---|---|---|---|---|
| **update-flake-lock** | MIT | ✅ | ✅ Native | Purpose-built for this exact job. 3,400+ dependent repos. Creates PRs. |
| ~~dependabot~~ | Proprietary | ❌ | ❌ None | Issue #7340 open since May 2023 with no progress. **Excluded.** |
| ~~renovate~~ | AGPL-3.0 | ✅ | ⚠️ Beta | Nix manager in beta, known reliability issues with `lockFileMaintenance`. Overkill for now. |

**Decision:** `DeterminateSystems/update-flake-lock` on a weekly cron, creating a PR.

---

## Recommended Stack

| Category | Tool | Action |
|---|---|---|
| Secret scanning | gitleaks | `gitleaks/gitleaks-action` |
| Secret verification | trufflehog | `trufflesecurity/trufflehog` |
| Nix CVE scanning | vulnix | `cachix/install-nix-action` + `cachix/cachix-action` + vulnix |
| Shell analysis | shellcheck | `ludeeus/action-shellcheck` |
| Flake updates | update-flake-lock | `DeterminateSystems/update-flake-lock` |

---

## Proposed Workflow Architecture

### `security.yml` — runs on every push and PR

1. Checkout (full history: `fetch-depth: 0`)
2. gitleaks — full git history scan
3. shellcheck — all `.sh` files + `.aliasrc`

### `nix-vuln.yml` — runs on push to master + weekly

1. Checkout
2. Install Nix with flakes (`cachix/install-nix-action`)
3. Set up Cachix binary cache
4. Build home-manager activation package
5. Run vulnix against closure
6. Upload report as artifact

Requires a committed `vulnix-whitelist.toml` to suppress known false positives.

### `flake-update.yml` — runs weekly (Monday 03:00 UTC)

1. Checkout with PAT (so the created PR triggers CI workflows)
2. Install Nix with flakes
3. Run `DeterminateSystems/update-flake-lock` — creates a PR with updated `flake.lock`

---

## Known Caveats

- **vulnix cold build cost:** Building the full closure (ffmpeg, clang, nodejs, go, imagemagick…)
  takes 20–60 min without a cache. Cachix free personal tier is required to make this practical.
- **flake.lock location:** It lives at `.config/home-manager/flake.lock`, not the repo root.
  Both `update-flake-lock` and vulnix need to be pointed at that subdirectory.
- **gitleaks false positives:** dotfiles repos commonly trip on config values that look like keys.
  Plan for an initial scan pass and a `.gitleaks.toml` allowlist before enabling blocking CI.
- **shellcheck + .aliasrc:** Add `# shellcheck shell=bash` as first line of `.aliasrc` to avoid
  the "no extension" warning. Some zsh-isms will still produce findings.
- **claude-desktop supply chain:** `k3d3/claude-desktop-linux-flake` is a third-party flake with
  no security team. Consider pinning it to a specific commit in `flake.lock` and reviewing updates
  manually before merging the flake-update PR.
- **trufflehog scheduling:** Run on a schedule rather than every push to avoid API rate limits
  during active credential verification checks.
