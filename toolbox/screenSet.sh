#!/bin/bash

if [ $# -gt 1 ]; then
	# set up three monitor setup
	notify-send -t 3000 "setting xrandr in office special"
	xbacklight -set 100
	xrandr --output DP2-3 --mode 1920x1080 --primary
	xrandr --output eDP1 --off
	xrandr --output eDP1 --mode 1920x1080 --left-of DP2-3
	xrandr --output DP2-2 --mode 1920x1080 --right-of DP2-3
	exit
elif [ $# -gt 0 ]; then
	xrandr --output eDP1 --auto --primary
	xrandr --output DP2-2 --off
	xrandr --output DP2-3 --off
	exit
fi

if xrandr | grep -q 'DP2-2 connected' &&
	[ "$(xrandr | grep --after-context=1 'DP2-2' | grep -c DP2)" -eq 1 ]; then
	# second condition because it takes time to adapt to dockingstation
	# Connected to Docking Station
	notify-send -t 3000 "setting xrandr for dockingstation in office"
	# check if already set
	if xrandr | grep "eDP1" | grep -q "+0+" && 
		xrandr | grep "DP2-2" | grep -q "+1920+" &&
		xrandr | grep "DP2-3" | grep -q "+0+"; then
		notify-send "xrandr already set, exiting."
		exit
	fi
	xbacklight -set 10
	xrandr --output VIRTUAL1 --off 
	xrandr --output DP2-2 --off
	xrandr --output DP2-3 --off
	xrandr --output DP2-2 --mode 1920x1080 --right-of eDP1
	xrandr --output DP2-3 --mode 1920x1080 --same-as eDP1
	# maybe turn DP2-3 off and on again (in xrandr)
	# turn down screen brightness on edp1
else
	# assume no other display connected, use only laptop
	xbacklight -set 100
	notify-send -t 3000 "setting xrandr for mobile use"
	xrandr --output eDP1 --auto --primary
	xrandr --output DP2-2 --off
	xrandr --output DP2-3 --off
	#xrandr --output DP2-2 --same-as eDP1 || xrandr --output DP2-2 --off
	#xrandr --output DP2-3 --same-as eDP1 || xrandr --output DP2-3 --off
	# turn up screen brightness again
fi

#cat /etc/systemd/logind.conf
