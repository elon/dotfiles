# executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# if not running interactively, don't do anything
[ -z "$PS1" ] && return

[[ -s "$HOME/.bash_private" ]] && . "$HOME/.bash_private"

# notify bg job completion immediately
set -o notify

set -o vi

# don't put duplicate lines in the history
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=10000
HISTFILESIZE=11000

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

[[ -s "$HOME/.bash_prompt" ]] && source "$HOME/.bash_prompt"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

[[ -d "$HOME/bin" ]] && PATH="$HOME/bin:$PATH"

if [ -f ~/.bash_functions ]; then
	source ~/.bash_functions
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	. /etc/bash_completion
fi

if [[ -f "$HOME/.ec2_keys" ]]; then
	source "$HOME/.ec2_keys";
fi

if [[ -f "$HOME/.aws_access_keys" ]]; then
	source "$HOME/.aws_access_keys";
fi

export EDITOR=vim
export SVN_EDITOR=vim
export RUBYLIB=~/.ruby # added to the search path
export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:bin/javac::")
# export ANDROID_LOG_TAGS="TAGNAME:D *:W"

[[ -s "$HOME/.bash_exports.local" ]] && source "$HOME/.bash_exports.local"

export PATH=$(puniq $PATH)

test -n "$INTERACTIVE" -a -n "$LOGIN" && {
	uname -npsr
	uptime
}

# set up rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
