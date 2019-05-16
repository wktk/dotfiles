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

  mkgit "$1"

  # Create app
  result="$(heroku apps:create `basename $1` 2>&1)"
  echo "$result"

  # When error creating app
  if [[ "$result" =  *"already taken"* ]]; then
    cd -
    rm -rf "$1"
    echo " !    Removed $1"
  fi
}

function mkgif() {
  ffmpeg -i "$1" -vf scale=1280:-1 -r 10 "$2"
}

# env vars
export EDITOR="vim"

# custom bin
export PATH="$HOME/.bin:$HOME/go/bin:./.bundle/bin:$HOME/.rbenv/bin:$PATH"
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# init rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

if [ -f "$HOME/.profile_local" ]; then
  . $HOME/.profile_local
fi
