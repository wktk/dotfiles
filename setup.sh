#!/bin/bash

DOTFILES="
  .bashrc
  .bin
  .gitconfig
  .oh-my-zsh
  .tmux.conf
  .tmux-pbcopy.conf
  .vim
  .vimrc
  .zshrc
"

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

echo "done."
