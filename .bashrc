# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

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

export PATH=$PATH:~/.config/dotfiles/functions
#export ANTHROPIC_API_KEY=$(pass llm/anthropic)
#export GROQ_API_KEY=$(pass llm/groq)
export EDITOR=vim
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

#. "$HOME/.asdf/asdf.sh"
#. "$HOME/.asdf/completions/asdf.bash"
#eval "$(starship init bash)"
#export PATH=${PATH}:`go env GOPATH`/bin
#export OPENAI_API_KEY=$(pass llm/openai)

#export GOPATH=$HOME/go
#export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
#alias firefox="flatpak run io.github.zen_browser.zen"

#. "$HOME/.cargo/env"

#. "$HOME/.local/share/../bin/env"
#
#

if echo "$(zellij ls)" | grep -qE '*\(current\)'; then
     source ~/zellijrc.sh
else
     echo "not in zellij"
fi


# Search function that opens cha with searx URL
search() {
    local query=""
    
    # Check if we have stdin input
    if [ ! -t 0 ]; then
        # Read from stdin
        query=$(cat)
    elif [ $# -gt 0 ]; then
        # Use command line arguments
        query="$*"
    else
        echo "Usage: search <query> or echo <query> | search"
        return 1
    fi
    
    # URL encode the query
    local encoded_query=$(printf '%s' "$query" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))")
    
    # Open cha with the searx URL
    cha "https://searx.osmosis.page/search?q=$encoded_query"
}

export OPENROUTER_API_KEY=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

eval "$(starship init bash)"
export PATH=~/.npm-global/bin:$PATH
eval "$(zoxide init bash)"
export TERM=alacritty
