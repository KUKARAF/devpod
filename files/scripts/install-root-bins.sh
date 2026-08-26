#!/bin/bash
# Install the binaries declared in root_bins.toml into the image.
#
# Entries default to tracking the latest release, but any entry can pin a tag
# with version = "v1.2.3". Either way the concrete tag is resolved first, so
# the build log records exactly what went in and an asset name containing
# {version} can be filled in.
#
# Verification is per-entry: checksum = "sha256sum" fetches the published
# <asset>.sha256sum and checks against it. Entries without one are installed
# unverified, which is the trade for projects that publish no checksum.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="${HERE}/root_bins.toml"
[ -r "$MANIFEST" ] || { echo "No manifest at $MANIFEST" >&2; exit 1; }

# /usr/local is a symlink into /var on ostree and is not shipped in the image.
BIN_DIR="/usr/bin"
MAN_DIR="/usr/share/man/man1"

# Flatten the TOML into tab-separated rows so the shell below stays simple.
# tomllib is in the standard library from Python 3.11.
rows="$(python3 - "$MANIFEST" <<'PY'
import sys, tomllib

with open(sys.argv[1], "rb") as fh:
    manifest = tomllib.load(fh)

for name, cfg in manifest.items():
    if not isinstance(cfg, dict):
        sys.exit(f"{name}: expected a table")
    for required in ("repo", "asset"):
        if required not in cfg:
            sys.exit(f"{name}: missing required key '{required}'")
    binaries = cfg.get("binaries", [name])
    if isinstance(binaries, str):
        binaries = [binaries]
    print("\t".join([
        name,
        cfg["repo"],
        cfg["asset"],
        cfg.get("version", "latest"),
        cfg.get("checksum", "none"),
        " ".join(binaries),
    ]))
PY
)"

failed=0

while IFS=$'\t' read -r name repo asset version checksum binaries; do
    [ -n "${name:-}" ] || continue

    # Resolve "latest" to a concrete tag. The asset download URL redirects to a
    # CDN host that carries no tag, so read it from the releases/latest
    # redirect instead.
    if [ "$version" = "latest" ]; then
        tag="$(curl -fsSI "https://github.com/${repo}/releases/latest" 2>/dev/null \
               | tr -d '\r' | sed -n 's|^[Ll]ocation:.*/releases/tag/||p' | tail -1)"
        if [ -z "$tag" ]; then
            echo "==> FAILED: ${name} — could not resolve latest release of ${repo}" >&2
            failed=1
            continue
        fi
    else
        tag="$version"
    fi

    asset_name="${asset//\{version\}/$tag}"
    base="https://github.com/${repo}/releases/download/${tag}"
    tmp="$(mktemp -d)"

    (
        cd "$tmp"
        echo "==> ${name} ${tag} (${asset_name})"
        curl -fsSL "${base}/${asset_name}" -o "$asset_name"

        case "$asset_name" in
            *.tar.gz|*.tgz) tar xzf "$asset_name" ;;
            *)
                # Bare binary: name it after its single install target.
                set -- $binaries
                mv "$asset_name" "$1"
                ;;
        esac

        if [ "$checksum" = "sha256sum" ]; then
            curl -fsSL "${base}/${asset_name%.tar.gz}.sha256sum" -o expected.sha256sum
            expected="$(awk '{print $1}' expected.sha256sum)"
            for b in $binaries; do
                actual="$(sha256sum "$b" | awk '{print $1}')"
                if [ "$expected" != "$actual" ]; then
                    echo "    ERROR: checksum mismatch for $b" >&2
                    echo "      expected $expected" >&2
                    echo "      actual   $actual" >&2
                    exit 1
                fi
                echo "    checksum verified: $actual"
            done
        else
            echo "    no checksum configured; installed unverified"
        fi

        for b in $binaries; do
            install -Dm755 "$b" "${BIN_DIR}/${b}"
            echo "    installed ${BIN_DIR}/${b}"
        done

        for m in *.1; do
            [ -e "$m" ] || continue
            install -Dm644 "$m" "${MAN_DIR}/${m}"
            echo "    installed ${MAN_DIR}/${m}"
        done
    ) || { echo "==> FAILED: ${name}" >&2; failed=1; }

    rm -rf "$tmp"
done <<< "$rows"

[ "$failed" -eq 0 ] || { echo "One or more entries failed." >&2; exit 1; }
echo "==> All root binaries installed."
