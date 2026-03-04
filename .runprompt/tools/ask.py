#!/usr/bin/env python3

import sys

default = ""

def ask(question):
    """
    Ask a clarifying question

    Parameters
    ----------
    question : str
        The question to display to the user.
    Returns
    -------
    str
        The user's answer, stripped of whitespace.
    """
    # Print the full question to stderr so it's visible even when stdout is captured
    print(f"\n{question}", file=sys.stderr)
    answer = input("> ").strip()
    return answer if answer else default

ask.safe = True

if __name__ == "__main__":
    name = ask("What's your name")
    print(f"Hello, {name}!")
