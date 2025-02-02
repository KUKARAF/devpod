# .bashrc

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

#. "$HOME/.asdf/asdf.sh"
#. "$HOME/.asdf/completions/asdf.bash"
#eval "$(starship init bash)"
#export PATH=${PATH}:`go env GOPATH`/bin
#export OPENAI_API_KEY=$(pass llm/openai)
export ANTHROPIC_API_KEY=$(pass llm/anthropic)
export GROQ_API_KEY=$(pass llm/groq)

export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
alias firefox="flatpak run io.github.zen_browser.zen"
export EDITOR=vim

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"

. "$HOME/.local/share/../bin/env"
