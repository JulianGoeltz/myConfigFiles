#!/bin/zsh

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh

# state DOWN is not sufficient for turned off
if ip link show wlp0s20f3 | grep -q "state DOWN mode DEFAULT"; then
	echo "$emojiWifiOff"
	return
fi
string=$(iw dev wlp0s20f3 link)
if [ "$?" -eq 0 ] && [ "$(echo "$string" | grep -c "Not connected.")" -eq 0 ]; then
	echo -n "Wifi: "
	echo -n "$(echo "$string" | grep -oP "SSID: \K.*")"
fi
# in some trains show fun information
wifi_ssid="$(echo "$string" | grep -oP "SSID: \K.*")"
if [[ "$wifi_ssid" =~ "(WIFIonICE|WIFI@DB|freeWIFIahead!|_SNCF_WIFI_INOUI|Portaleregionale FNM)" ]]; then
	python ~/.config//i3/scripts/db_wifi.py "$wifi_ssid"
fi
echo
