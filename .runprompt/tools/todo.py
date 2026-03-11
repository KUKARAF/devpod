import datetime as dt
import os
from typing import Dict

def get_todos() -> Dict[str, str]:
    """
    Return the contents of today's todo file.
    """
    # Build path of today's todo file
    base = os.path.expanduser('~/vimwiki/diary')
    path = f"{base}/{dt.datetime.now().strftime('%Y-%m-%d')}.md"

    if not os.path.exists(path):
        raise FileNotFoundError("Today's file not present.")

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    return content


def postpone(task_text: str) -> str:
    """Postpone a task (and its subtasks) from today to tomorrow.

    Removes the task line and any indented subtasks below it from today's file
    and appends them to tomorrow's file. Matching is done on the task_text
    substring (ignoring leading whitespace and checkbox).

    Args:
        task_text: The task description to match, e.g. "contact small businesses".
                   Does not need the full line — a unique substring is enough.
    """
    base = os.path.expanduser("~/vimwiki/diary")
    today_path = f"{base}/{dt.datetime.now().strftime('%Y-%m-%d')}.md"
    tomorrow = dt.datetime.now() + dt.timedelta(days=1)
    tomorrow_path = f"{base}/{tomorrow.strftime('%Y-%m-%d')}.md"

    if not os.path.exists(today_path):
        raise FileNotFoundError("Today's file not present.")

    with open(today_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    # Find the matching task line
    match_idx = None
    for i, line in enumerate(lines):
        stripped = line.lstrip("\t ").rstrip("\n")
        if task_text.lower() in stripped.lower():
            match_idx = i
            break

    if match_idx is None:
        raise ValueError(f"Task not found: {task_text!r}")

    # Determine indentation level of the matched task
    task_line = lines[match_idx]
    task_indent = len(task_line) - len(task_line.lstrip("\t"))

    # Collect the task + all subtasks (lines indented deeper)
    moved = [lines[match_idx]]
    end_idx = match_idx + 1
    while end_idx < len(lines):
        line = lines[end_idx]
        # Empty lines break the block
        if line.strip() == "":
            break
        line_indent = len(line) - len(line.lstrip("\t"))
        if line_indent > task_indent:
            moved.append(line)
            end_idx += 1
        else:
            break

    # Remove moved lines from today
    remaining = lines[:match_idx] + lines[end_idx:]
    with open(today_path, "w", encoding="utf-8") as f:
        f.writelines(remaining)

    # Append to tomorrow's file (create if needed)
    if os.path.exists(tomorrow_path):
        with open(tomorrow_path, "r", encoding="utf-8") as f:
            content = f.read()
        # Ensure there's a newline before appending
        if content and not content.endswith("\n"):
            content += "\n"
    else:
        content = f"---\nplan: true\n---\n\n"

    content += "".join(moved)
    with open(tomorrow_path, "w", encoding="utf-8") as f:
        f.write(content)

    task_desc = moved[0].strip()
    subtask_count = len(moved) - 1
    msg = f"Postponed {task_desc!r}"
    if subtask_count:
        msg += f" + {subtask_count} subtask(s)"
    msg += f" to {tomorrow.strftime('%Y-%m-%d')}"
    return msg


def calculate(expression: str):
    """Evaluates a mathematical expression.

    Use this for arithmetic calculations.
    """
    return eval(expression)

get_todos.safe = True
calculate.safe = True


if __name__ == "__main__":
    print(get_todos())
