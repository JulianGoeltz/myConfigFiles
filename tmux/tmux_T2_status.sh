#!/bin/bash

# set -euo pipefail

# the following comes from i3 status
# ethernet
Ethernet() {
	if [ "$(ifconfig enp0s31f6 | grep -c addr)" -gt 1 ]; then
		echo -n "Eth: "
		# string=$(ifconfig enp0s31f6)
		echo -n "$(ethtool enp0s31f6  2>/dev/null| grep Speed | sed -E 's/.*Speed: ([0-9]*Mb\/s).*/\1/')"
		echo
	fi
}
# wifi
Wifi() {
	string=$(iw dev wlp4s0 link)
	if [ "$(echo "$string" | grep -c off/any)" -eq 0 ]; then
		echo -n "Wifi: "
		echo -n "$(echo "$string" | grep -oP "SSID: \K.*")"
		signalstr=$(echo "$string" | grep "Signal level" | sed -E 's/.*Signal level=-([2-9]*) dBm.*/\1/')
		# echo -n " at $signalstr"
		signalstr=$(((100-signalstr)*2))
		signalstr=$((signalstr > 100 ? 100 : signalstr))
		signalstr=$((signalstr < 0 ? 0 : signalstr))
		printf " at%4u%%" $signalstr
	fi
}
# vpn
Vpn() {
	if ifconfig tun0 &>/dev/null; then
		echo -n "VPN:"
		ps --no-headers -o command "$(pgrep openconnect)" | awk '{print $2}'
	fi
}


ethernet=$(Ethernet)
wifi=$(Wifi)
# vpn=$(Vpn)
echo -n "#[fg=white,bg=black]"
if [ -n "$ethernet" ]; then
       	echo -n "$ethernet |"
elif [ -n "$wifi" ]; then
       	echo -n " $wifi |"
fi
# [ -n "$vpn" ] && echo -n " $vpn |"
# echo -n "#[fg=black,bg=white] on #[fg=cyan]$(hostname) #[fg=white,bg=black]| "
echo -n " Batt: $(acpi -b | grep  -o '[0-9]*%' | head -n1) & $(acpi -b | grep  -o '[0-9]*%'| tail -n1) "
echo -n "#[fg=green]$(acpi -b |grep -o "Charging")#[fg=red]$(acpi -b |grep -o "Discharging") "
echo -n "#[fg=white]| $(date +'%a %d %b %R ')"
# seconds show with %S
