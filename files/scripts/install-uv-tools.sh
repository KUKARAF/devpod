#!/usr/bin/env bash
# Installs uv and custom/GitHub-based tools system-wide during image build.
set -euo pipefail

# Install uv system-wide
curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/bin sh

# Install tools system-wide
export UV_TOOL_DIR=/usr/share/uv/tools
export UV_TOOL_BIN_DIR=/usr/bin

uv tool install aider-chat
uv tool install posting
uv tool install mistral-vibe
uv tool install 'runprompt[all]' --from 'git+https://github.com/chr15m/runprompt' --with 'requests,icalendar,python-dateutil'
uv tool install today --from 'git+https://github.com/KUKARAF/diary.git'
uv tool install todo --from 'git+https://github.com/KUKARAF/todo.git'
uv tool install pomodoro --from 'git+https://github.com/KUKARAF/pomodoro.git'
