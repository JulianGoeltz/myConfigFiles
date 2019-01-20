#!/bin/bash


if [ "$1" = "pause" -a "$(cat ~/.tmp_dunststate)" = 'running' ]; then
	dunstify -r 2222 -t 2000 'Turning off notifications'
	echo paused > /home/julgoe/.tmp_dunststate
	sleep 2
	dunstify 'DUNST_COMMAND_PAUSE'
elif [ "$1" = "resume" ]; then
	if [ "$(cat ~/.tmp_dunststate)" = 'paused' ]; then
		dunstify 'DUNST_COMMAND_RESUME'
		dunstify -t 2000 'Enabled notifications again'
		exec echo 'running' > /home/julgoe/.tmp_dunststate
	else
		dunstify -r 1111 -i dialog-information -t 2000 'dunst already running'
	fi
fi
