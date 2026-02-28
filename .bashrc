# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
if ! [[ "$PATH" =~ "$HOME/.runprompt/prompts" ]]; then
    PATH="$HOME/.runprompt/prompts:$PATH"
fi
export PATH

# History (unlimited)
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Shell options
shopt -s globstar
shopt -s checkwinsize

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

[ -f ~/.aliasrc ] && . ~/.aliasrc

export EDITOR="vim"

# Auto-start Zellij
# if [[ -z "$ZELLIJ" ]] && command -v zellij &>/dev/null; then
#     exec zellij attach -c
# fi
