# Used to pick the per-shell variant of tool integrations; unset at the end.
if [ -n "$ZSH_VERSION" ]; then
  _rc_shell=zsh
else
  _rc_shell=bash
fi

# PATH and environment variables come before the interactive check below, so
# that non-interactive bash started by sshd (`ssh host command`) gets them too.

# Set HOMEBREW_PREFIX here instead of relying on `brew shellenv`, which prints
# nothing when PATH already starts with Homebrew's bin and sbin.
if [ -z "$HOMEBREW_PREFIX" ]; then
  for _rc_brew in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if [ -x "$_rc_brew/bin/brew" ]; then
      HOMEBREW_PREFIX="$_rc_brew"
      break
    fi
  done
  unset _rc_brew
fi
[ -n "$HOMEBREW_PREFIX" ] && export HOMEBREW_PREFIX

# Rebuild PATH with these directories first, followed by the inherited entries
# without duplicates. Login shells move them to the front even when present:
# macOS path_helper (/etc/zprofile, /etc/profile) has just pushed inherited
# entries behind /usr/bin. Other shells inherit PATH from a parent that already
# ran this, so they add only missing ones and keep what a parent put first on
# purpose (e.g. an activated venv).
_rc_path_add() {
  case ":$_rc_path:" in
    *":$1:"*) ;;
    *) _rc_path="${_rc_path:+$_rc_path:}$1" ;;
  esac
}

_rc_login=
if [ "$_rc_shell" = zsh ]; then
  [[ -o login ]] && _rc_login=1
else
  shopt -q login_shell && _rc_login=1
fi

_rc_path=
# Listed from the highest to the lowest priority.
for _rc_dir in \
  "${ASDF_DATA_DIR:-$HOME/.asdf}/shims" \
  "$HOME/.antigravity/antigravity/bin" \
  /opt/local/bin \
  /opt/local/sbin \
  "$HOME/.cargo/bin" \
  "$HOME/.bin" \
  "$HOME/go/bin" \
  "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}" \
  "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}" \
  "$HOME/bin" \
  "$HOME/.local/bin"
do
  [ -d "$_rc_dir" ] || continue
  if [ -z "$_rc_login" ]; then
    case ":$PATH:" in
      *":$_rc_dir:"*) continue ;;
    esac
  fi
  _rc_path_add "$_rc_dir"
done

_rc_rest="$PATH:"
while [ -n "$_rc_rest" ]; do
  _rc_dir="${_rc_rest%%:*}"
  _rc_rest="${_rc_rest#*:}"
  [ -n "$_rc_dir" ] && _rc_path_add "$_rc_dir"
done
export PATH="$_rc_path"
unset _rc_path _rc_rest _rc_dir _rc_login
unset -f _rc_path_add

export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESS='-F -i -M -R -X'
# Colors for man pages. Debian's groff emits SGR escapes, which bypass these,
# unless GROFF_NO_SGR is set; macOS's mandoc ignores it.
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[00;47;30m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
export GROFF_NO_SGR=1
# Only when the locale is installed; otherwise every program warns via setlocale.
if [ -z "$LANG" ] && locale -a 2> /dev/null | grep -qiE '^en_US\.utf-?8$'; then
  export LANG=en_US.UTF-8
fi
export BASH_SILENCE_DEPRECATION_WARNING=1

if [ -z "$LESSOPEN" ] && command -v lesspipe > /dev/null; then
  export LESSOPEN="| /usr/bin/env lesspipe %s 2>&-"
fi

# Non-interactive shells only need PATH and the environment variables above;
# stop here so that nothing below runs or prints (e.g. for scp).
case $- in
  *i*) ;;
  *)
    unset _rc_shell
    return
    ;;
esac

# Fall back to a TERM this host has terminfo for. ssh passes TERM through, and
# e.g. tmux-256color is missing on older Debian, which breaks vim and less.
if command -v infocmp > /dev/null && ! infocmp "$TERM" > /dev/null 2>&1; then
  _rc_term=xterm-256color
  # tmux-* has a close screen-* counterpart, e.g. screen-256color.
  case $TERM in
    tmux*)
      if infocmp "screen${TERM#tmux}" > /dev/null 2>&1; then
        _rc_term="screen${TERM#tmux}"
      fi
      ;;
  esac
  if infocmp "$_rc_term" > /dev/null 2>&1; then
    export TERM="$_rc_term"
  fi
  unset _rc_term
fi

