#!/bin/bash

DOTFILES="
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

git submodule update --init --recursive
brew tap caskroom/fonts
brew cask install font-hack-nerd-font

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
