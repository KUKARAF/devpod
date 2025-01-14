# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Basic prompt
PS1='[\u@\h \W]\$ '

# Basic environment
export EDITOR=vim
echo 'eval "$(zoxide init bash)"'

echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc 
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc 
. "$HOME/.asdf/asdf.sh" 


get_keys() {
  if [ -z "$ANTHROPIC_API_KEY" ]; then
    export ANTHROPIC_API_KEY=$(pass external/ANTHROPIC_API_KEY)
  fi
  if [ -z "$JIRA_API_TOKEN" ]; then
    export JIRA_API_TOKEN=$(pass tmpl/JIRA_API_TOKEN)
  fi
}

PROMPT_COMMAND="get_keys;$PROMPT_COMMAND"
source /env/fzf-git.sh/fzf-git.sh
alias docker-compose="docker compose"
alias docker-login="pass tmpl/corpo | head -n 1 |  docker login af2.corpo.t-mobile.pl -u rkukawski --password-stdin"
alias kerberos-login="pass tmpl/corpo | head -n 1 | kinit $USER"
function k8(){
kubectl --kubeconfig=$(find /home/corpo.t-mobile.pl/rkukawski/.kube -type f -name "*.yaml" -o -name "*.yml" | fzf) -n $(cat ~/.kube/namespaces.list | fzf) $@
}

