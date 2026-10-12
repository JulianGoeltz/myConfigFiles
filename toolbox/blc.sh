#!/bin/bash

#set -euo pipefail
set -eu


curr_connected="$(echo devices Connected | bluetoothctl | grep Device | while read -r line; do echo "${line:25:99} "; done )"

arg=$((
	echo devices | bluetoothctl | grep Device | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" |
		while read -r line; do echo "${line:25:99}|${line:7:18}"; done |
		sort -r |
		column --separator="|" -t --output-separator="|    ";
	echo "Already connected";
	echo devices Connected | bluetoothctl | grep Device | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" |
		while read -r line; do echo "${line:25:99}"; done |
		sort -r
		#column --separator="|" -t --output-separator="|    "
	) |
	# cut  -f1,2 | column --separator="|" -t --output-separator="    " --table-right 1 |
	# --table-right 1 |
	rofi -config /home/$USER/.config/rofi/config.rasi -dmenu -p "which device to connect to?")

echo "return to function"

for mac in $(echo devices Connected | bluetoothctl | grep Device | cut --delimiter=' ' -f2); do echo disconnect $mac | bluetoothctl& done

mac=$(echo ${arg} | cut --delimiter '|' -f2)

echo "chose '$arg'"
echo "trying to connect to '$mac'"

echo connect $mac | bluetoothctl

pkill -SIGRTMIN+20 i3blocks
