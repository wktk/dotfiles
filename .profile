# aliases
if [ "$(uname)" = "Darwin" ]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi

alias bi='bundle install --path .bundle --binstubs .bundle/bin'
alias bu='bundle update'
alias dr='sudo killall -HUP mDNSResponder'
alias hl='heroku logs'
alias irbb='irb -r bundler/setup'
alias l='ls -CF'
alias lf='ls -lFh'
alias ll='ls -laFh'
alias sa='eval "$(ssh-agent)" && ssh-add'
alias vi='vim'
alias d='dig +noedns'

# Heroku clone
function hc() {
  git clone git@heroku.com:${1}.git $2
}

function mkcd() {
  mkdir -p "$1"
  cd "$1"
}

function mkgit() {
  mkcd "$1"
  git init
}

function mkheroku() {
  # Exit if the target exists on the filesystem
  if [ -e "$1" ]; then
    echo "$1: already exists"
    set -e
    return 1
  fi

  pwd="$(pwd)"
  mkgit "$1"

  # Create app
  result="$(heroku apps:create `basename $1` 2>&1)"
  echo "$result"

  # When error creating app
  if [[ "$result" =  *"already taken"* ]]; then
    # Remove directory and go back to $pwd
    cd "$pwd"
    rm -rf "$1"
    echo " !    Removed $1"
  fi
}

# env vars
export EDITOR="vim"

# rbenv bin path
export PATH="$HOME/.rbenv/bin:$PATH"

# bundler bin path
export PATH="./.bundle/bin:$PATH"

# custom bin
PATH="$HOME/.bin:$PATH"

# history customize for tmux
function share_history {
  history -a
  history -c
  history -r
}
PROMPT_COMMAND='share_history'
shopt -u histappend
export HISTSIZE=99999
export HISTFILESIZE=99999

# init rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

if [ -f "$HOME/.profile_local" ]; then
  . $HOME/.profile_local
fi
