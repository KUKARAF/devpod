# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Basic prompt
PS1='[\u@\h \W]\$ '

# Basic environment
export EDITOR=vim
