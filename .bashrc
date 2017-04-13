#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --group-directories-first --time-style=+"%Y-%m-%d %H:%M" --color=auto -F'
alias ll='ls -l'
alias la='ls -la'

alias vi='vim'
alias npm="npm --registry=https://registry.npm.taobao.org \
  --cache=$HOME/.npm/.cache/cnpm \
  --disturl=https://npm.taobao.org/dist \
  --userconfig=$HOME/.npmrc"

alias depclean='sudo pacman -Rsn $(pacman -Qdtq)'
alias open='xdg-open'
alias rm='echo "Use trash instead"; false'

PS1='[\u@\h \W]\$ '

export EDITOR="vim"
export VISUAL=$EDITOR
export PATH=${HOME}/bin:${HOME}/.npm-packages/bin:$PATH
export PATH=$PATH:/opt/anaconda/bin

_byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export PATH="$PATH:$HOME/.rvm/bin"