# zsh keeps SAVEHIST entries in the file, bash keeps HISTFILESIZE.
HISTSIZE=99999
SAVEHIST=$HISTSIZE
HISTFILESIZE=$HISTSIZE

if [ "$_rc_shell" = zsh ]; then
  # zsh picks vi key bindings when EDITOR contains "vi"; keep emacs ones.
  bindkey -e
  # Ctrl-W deletes back to "/" or "=" instead of the whole path.
  WORDCHARS='*?_-.[]~&;!#$%^(){}<>'
  # Keys that zsh leaves unbound. Each one is sent differently depending on
  # the terminal and its keypad mode.
  bindkey '^[[H' beginning-of-line
  bindkey '^[OH' beginning-of-line
  bindkey '^[[1~' beginning-of-line
  bindkey '^[[F' end-of-line
  bindkey '^[OF' end-of-line
  bindkey '^[[4~' end-of-line
  bindkey '^[[3~' delete-char
  # Word moves with Ctrl or Option/Alt + arrows (and Esc b / Esc f).
  bindkey '^[[1;5D' emacs-backward-word
  bindkey '^[[1;5C' emacs-forward-word
  bindkey '^[[1;3D' emacs-backward-word
  bindkey '^[[1;3C' emacs-forward-word
  bindkey '^[^[[D' emacs-backward-word
  bindkey '^[^[[C' emacs-forward-word
  bindkey '^[b' emacs-backward-word
  bindkey '^[f' emacs-forward-word
  bindkey '^[[Z' reverse-menu-complete

  typeset -gU fpath
  if [ -n "$HOMEBREW_PREFIX" ]; then
    # zsh-completions adds definitions that zsh lacks (e.g. yarn, bundle).
    fpath=(
      "$HOMEBREW_PREFIX/share/zsh/site-functions"
      "$HOMEBREW_PREFIX/share/zsh-completions"
      $fpath
    )
  fi
  setopt COMPLETE_IN_WORD ALWAYS_TO_END
  autoload -Uz compinit
  compinit
  zstyle ':completion:*' menu select
  # Case-insensitive first, then partial words (f.b -> foo.bar), then substrings.
  zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  # Fall back to correcting typos; one error is allowed per three characters.
  zstyle ':completion:*' completer _complete _match _approximate
  zstyle ':completion:*:match:*' original only
  zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*' verbose yes
  zstyle ':completion:*:options' description yes
  zstyle ':completion:*:options' auto-description '%d'
  zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
  zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
  zstyle ':completion:*:messages' format ' %F{magenta} -- %d --%f'
  zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
  # Evaluated on use, since LS_COLORS is set further below.
  zstyle -e ':completion:*:default' list-colors 'reply=(${(s.:.)LS_COLORS})'
  zstyle ':completion:*:default' list-prompt '%S%M matches%s'
  zstyle ':completion:*' squeeze-slashes true
  zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

  setopt CORRECT
  setopt INTERACTIVE_COMMENTS
  # Run background jobs at normal priority, as bash does.
  setopt NO_BG_NICE
  # Keep `=word` literal as in bash, instead of expanding it to a command path.
  setopt NO_EQUALS

  HISTFILE=~/.histfile
  setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_VERIFY

  # Up/Down (and ^P/^N) step through history entries that contain what was
  # typed before the first press, like bash's history-substring-search-*
  # bound in .inputrc.
  _rc_history_substring_search() {
    emulate -L zsh
    # Matching entries are collected once per search; repeated presses reuse them.
    if [[ $LASTWIDGET != _rc_history_substring_search_* ]]; then
      _rc_hss_query=$BUFFER
      _rc_hss_index=$HISTCMD
      _rc_hss_keys=(${(k)history[(R)*${(b)_rc_hss_query}*]})
    fi
    # In a multi-line buffer, move between its lines first.
    if [[ $1 == up && $LBUFFER == *$'\n'* ]]; then
      zle up-line
      return
    elif [[ $1 == down && $RBUFFER == *$'\n'* ]]; then
      zle down-line
      return
    fi
    if [[ -z $_rc_hss_query ]]; then
      zle $1-line-or-history
      return
    fi
    local k
    if [[ $1 == up ]]; then
      for k in ${(On)_rc_hss_keys}; do
        if (( k < _rc_hss_index )); then
          _rc_hss_index=$k
          BUFFER=$history[$k]
          CURSOR=$#BUFFER
          return
        fi
      done
    else
      for k in ${(on)_rc_hss_keys}; do
        if (( k > _rc_hss_index )); then
          _rc_hss_index=$k
          BUFFER=$history[$k]
          CURSOR=$#BUFFER
          return
        fi
      done
      _rc_hss_index=$HISTCMD
      BUFFER=$_rc_hss_query
      CURSOR=$#BUFFER
    fi
  }
  _rc_history_substring_search_up() { _rc_history_substring_search up; }
  _rc_history_substring_search_down() { _rc_history_substring_search down; }
  zle -N _rc_history_substring_search_up
  zle -N _rc_history_substring_search_down
  bindkey '^[[A' _rc_history_substring_search_up
  bindkey '^[OA' _rc_history_substring_search_up
  bindkey '^P' _rc_history_substring_search_up
  bindkey '^[[B' _rc_history_substring_search_down
  bindkey '^[OB' _rc_history_substring_search_down
  bindkey '^N' _rc_history_substring_search_down
