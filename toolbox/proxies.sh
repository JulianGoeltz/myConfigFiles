#!/bin/bash

arg=$1
# in order to ssh through proxy
# ssh git@github.com -o "ProxyCommand=connect -5S proxy.kip.uni-heidelberg.de:1080 %h %p"
if [ $# -eq 0 ]; then
	if [ -z "$DISPLAY" ]; then
		echo "Not setting proxies on TTY"
		return
	fi
	# if stopped due to timeout, it unsets
	tmp_len=$(wget --no-proxy --timeout=1 -qO- http://www.kip.uni-heidelberg.de/proxy 2>/dev/null | wc -c)
	if [ $? -ne 0 ]; then
		echo "Problem calling kip proxy with wget, do manually with set/unset"
		return
	fi
	if [ $tmp_len -gt 200 ]; then
		arg="set"
	else
		arg="unset"
	fi
fi
if [[ "$arg" == "set" ]]; then
	echo -n "Setting proxy for (current) shell, git, apt"
	export ftp_proxy=http://proxy.kip.uni-heidelberg.de:2121
	export http_proxy=http://proxy.kip.uni-heidelberg.de:8080
	export https_proxy=https://proxy.kip.uni-heidelberg.de:8080

	export GIT_SSH_COMMAND="ssh -F ~/.ssh/config_prox"

	# setting the proxy in the file /etc/apt/apt.conf
	# this will only work if it is writeable
	# i.e. chmod u+x /etc/apt/apt.conf has been called
	# (temporaruly writes to a /tmp file, this way no sudo is necessary)
	escaped_http=${http_proxy/\/\//\\\/\\\/}
	escaped_https=${https_proxy/\/\//\\\/\\\/}
	tmpFilename=/tmp/aptconfInplaceReplace$$
	# if config doesnt have proxy part insert it
	if ! grep -q Proxy /etc/apt/apt.conf ; then
		echo 'Acquire::http::Proxy "";' >> /etc/apt/apt.conf
		echo 'Acquire::https::Proxy "";' >> /etc/apt/apt.conf
	fi
	cp /etc/apt/apt.conf $tmpFilename
	sed -i -e 's/Acquire::http::Proxy "[a-zA-Z0-9:/.-]*";/Acquire::http::Proxy "'$escaped_http'";/g' $tmpFilename
	sed -i -e 's/Acquire::https::Proxy "[a-zA-Z0-9:/.-]*";/Acquire::https::Proxy "'$escaped_https'";/g' $tmpFilename
	cat $tmpFilename > /etc/apt/apt.conf
	rm $tmpFilename

	# spotify
	if [[ $# -gt 0 ]]; then
		echo ", spotify"
		( if grep "network.proxy.mode=1" ~/.config/spotify/prefs -q; then
			spotifyRunning=false
			if ps aux | grep -v grep | grep -q spotify; then
				spotifyRunning=true
				spotifyPlaying=$(playerctl -p spotify status)
				killall spotify
				sleep 1
			fi
			sed -i 's/network.proxy.mode=1/network.proxy.mode=2/g' ~/.config/spotify/prefs
			if $spotifyRunning; then
				i3-msg exec /usr/bin/spotify >/dev/null
				sleep 1
				[[ $spotifyPlaying == "Playing" ]] && playerctl -p spotify play
			fi
		fi & )
	else
		echo
	fi
elif [[ "$arg" == "unset" ]]; then
	echo -n "Removing proxy from (current) shell, git, apt"
	export ftp_proxy=
	export http_proxy=
	export https_proxy=

	unset GIT_SSH_COMMAND

	tmpFilename=/tmp/aptconfInplaceReplace$$
	# if config doesnt have proxy part insert it
	if ! grep -q Proxy /etc/apt/apt.conf ; then
		echo 'Acquire::http::Proxy "";' >> /etc/apt/apt.conf
		echo 'Acquire::https::Proxy "";' >> /etc/apt/apt.conf
	fi
	cp /etc/apt/apt.conf $tmpFilename
	sed -i 's/Acquire::http::Proxy "[a-zA-Z0-9:/.-]*";/Acquire::http::Proxy "";/g' $tmpFilename
	sed -i 's/Acquire::https::Proxy "[a-zA-Z0-9:/.-]*";/Acquire::https::Proxy "";/g' $tmpFilename
	cat $tmpFilename > /etc/apt/apt.conf
	rm $tmpFilename

	# spotify
	if [[ $# -gt 0 ]]; then
		echo ", spotify"
		( if grep "network.proxy.mode=2" ~/.config/spotify/prefs -q; then
			spotifyRunning=false
			if ps aux | grep -v grep | grep -q spotify; then
				spotifyRunning=true
				spotifyPlaying=$(playerctl -p spotify status)
				killall spotify
				sleep 1
			fi
			sed -i 's/network.proxy.mode=2/network.proxy.mode=1/g' ~/.config/spotify/prefs
			if $spotifyRunning; then
				i3-msg exec /usr/bin/spotify >/dev/null
				sleep 1
				[[ $spotifyPlaying == "Playing" ]] && playerctl -p spotify play
			fi
		fi & )
	else
		echo
	fi
elif [ "$arg" == "proxify" -a $# -gt 1 ]; then
	# to execute a command in a proxified environment
	# used for Telegram in i3_config
	cmd=$2
	shift 2
	source $0
	$cmd
else
	echo "argument has to be set or unset, not $1"
fi

