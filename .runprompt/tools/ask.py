#!/usr/bin/env python3

def ask(question, default=None):
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
    prompt = f"{question} [{default}]: "
    prompt = f"{question}: "

    answer = input(prompt).strip()
    return answer if answer else default

ask.safe = True

if __name__ == "__main__":
    name = ask("What's your name", "anonymous")
    print(f"Hello, {name}!")
