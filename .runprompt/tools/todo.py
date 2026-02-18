import subprocess
import os
from typing import Dict

def get_todos() -> Dict[str, str]:
    """Return the contents of today's todo file.
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
        return f.read()

# Mark the tool as safe for auto‑approval with ``--safe-yes``.
get_todos.safe = True


if __name__ == "__main__":
    print(get_todos())