fi

if [ "$_rc_shell" = bash ]; then
  # failglob would match zsh's NOMATCH, but it breaks bash-completion
  # (e.g. tar and ssh completions abort in bash-completion 2.11).
  # globstar needs bash 4+; macOS /bin/bash is 3.2.
  shopt -s globstar 2> /dev/null

  for _rc_completion in \
    "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh}" \
    /usr/share/bash-completion/bash_completion \
    /etc/bash_completion
  do
    if [ -r "$_rc_completion" ]; then
      . "$_rc_completion"
      break
    fi
  done
  unset _rc_completion

  # Not the default ~/.bash_history: a bash started without this rc (e.g.
  # `bash --norc`) keeps only 500 entries and would truncate the file.
  # bash 3.2 (macOS /bin/bash) reads the timestamp lines that bash 4+ writes as
  # commands, so it gets a file of its own.
  if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    HISTFILE=~/.bash_history_bash3
  else
    HISTFILE=~/.bash_history_shared
    if [ ! -e "$HISTFILE" ] && [ -f ~/.bash_history ]; then
      command cp ~/.bash_history "$HISTFILE"
    fi

    # erasedups works only within one shell, so once a day rewrite the file
    # keeping the last occurrence of each command. A command another shell
    # saves during the rewrite (a fraction of a second) can be lost.
    # printf %(...)T needs bash 4.2+; older ones skip this.
    printf -v _rc_now '%(%s)T' -1 2> /dev/null
    _rc_mark="${XDG_CACHE_HOME:-$HOME/.cache}/bash_history_compacted_at"
    _rc_last=
    if [ -r "$_rc_mark" ]; then
      read -r _rc_last < "$_rc_mark"
    fi
    case $_rc_last in
      '' | *[!0-9]*) _rc_last=0 ;;
    esac
    if [ -n "$_rc_now" ] && [ $((_rc_now - _rc_last)) -ge 86400 ] && [ -s "$HISTFILE" ]; then
      # Recorded first so that shells starting at the same time skip it.
      mkdir -p "${_rc_mark%/*}" && echo "$_rc_now" >| "$_rc_mark"
      awk -v max="$HISTSIZE" '
        /^#[0-9]+$/ { n++; ts[n] = $0 "\n"; cmd[n] = ""; stamped = 1; next }
        { if (!stamped) { n++; ts[n] = ""; cmd[n] = "" }; cmd[n] = cmd[n] $0 "\n" }
        END {
          for (i = 1; i <= n; i++) last[cmd[i]] = i
          for (i = 1; i <= n; i++) if (cmd[i] != "" && last[cmd[i]] == i) keep[++m] = i
          for (j = (m > max ? m - max + 1 : 1); j <= m; j++) printf "%s%s", ts[keep[j]], cmd[keep[j]]
        }' "$HISTFILE" >| "$HISTFILE.$$" &&
        command mv -f "$HISTFILE.$$" "$HISTFILE"
      command rm -f "$HISTFILE.$$"
    fi
    unset _rc_now _rc_mark _rc_last
  fi
  HISTCONTROL=ignoreboth:erasedups
  HISTTIMEFORMAT='%F %T '
  shopt -s histappend histverify
  # Share history between running shells, as zsh's SHARE_HISTORY does: save
  # new entries and reload the file before each prompt.
  _rc_history_sync() {
    history -a
    history -c
    history -r
  }
  case ";$PROMPT_COMMAND;" in
    *";_rc_history_sync;"*) ;;
    *) PROMPT_COMMAND="_rc_history_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
fi

