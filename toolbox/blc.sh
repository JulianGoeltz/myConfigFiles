#!/bin/bash

set -euo pipefail


curr_connected="$(bluetoothctl devices Connected | 	while read -r line; do echo "${line:25:99} "; done )"

arg=$((
	bluetoothctl devices | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" |
		while read -r line; do echo "${line:25:99}|${line:7:18}"; done |
		sort -r |
		column --separator="|" -t --output-separator="|    ";
	echo "Already connected";
	bluetoothctl devices Connected | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" |
		while read -r line; do echo "${line:25:99}"; done |
		sort -r
		#column --separator="|" -t --output-separator="|    "
	) |
	# cut  -f1,2 | column --separator="|" -t --output-separator="    " --table-right 1 |
	# --table-right 1 |
	rofi -config /home/julgoe/.config/rofi/config.rasi -dmenu -p "which device to connect to?")

echo "return to function"

for mac in $(bluetoothctl devices Connected | cut --delimiter=' ' -f2); do bluetoothctl disconnect $mac& done

mac=$(echo ${arg} | cut --delimiter '|' -f2)

echo "chose '$arg'"
echo "trying to connect to '$mac'"

bluetoothctl connect $mac

pkill -SIGRTMIN+20 i3blocks
