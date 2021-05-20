#!/bin/bash

# set -euo pipefail


if [ "$1" = "pause" -a "$(dunstctl is-paused)" = 'false' ]; then
	dunstify -r 2222 -t 2000 'Turning off notifications'
	sleep 2
	dunstctl set-paused true
elif [ "$1" = "resume" ]; then
	if [ "$(dunstctl is-paused)" = 'true' ]; then
		dunstctl set-paused false
		dunstify -t 2000 'Enabled notifications again'
	else
		dunstify -r 1111 -t 2000 'dunst already running'
	fi
fi
