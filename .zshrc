# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Load my old settings
. ~/.bashrc

# VS Code Shell Integration for Copilot
# Fix for terminal completion detection issue
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  # Load VS Code shell integration
  [[ -f "$(code --locate-shell-integration-path zsh)" ]] && \
      . "$(code --locate-shell-integration-path zsh)"

  export GH_PAGER="" GIT_PAGER=""
fi
