#!/bin/bash
# Install binaries listed in github-binaries.tsv into the image.
#
# Every entry tracks the latest upstream release. GitHub redirects
#   https://github.com/<repo>/releases/latest/download/<asset>
# to the current release, so this needs no API call, no token, and no pinned
# version -- which also means no bump workflow to maintain. The image rebuilds
# nightly, so a new release is on the machines the next morning.
#
# Verification is per-entry: where upstream publishes a .sha256sum asset it is
# fetched and checked. Where it does not, the download is unverified -- that is
# the trade for tracking latest without a recorded hash.
set -euo pipefail

MANIFEST="$(dirname "$0")/github-binaries.tsv"
[ -r "$MANIFEST" ] || { echo "No manifest at $MANIFEST" >&2; exit 1; }

# /usr/local is a symlink into /var on ostree and is not shipped in the image.
BIN_DIR="/usr/bin"
MAN_DIR="/usr/share/man/man1"

failed=0

while IFS=$'\t' read -r repo asset binaries checksum; do
    case "${repo:-}" in ''|'#'*) continue ;; esac
    [ -n "${checksum:-}" ] || { echo "malformed row: $repo" >&2; failed=1; continue; }

    base="https://github.com/${repo}/releases/latest/download"
    tmp="$(mktemp -d)"

    (
        cd "$tmp"

        # Resolve what "latest" points at, for the build log. The asset URL
        # redirects to a CDN host with no tag in it, so read the tag from the
        # releases/latest redirect instead.
        version="$(curl -fsSI "https://github.com/${repo}/releases/latest" 2>/dev/null \
                   | tr -d '\r' | sed -n 's|^[Ll]ocation:.*/releases/tag/||p' | tail -1)"
        echo "==> ${repo} ${version:-<unknown>} (${asset})"

        curl -fsSL "${base}/${asset}" -o "$asset"

        case "$asset" in
            *.tar.gz|*.tgz) tar xzf "$asset" ;;
            *)
                # Bare binary: name it after its single install target.
                set -- $binaries
                mv "$asset" "$1"
                ;;
        esac

        if [ "$checksum" = "sha256sum" ]; then
            curl -fsSL "${base}/${asset%.tar.gz}.sha256sum" -o expected.sha256sum
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
            echo "    no upstream checksum published; installed unverified"
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
    ) || { echo "==> FAILED: ${repo}" >&2; failed=1; }

    rm -rf "$tmp"
done < "$MANIFEST"

[ "$failed" -eq 0 ] || { echo "One or more entries failed." >&2; exit 1; }
echo "==> All github binaries installed."
