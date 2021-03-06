function sshvm() {
    local ip=`vmips -q $1`
    if [ -n ip ]; then
        ssh $ip
    else
        echo "No IP found"
    fi
}

function clearhistory() {
	history -w && history -c
	cat /dev/null > ~/.bash_history
}

function fig() {
    # if rails project
    # if [ -f "config/environment.rb" ]; then
    # fi
    # unless in assets folder drop assets
    # unless in log folder drop log
	function _fig() {
		find . -type f -print0| grep -z -v '.git' | grep -z -v '.swp' | grep -z -v '.tags' | grep -z -v _site
	}
	if [ $# -eq 1 ]; then
		_fig | xargs -0 grep -i "$1"
	elif [ $# -eq 2 ]; then
		_fig | xargs -0 grep -i -l -Z "$1" | xargs -0 grep -i "$2"
	fi
}

pdfencrypt() {
	local f=$(basename $1)
	pdftk $f output $f.128.pdf user_pw PROMPT
}

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
	_pids=`ps -e -www -o pid,command |grep unicorn |grep master |grep -v grep |sed -e 's/^[ \t]*//'| cut -d " " -f 1`
	if [ -n "$_pids" ];
	then
		kill -TERM $_pids
	fi
}

function bouncerails() {
	stoprails
	sleep 0.5
	if [ -f "config/unicorn.conf" ]; then
		bundle exec unicorn -c config/unicorn.conf -D
	elif [ -f "config/unicorn.rb" ]; then
		bundle exec unicorn -c config/unicorn.rb -D
	else
		bundle exec unicorn_rails -D
	fi
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

function clean_on_logout {
    cleanslate=`which cleanslate`
    if [ -x $cleanslate ]; then
        history -w
        cleanslate -b
        history -c
    fi
}

