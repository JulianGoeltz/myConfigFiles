#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh


if ifconfig tun0 &>/dev/null; then
	echo -n "VPN:"
	ps --no-headers -o command "$(pgrep openconnect)" | awk '{print $2}'
fi
