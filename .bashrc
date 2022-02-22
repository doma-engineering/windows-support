# If not running interactively, don't do anything
[[ $- != *i* ]] && return]

set -o vi

export EDITOR="vim"
export TERM="screen-256color"

ps1_date="\[$(tput bold)\]\[$(tput setaf 40)\]\$(date +'%a %b %d %H:%M:%S:%N')"
ps1_user="\[$(tput setaf 41)\]\u\[$(tput setaf 40)\]@\[$(tput setaf 41)\]\h"
ps1_path="\[$(tput setaf 40)\]\w"
ps1_lambda="\[$(tput setaf 40)\]λ\[$(tput sgr0)\]"
for x in {0..256}; do
  ps1_tester="${ps1_tester}\[$(tput setaf $x)\]$x"
done

git_prompt() {
  local ref="$(git symbolic-ref -q HEAD 2>/dev/null)"
  if [ -n "$ref" ]; then
    echo "$(tput setaf 241)(${ref#refs/heads/}) "
  fi
}

# ALIASES
alias rg='rg --color=always'
alias less='less -R'
alias emacs='emacs -nw'
alias vi='emacsclient -c -nw'
alias ls='ls -p'
alias p='proxychains4'
alias docker='sudo docker'
alias docker-compose='sudo docker-compose'

# HISTORY
HISTCONTROL=ignoredups:erasedups
HISTIGNORE=' *'
HISTSIZE=''
shopt -s histappend

# ENV
export PS1="${ps1_date} ${ps1_user} ${ps1_path} \$(git_prompt)\n${ps1_lambda} "
export PATH=$HOME/.local/bin:$HOME/github/usr-local-bin:$PATH:$HOME/npm/bin:$HOME/github/mkbook/bin
export GPG_AGENT_INFO  # the env file does not contain the export statement
export SSH_AUTH_SOCK   # enable gpg-agent for ssh

# IT'S A TRAP
#trap 'echo -ne "\033]2;$(pwd); $(history 1 | sed "s/^[ ]*[0-9]*[ ]*//g")\007"' DEBUG

MAIL="/var/spool/mail/sweater" && export MAIL

#
if [ -e /home/sweater/.nix-profile/etc/profile.d/nix.sh ]; then . /home/sweater/.nix-profile/etc/profile.d/nix.sh; fi

# Android bullshit
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Direnv!
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
source $HOME/.nix-profile/share/nix-direnv/direnvrc
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
eval "$(direnv hook bash)"

# boostrap_home_manager.sh: https://raw.githubusercontent.com/cognivore/nix-home/main/boostrap_home_manager.sh
export PATH=$HOME/.local/nbin:$PATH
