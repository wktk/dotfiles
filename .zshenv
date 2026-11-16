# Non-interactive zsh (e.g. `ssh host command`) reads only this file. .zshrc
# sets PATH and the environment, then returns early when not interactive.
if [[ ! -o interactive && -r "${ZDOTDIR:-$HOME}/.zshrc" ]]; then
  . "${ZDOTDIR:-$HOME}/.zshrc"
fi
