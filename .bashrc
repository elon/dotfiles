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
HISTIGNORE=srm*:cryptsetup*:truecrypt*:mount*:umount*

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

[[ -f ~/.aliases ]] && source ~/.aliases

[[ -d "$HOME/bin" ]] && PATH="$HOME/bin:$PATH"

if [ -f ~/.bash_functions ]; then
	source ~/.bash_functions
fi

trap clean_on_logout EXIT

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

# might have already been defined in ~/.bash_private
if [ -z $JAVA_HOME ]; then
    export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:bin/javac::")
fi

# export ANDROID_LOG_TAGS="TAGNAME:D *:W"

[[ -s "$HOME/.bash_exports.local" ]] && source "$HOME/.bash_exports.local"

test -n "$INTERACTIVE" -a -n "$LOGIN" && {
	uname -npsr
	uptime
}


# terminal mess
# if ever move off of gnome-terminal http://www.reddit.com/r/vim/comments/1a29vk/fixing_vims_background_color_erase_for_256color/
# remember: 16 color, gnome-terminal, gnome-terminal to remote, gnome-terminal to remote with tmux
# fix gnome-terminal - keep this below prompt definition
if [[ $TERM=="xterm" && $COLORTERM=="gnome-terminal" ]]; then
	export TERM="xterm-256color"
fi
# for tmux: export 256color
if [ -n "$TMUX" ]; then
    color_term=$COLORTERM
    if [ -n "$SSH_CLIENT" ]; then
        color_term="gnome-terminal"
    fi
    case $color_term in
        rxvt-xpm) export TERM=screen-256color ;;         # urxvt
        Terminal) export TERM=screen-256color ;;         # XFCE
        gnome-terminal) export TERM=screen-256color ;;   # gnome-terminal
    esac
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
# git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
if [ -d $HOME/.rbenv ]; then
	export PATH="$HOME/.rbenv/bin:$PATH"
	eval "$(rbenv init -)"
elif [ -d $HOME/.rvm ]; then
	[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
	PATH=$PATH:$HOME/.rvm/bin
fi

if [ -d $HOME/.nvm ]; then
    . ~/.nvm/nvm.sh
fi

# expose gnome-keyring to shell under xfce
if [ "$DESKTOP_SESSION" == "xfce" ];then
    eval $(gnome-keyring-daemon --start --components=ssh)
    export SSH_AUTH_SOCK
fi

export PATH=$(puniq $PATH)
