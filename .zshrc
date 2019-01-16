# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/user/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Load my old settings
. ~/.bashrc
