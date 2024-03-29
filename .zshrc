# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=99999
SAVEHIST=99999
setopt appendhistory
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/user/.zshrc'

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Load direnv
type direnv > /dev/null && eval "$(direnv hook zsh)"

if [ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/gcloud ];then
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
fi

# Load my old settings
. ~/.bashrc

# AWS ACCOUNT NAME
function aws_account_info {
  [ "$AWS_ACCOUNT_NAME" ] && [ "$AWS_ACCOUNT_ROLE" ] && echo "%F{blue}aws:(%f%F{red}$AWS_ACCOUNT_NAME:$AWS_ACCOUNT_ROLE%f%F{blue})%F$reset_color"
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/user/.sdkman"
[[ -s "/Users/user/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/user/.sdkman/bin/sdkman-init.sh"

export PATH="$HOME/.poetry/bin:$PATH"
