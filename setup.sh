#!/bin/bash

# The links and the cleanup below use paths relative to this repository.
cd "$(dirname "$0")" || exit 1

DOTFILES="
  .actrc
  .asdfrc
  .bashrc
  .bin
  .gitconfig
  .tmux
  .tmux.conf
  .tmux-pbcopy.conf
  .vim
  .vimrc
  .zprezto
  .zlogin
  .zlogout
  .zpreztorc
  .zprofile
  .zshenv
  .zshrc
"

RETIRED="
  .profile
  .oh-my-zsh
"

# Servers may get a copy of this repository without .git (e.g. via rsync).
if [ -e .git ]; then
  git submodule update --init --recursive
fi

if [ "$(uname)" = "Darwin" ] && command -v brew > /dev/null; then
  brew install \
    asdf \
    font-hack-nerd-font \
    font-hackgen-nerd \
    font-biz-udgothic \
    font-udev-gothic \
    font-udev-gothic-nf \
    fzf \
    zoxide \

fi

for dotfile in $DOTFILES; do
  if [ -h "$HOME/$dotfile" ]; then
    echo "Skip: $dotfile (already linked to somewhere)"
    continue
  fi

  if [ -e "$HOME/$dotfile" ]; then
    echo "Backup: $dotfile -> $dotfile.bak (Existing file renamed)"
    mv "$HOME/$dotfile"{,.bak}
  fi

  ln -s "$(pwd)/$dotfile" "$HOME"
  echo "Created: $dotfile"
done

for retired in $RETIRED; do
  if [ -h "$HOME/$retired" ]; then
    echo "Archive: $HOME/$retired"
    mv "$HOME/$retired" "$HOME/$retired.$(date +'%y%m%d%H%M%S').bak"
  fi
done

echo "done."
