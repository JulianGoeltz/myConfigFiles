#!/bin/bash

arg=$1
# in order to ssh through proxy
# ssh git@github.com -o "ProxyCommand=connect -5S proxy.kip.uni-heidelberg.de:1080 %h %p"
if [ $# -eq 0 ]; then
	tmp_len=$(wget -qO- http://www.kip.uni-heidelberg.de/proxy 2>/dev/null | wc -c)
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
	echo "Setting proxy for (current) shell, git and apt"
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
	cp /etc/apt/apt.conf /tmp/aptconfInplaceReplace
	sed -i -e 's/Acquire::http::Proxy "[a-zA-Z0-9:/.-]*";/Acquire::http::Proxy "'$escaped_http'";/g' /tmp/aptconfInplaceReplace
	sed -i -e 's/Acquire::https::Proxy "[a-zA-Z0-9:/.-]*";/Acquire::https::Proxy "'$escaped_https'";/g' /tmp/aptconfInplaceReplace
	cat /tmp/aptconfInplaceReplace > /etc/apt/apt.conf
	rm /tmp/aptconfInplaceReplace
elif [[ "$arg" == "unset" ]]; then
	echo "Removing proxy from (current) shell, git, apt."
	export ftp_proxy=
	export http_proxy=
	export https_proxy=

	unset GIT_SSH_COMMAND

	cp /etc/apt/apt.conf /tmp/aptconfInplaceReplace
	sed -i 's/Acquire::http::Proxy "[a-zA-Z0-9:/.-]*";/Acquire::http::Proxy "";/g' /tmp/aptconfInplaceReplace
	sed -i 's/Acquire::https::Proxy "[a-zA-Z0-9:/.-]*";/Acquire::https::Proxy "";/g' /tmp/aptconfInplaceReplace
	cat /tmp/aptconfInplaceReplace > /etc/apt/apt.conf
	rm /tmp/aptconfInplaceReplace
elif [ "$arg" == "proxify" -a $# -gt 1 ]; then
	cmd=$2
	shift 2
	source $0
	$cmd
else
	echo "argument has to be set or unset, not $1"
fi