# aliases
if [ "$(uname)" = "Darwin" ]; then
  alias ls='ls -G'
  alias dr='sudo killall -HUP mDNSResponder'
  alias docker-desktop='open /Applications/Docker.app'
  alias nosleep='sudo pmset -a disablesleep 1'
  alias nonosleep='sudo pmset -a disablesleep 0'
  alias nosleepstatus="pmset -g | awk '/SleepDisabled/ { print \$2 }'"
  alias od='docker-desktop'
  alias qd="osascript -e 'quit app \"Docker Desktop\"'"
  alias pbc='pbcopy'
  alias pbp='pbpaste'
else
  alias ls='ls --color=auto'
fi

alias gf='git switch $(basename $(git rev-parse --abbrev-ref origin/HEAD)) && git pull --prune && git merged-branch'
alias ll='ls -laFh'
alias vi='vim'
alias d='dig +noedns'
alias grep='grep --color=auto'
# --color needs GNU diffutils 3.4+ or the FreeBSD-based diff of recent macOS.
if diff --color=auto /dev/null /dev/null > /dev/null 2>&1; then
  alias diff='diff --color=auto'
fi

# BSD ls on macOS ignores LS_COLORS; it is set there for zsh's completion list.
if [ -z "$LS_COLORS" ]; then
  if command -v dircolors > /dev/null; then
    eval "$(dircolors -b)"
  else
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'
  fi
fi

function mkcd() {
  mkdir -p "$1"
  cd "$1"
}

