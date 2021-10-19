#!/bin/bash

# set -euo pipefail

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
	if [ "$tmp_len" -gt 200 ]; then
		arg="set"
	else
		arg="unset"
	fi
fi
if [[ "$arg" == "set" ]]; then
	echo -n "Setting proxy for (current) shell, git"
	export ftp_proxy=http://proxy.kip.uni-heidelberg.de:2121
	export http_proxy=http://proxy.kip.uni-heidelberg.de:8080
	export https_proxy=http://proxy.kip.uni-heidelberg.de:8080

	export GIT_SSH_COMMAND="ssh -F ~/.ssh/config_prox"
	alias ssh="ssh -F ~/.ssh/config_prox"

	# spotify
	if [[ $# -gt 0 ]]; then
		echo ", spotify"
		( if grep "network.proxy.mode=1" ~/.config/spotify/prefs -q; then
			spotifyRunning=false
			if pgrep -c spotify >/dev/null; then
				spotifyRunning=true
				spotifyPlaying=$(playerctl -p spotify status)
				killall spotify
				sleep 1
			fi
			sed -i 's/network.proxy.mode=1/network.proxy.mode=3/g' ~/.config/spotify/prefs
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
	echo -n "Removing proxy from (current) shell, git"
	export ftp_proxy=
	export http_proxy=
	export https_proxy=

	unset GIT_SSH_COMMAND
	unalias ssh 2>/dev/null

	# spotify
	if [[ $# -gt 0 ]]; then
		echo ", spotify"
		( if grep "network.proxy.mode=3" ~/.config/spotify/prefs -q; then
			spotifyRunning=false
			if pgrep -c spotify >/dev/null; then
				spotifyRunning=true
				spotifyPlaying=$(playerctl -p spotify status)
				killall spotify
				sleep 1
			fi
			sed -i 's/network.proxy.mode=3/network.proxy.mode=1/g' ~/.config/spotify/prefs
			if $spotifyRunning; then
				i3-msg exec /usr/bin/spotify >/dev/null
				sleep 1
				[[ $spotifyPlaying == "Playing" ]] && playerctl -p spotify play
			fi
		fi & )
	else
		echo
	fi
elif [[ "$arg" == "proxify" ]] && [[ "$#" -gt 1 ]]; then
	# to execute a command in a proxified environment
	# used for Telegram in i3_config
	cmd=$2
	shift 2
	source "$0"
	$cmd
else
	echo "argument has to be 'set' or 'unset', or 'proxify [command]', not '$@'"
fi

