#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh

eth () {
	if [ "$(ifconfig "$1" 2>/dev/null | grep -c inet)" -gt 1 ]; then
		echo -n "Eth: "
		echo -n "$(ethtool "$1"  2>/dev/null| grep Speed | awk '{print $2}')"
		echo
	fi
}

# my eth
eth enp0s31f6

# billis adapter
eth enp0s13f0u3u4

# bern adapter
eth enp0s13f0u3u3c2