function mkgit() {
  mkcd "$1"
  git init
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

# Prompt: [user@host:]~/path[ branch][|action][*][+][?][↑N][↓N] $
# When the top-level directory of the work tree ends with the branch name
# (e.g. a worktree at .../issues/3290 on branch issues/3290), that part of the
# path is shown in the branch color instead of repeating the name after it.
# One implementation for both shells, so bash on Linux shows the same as zsh.
# * marks unstaged changes, + staged changes and ? untracked files.
_rc_prompt_dir() {
  local dir c_dir c_git c_sync out nl git_dir inside prefix st branch action flags ab ahead behind sync tail
  if [ -n "$ZSH_VERSION" ]; then
    # What %~ shows; % has to be escaped, as the prompt expands it again.
    dir=${(%):-%~}
    dir=${dir//\%/%%}
    c_dir='%F{cyan}' c_git='%F{green}' c_sync='%F{yellow}'
  else
    # What \w shows (${PS1@P} would need bash 4.4+). \001 and \002 tell
    # readline that the escape sequences take no width.
    dir=${PWD/#$HOME/\~}
    c_dir=$'\001\033[35m\002' c_git=$'\001\033[32m\002' c_sync=$'\001\033[33m\002'
  fi
  if ! out=$(git rev-parse --git-dir --is-inside-work-tree --show-prefix 2> /dev/null); then
    printf '%s%s' "$c_dir" "$dir"
    return 0
  fi
  # One value per line; the prefix (e.g. "src/" below the top level) is empty
  # at the top level, and $(...) drops that trailing empty line.
  nl='
'
  git_dir=${out%%"$nl"*}
  out=${out#*"$nl"}
  inside=${out%%"$nl"*}
  case $out in
    *"$nl"*) prefix=${out#*"$nl"} ;;
  esac
  prefix=${prefix%/}
  if [ "$inside" = true ]; then
    # One command for the branch, upstream counts and changes. --porcelain=v2
    # needs git 2.11+. Headers look like "# branch.head <name>"; change lines
    # start with "1 XY" or "2 XY" (X staged, Y unstaged, "." unchanged),
    # "u " for conflicts and "? " for untracked files.
    st="$nl$(git status --porcelain=v2 --branch 2> /dev/null)$nl"
    branch=${st#*"$nl# branch.head "}
    branch=${branch%%"$nl"*}
    if [ "$branch" = "(detached)" ]; then
      branch=${st#*"$nl# branch.oid "}
      branch=$(printf '%.7s' "${branch%%"$nl"*}")
    fi
    # git before 2.11 (e.g. on rental servers) lacks --porcelain=v2; show at
    # least the branch there.
    if [ -z "$branch" ]; then
      branch=$(git symbolic-ref --short -q HEAD 2> /dev/null) ||
        branch=$(git rev-parse --short HEAD 2> /dev/null)
    fi
    case $st in
      *"$nl"[12]" "?[!.]* | *"$nl"u" "*) flags='*' ;;
    esac
    case $st in
      *"$nl"[12]" "[!.]*) flags="$flags+" ;;
    esac
    case $st in
      *"$nl? "*) flags="$flags?" ;;
    esac
    # Commits ahead of (↑) and behind (↓) the upstream, as of the last fetch.
    case $st in
      *"$nl# branch.ab "*)
        ab=${st#*"$nl# branch.ab +"}
        ab=${ab%%"$nl"*}
        ahead=${ab%% *}
        behind=${ab#* -}
        [ "$ahead" -gt 0 ] && sync="↑$ahead"
        [ "$behind" -gt 0 ] && sync="$sync↓$behind"
        ;;
    esac
  else
    # Inside .git, where git status does not work.
    branch=$(git symbolic-ref --short -q HEAD 2> /dev/null) ||
      branch=$(git rev-parse --short HEAD 2> /dev/null)
  fi
  if [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ]; then
    action=rebase
  elif [ -f "$git_dir/MERGE_HEAD" ]; then
    action=merge
  elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
    action=cherry-pick
  elif [ -f "$git_dir/REVERT_HEAD" ]; then
    action=revert
  elif [ -f "$git_dir/BISECT_LOG" ]; then
    action=bisect
  fi
  if [ -n "$ZSH_VERSION" ]; then
    branch=${branch//\%/%%}
    prefix=${prefix//\%/%%}
  fi
  tail="/$branch${prefix:+/$prefix}"
  case $dir in
    *"$tail")
      printf '%s%s/%s%s%s%s' "$c_dir" "${dir%"$tail"}" "$c_git" "$branch" "$c_dir" "${prefix:+/$prefix}"
      ;;
    *)
      printf '%s%s%s %s' "$c_dir" "$dir" "$c_git" "$branch"
      ;;
  esac
  printf '%s%s%s' "$c_git" "${action:+|$action}" "$flags"
  if [ -n "$sync" ]; then
    printf '%s%s' "$c_sync" "$sync"
  fi
}

# The path is cyan in zsh and magenta in bash, to tell the shells apart;
# user@host (over ssh only) is white.
if [ "$_rc_shell" = zsh ]; then
  setopt PROMPT_SUBST
  PROMPT='${SSH_CONNECTION:+%7F%n@%m:%f}$(_rc_prompt_dir)%f %(!.#.$) '
else
  PS1='${SSH_CONNECTION:+\[\e[37m\]\u@\h:\[\e[0m\]}$(_rc_prompt_dir)\[\e[0m\] \$ '
fi

# init *env
if command -v asdf > /dev/null; then
  # zsh gets _asdf from Homebrew's site-functions.
  if [ "$_rc_shell" = bash ]; then
    eval "$(asdf completion bash)"
  fi
  _rc_java_home="${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/java/set-java-home.$_rc_shell"
  if [ -f "$_rc_java_home" ]; then
    . "$_rc_java_home"
  fi
  unset _rc_java_home
fi

if [ -f "$HOME/.profile_local" ]; then
  . "$HOME/.profile_local"
fi

if command -v direnv > /dev/null; then
  eval "$(direnv hook $_rc_shell)"
fi

if command -v zoxide > /dev/null; then
  eval "$(zoxide init $_rc_shell)"
fi

# `fzf --zsh` / `fzf --bash` need fzf 0.48+. Older versions only have scripts:
# ~/.fzf.* generated by fzf's install script, which also puts ~/.fzf/bin in
# PATH (so fzf need not be found yet), or the ones shipped by Debian.
if command -v fzf > /dev/null && _rc_fzf="$(fzf --$_rc_shell 2> /dev/null)"; then
  eval "$_rc_fzf"
elif [ -f ~/.fzf.$_rc_shell ]; then
  . ~/.fzf.$_rc_shell
elif command -v fzf > /dev/null && [ -f /usr/share/doc/fzf/examples/key-bindings.$_rc_shell ]; then
  . /usr/share/doc/fzf/examples/key-bindings.$_rc_shell
fi
unset _rc_fzf

if [ "$TERM_PROGRAM" = vscode ]; then
  # Agents in the VS Code terminal read command output directly; a pager
  # would wait for input.
  export GH_PAGER="" GIT_PAGER=""
  # Shell integration lets Copilot detect when a command has finished.
  if command -v code > /dev/null; then
    _rc_vscode="$(code --locate-shell-integration-path $_rc_shell)"
    [ -f "$_rc_vscode" ] && . "$_rc_vscode"
    unset _rc_vscode
  fi
fi

unset _rc_shell
