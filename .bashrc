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
alias nosleep='sudo pmset -a disablesleep 1'
alias nonosleep='sudo pmset -a disablesleep 0'
alias dnsstatic='awk ''NF { print "dns static a " $0 " 0.0.0.0\ndns static aaaa " $0 " ::" }'''

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
  ffmpeg -i "$1" -vf scale=1280:-1 -r 10 "$1.gif"
}

function mkgif2x() {
  ffmpeg -i "$1" -vf "scale=1280:-1,setpts=0.5*PTS" -r 10 "$1.2x.gif"
}

function m3u8() {
  ffmpeg -allowed_extensions ALL -protocol_whitelist file,http,https,tcp,tls,crypto -i "$1" -movflags faststart -c copy -bsf:a aac_adtstoasc "$1.mp4"
}

# env vars
export EDITOR="vim"

# custom bin
export PATH="$HOME/.bin:$HOME/go/bin:./.bundle/bin:$HOME/.rbenv/bin:$PATH"
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# init rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# init nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"


if [ -f "$HOME/.profile_local" ]; then
  . $HOME/.profile_local
fi

export RUBY_CONFIGURE_OPTS="--with-readline-dir=/usr/lib"
