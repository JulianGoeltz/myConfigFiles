#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh


if [ "$(ifconfig enp0s31f6 | grep -c inet)" -gt 1 ]; then
	echo -n "Eth: "
	echo -n "$(ethtool enp0s31f6  2>/dev/null| grep Speed | awk '{print $2}')"
	echo
fi

