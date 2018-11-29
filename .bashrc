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

# init rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

if [ -f "$HOME/.profile_local" ]; then
  . $HOME/.profile_local
fi

if false && grep -q -v slack-black-theme "/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js"; then
  cat << 'EOS' | sudo tee -a /Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js > /dev/null
// First make sure the wrapper app is loaded
document.addEventListener("DOMContentLoaded", function() {

   // Then get its webviews
   let webviews = document.querySelectorAll(".TeamView webview");

   // Fetch our CSS in parallel ahead of time
   const cssPath = 'https://cdn.rawgit.com/widget-/slack-black-theme/master/custom.css';
   let cssPromise = fetch(cssPath).then(response => response.text());

   let customCustomCSS = `
   :root {
       --primary: #CCC;
       --text: #999;
       --background: #222;
       --background-elevated: #444;
   }
   `

   // Insert a style tag into the wrapper view
   cssPromise.then(css => {
      let s = document.createElement('style');
      s.type = 'text/css';
      s.innerHTML = css + customCustomCSS;
      document.head.appendChild(s);
   });

   // Wait for each webview to load
   webviews.forEach(webview => {
      webview.addEventListener('ipc-message', message => {
         if (message.channel == 'didFinishLoading')
            // Finally add the CSS into the webview
            cssPromise.then(css => {
               let script = `
                     let s = document.createElement('style');
                     s.type = 'text/css';
                     s.id = 'slack-custom-css';
                     s.innerHTML = \`${css + customCustomCSS}\`;
                     document.head.appendChild(s);
                     `
               webview.executeJavaScript(script);
            })
      });
   });
});
EOS
fi
