#!/bin/sh


if [ "$1" = "pause" -a "$(cat ~/.tmp_dunststate)" = 'running' ]; then
	notify-send -t 2000 'Turning off notifications'
	echo paused > /home/julgoe/.tmp_dunststate
	sleep 2
	notify-send 'DUNST_COMMAND_PAUSE'
elif [ "$1" = "resume" -a "$(cat ~/.tmp_dunststate)" = 'paused' ]; then
	notify-send 'DUNST_COMMAND_RESUME'
	notify-send -t 2000 'Enabled notifications again'
	exec echo 'running' > /home/julgoe/.tmp_dunststate
fi
