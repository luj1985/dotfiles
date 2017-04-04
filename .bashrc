#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
#alias ll='ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ll='ls -l'
alias la='ls -la'

alias vi='vim'
alias npm="npm --registry=https://registry.npm.taobao.org \
  --cache=$HOME/.npm/.cache/cnpm \
  --disturl=https://npm.taobao.org/dist \
  --userconfig=$HOME/.npmrc"

export EDITOR="vim"
export VISUAL=$EDITOR
export PATH=${HOME}/bin:${HOME}/.npm-packages/bin:$PATH

alias rm='echo "Use trash instead"; false'

PS1='[\u@\h \W]\$ '
