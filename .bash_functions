alias be='bundle exec'
alias dir2web="ruby -rwebrick -e 'WEBrick::HTTPServer.new(:DocumentRoot => \".\", :Port => 3001).start'"
alias du2='du -h --max-depth=1'
alias du3='du -chs *| sort -h'
alias fig='find . -type f | grep -v '.git' | grep -v '.swp' | grep -v '.tags' | grep -v _site | xargs grep -i'
alias fn='find . -name'
alias gb='git branch -av'
alias gdc='git diff --cached'
alias gd='git diff'
alias gl='git log --graph --abbrev-commit --pretty=oneline --decorate'
alias gs='git status'
alias h='history'
alias ls2='ls -alF'
alias ls3='ls -alFrt'
alias respork='rkill.rb -v --unless-my-tty watchr; rkill.rb spork; bundle exec spork &'
alias tlog='tail -n 20 -f log/development.log'
alias todos='fig TODO | grep EMF'
alias touchall="find . -type f -exec touch '{}' \;"
alias wget_mirror='wget --mirror –w 2 –p --adjust-extension --convert-links'

pushsshcert() {
    local _host
    test -f ~/.ssh/id_rsa.pub || ssh-keygen -t rsa
    for _host in "$@";
    do
		echo $_host
        ssh $_host 'mkdir ~/.ssh; chmod 700 ~/.ssh'
        ssh $_host 'cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
    done
}

function cdgem() {
	cd `gem env gemdir`/gems
	cd `ls | grep $1 | sort | tail -1`
}

function bigfiles() {
	local bigpath=$1
	if [ -z $bigpath ]; then
		bigpath=`pwd`;
	fi
	local size=$2
	if [ -z $size ]; then
		size=20;
	fi
	du -ak $bigpath |sort -n -r |head -n $size
}

function vims() {
	local servername=$1
	shift
	vim --servername $servername --remote-tab-silent $@
}

function stoprails() {
	if [ -f tmp/pids/unicorn.pid ]; then
		echo "Stopping Unicorn ..."
		kill `cat tmp/pids/unicorn.pid`
	elif [ -f tmp/pids/server.pid ]; then
		echo "Stopping server ..."
		kill `cat tmp/pids/server.pid`
	fi
}

function killrails() {
	ps -e -www -o pid,command |grep unicorn |grep master |grep -v grep |sed 's/^[ ]*//'| cut -d " " -f 1| xargs kill -TERM
}

function bouncerails() {
	killrails
	sleep 0.75
	bundle exec unicorn_rails -D
}

function psg() {
	  ps wwaux | grep "$1" | grep -v grep
}

function puniq () {
	echo "$1" |tr : '\n' |nl |sort -u -k 2,2 |sort -n |cut -f 2- |tr '\n' : |sed -e 's/:$//' -e 's/^://'
}

function ubuntu_version() {
	lsb_release -a 2>/dev/null |grep Description|cut -f 2
}

# http://stackoverflow.com/questions/53569/how-to-get-the-changes-on-a-branch-in-git
function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function gbin { 
	echo branch \($1\) has these commits and \($(parse_git_branch)\) does not 
	git log ..$1 --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local
}

function gbout { 
	echo branch \($(parse_git_branch)\) has these commits and \($1\) does not 
	git log $1.. --no-merges --format='%h | Author:%an | Date:%ad | %s' --date=local
}

function clearlogs {
	for f in `ls log/*.log`
	do
		cat /dev/null > $f
	done
}
