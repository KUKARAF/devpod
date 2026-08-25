#!/usr/bin/env bash
# Installs uv-managed CLI tools into $HOME.
#
# Not into /usr: this runs on a live ostree host where /usr is read-only, and
# not at image build time either -- aider-chat drags in a numpy build, which
# means shipping compilers in the image.
#
# $HOME is shared with the toolbox, so installing here makes the tools work
# both on the host and inside the container, from one install.
set -euo pipefail

# uv itself comes from the image (host) or from home.packages (toolbox).
if ! command -v uv >/dev/null; then
    echo "Error: uv not found on PATH." >&2
    echo "  host:    provided by the devpod image" >&2
    echo "  toolbox: provided by home-manager (home.packages)" >&2
    exit 1
fi

export UV_TOOL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/uv/tools"
export UV_TOOL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$UV_TOOL_BIN_DIR"

echo "==> Installing uv tools into $UV_TOOL_BIN_DIR ..."
uv tool install aider-chat
uv tool install posting
uv tool install 'runprompt[all]' --from 'git+https://github.com/chr15m/runprompt' --with 'requests,icalendar,python-dateutil'
uv tool install today --from 'git+https://github.com/KUKARAF/diary.git'
uv tool install todo --from 'git+https://github.com/KUKARAF/todo.git'
uv tool install pomodoro --from 'git+https://github.com/KUKARAF/pomodoro.git'
echo "==> Done."
