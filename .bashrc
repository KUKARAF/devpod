# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi


# Basic environment
export EDITOR=vim
echo 'eval "$(zoxide init bash)"'


get_keys() {
  if [ -z "$ANTHROPIC_API_KEY" ]; then
    export ANTHROPIC_API_KEY=$(pass external/ANTHROPIC_API_KEY)
  fi
  if [ -z "$JIRA_API_TOKEN" ]; then
    export JIRA_API_TOKEN=$(pass tmpl/JIRA_API_TOKEN)
  fi
}

fzf_git_setup() {
  local config_file="$HOME/.config/fzf-git/fzf-git.sh"

  if [ -f "$config_file" ]; then
    # Load the existing configuration file
    source "$config_file"
  else
    # Download the configuration file from the specified URL
    mkdir -p "$(dirname "$config_file")"
    wget -O "$config_file" "https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh"
    source "$config_file"
  fi
}


PROMPT_COMMAND="get_keys;$PROMPT_COMMAND"
source ~/.config/fzf-git.sh/fzf-git.sh
alias docker-compose="docker compose"
alias docker-login="pass tmpl/corpo | head -n 1 |  docker login af2.corpo.t-mobile.pl -u rkukawski --password-stdin"
alias kerberos-login="pass tmpl/corpo | head -n 1 | kinit $USER"
function k8(){
kubectl --kubeconfig=$(find /home/corpo.t-mobile.pl/rkukawski/.kube -type f -name "*.yaml" -o -name "*.yml" | fzf) -n $(cat ~/.kube/namespaces.list | fzf) $@
}

