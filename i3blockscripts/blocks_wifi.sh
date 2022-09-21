#!/bin/sh

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh

# state DOWN is not sufficient for turned off
if ip link show wlp4s0 | grep -q "state DOWN mode DEFAULT"; then
	echo "$emojiWifiOff"
	return
fi
string=$(iw dev wlp4s0 link)
if [ "$?" -eq 0 ] && [ "$(echo "$string" | grep -c "Not connected.")" -eq 0 ]; then
	echo -n "Wifi: "
	echo -n "$(echo "$string" | grep -oP "SSID: \K.*")"
	signalstr=$(echo "$string" | grep "Signal level" | sed -E 's/.*Signal level=-([0-9]*) dBm.*/\1/')
	signalstr=$(((100-signalstr)*2))
	signalstr=$((signalstr > 100 ? 100 : signalstr))
	signalstr=$((signalstr < 0 ? 0 : signalstr))
	printf " at%4u%%" $signalstr
fi
# in ICEs show some fun information
if [[ "$(echo "$string" | grep -oP "SSID: \K.*")" =~ "(WIFIonICE|WIFI@DB|freeWIFIahead!)" ]]; then
	python ~/.config//i3/scripts/db_wifi.py
fi
echo
