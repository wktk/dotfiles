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
# Load my old settings
. ~/.bashrc

# AWS ACCOUNT NAME
function aws_account_info {
  [ "$AWS_ACCOUNT_NAME" ] && [ "$AWS_ACCOUNT_ROLE" ] && echo "%F{blue}aws:(%f%F{red}$AWS_ACCOUNT_NAME:$AWS_ACCOUNT_ROLE%f%F{blue})%F$reset_color"
}

# VS Code Shell Integration for Copilot
# Fix for terminal completion detection issue
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  # Disable RPROMPT in VS Code (causes detection issues)
  unset RPROMPT
  unset RPS1

  # Load VS Code shell integration
  [[ -f "$(code --locate-shell-integration-path zsh)" ]] && \
      . "$(code --locate-shell-integration-path zsh)"

  export GH_PAGER="" GIT_PAGER=""
fi
