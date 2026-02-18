import subprocess
import os
from typing import Dict

def get_todays_todos() -> Dict[str, str]:
    """Return the contents of today's todo file.

    This tool runs the ``today`` CLI command, which is expected to output a
    path to a markdown file (e.g. ``vimwiki/diary/23-09-2024.md``). The function
    reads that file and returns its raw text.

    The operation is read‑only and therefore marked as safe.

    Returns
    -------
    dict
        A dictionary with a single key ``content`` containing the file's text.
    """
    # Execute the ``today`` command and capture stdout.
    result = subprocess.run(["today"], capture_output=True, text=True, check=True)
    path = result.stdout.strip()
    if not path:
        raise FileNotFoundError("'today' command did not return a path.")
    # Expand user and relative paths.
    path = os.path.expanduser(path)
    if not os.path.isabs(path):
        # Resolve relative to current working directory.
        path = os.path.abspath(path)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    return {"content": content}

# Mark the tool as safe for auto‑approval with ``--safe-yes``.
get_todays_todos.safe = True
