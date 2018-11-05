#!/bin/bash

if xrandr | grep -q 'DP2-2 connected' &&
	[ "$(xrandr | grep --after-context=1 'DP2-2' | grep -c DP2)" -eq 1 ]; then
	# second condition because it takes time to adapt to dockingstation
	# Connected to Docking Station
	echo "setting xrandr for dockingstation in office"
	# check if already set
	if xrandr | grep "eDP1" | grep -q "+0+" && 
		xrandr | grep "DP2-2" | grep -q "+1920+" &&
		xrandr | grep "DP2-3" | grep -q "+0+"; then
		echo "already set, exiting."
		exit
	fi
	xrandr --output VIRTUAL1 --off 
	xrandr --output DP2-2 --off
	xrandr --output DP2-3 --off
	xrandr --output DP2-2 --mode 1920x1080 --right-of eDP1
	xrandr --output DP2-3 --mode 1920x1080 --same-as eDP1
	# maybe turn DP2-3 off and on again (in xrandr)
else
	# assume no other display connected, use only laptop
	echo "setting xrandr for mobile use"
	xrandr --output eDP1 --auto --primary
	xrandr --output DP2-2 --off
	xrandr --output DP2-3 --off
	#xrandr --output DP2-2 --same-as eDP1 || xrandr --output DP2-2 --off
	#xrandr --output DP2-3 --same-as eDP1 || xrandr --output DP2-3 --off
fi

#cat /etc/systemd/logind.conf
