#!/bin/bash

if [ -n "$(xrandr | grep 'DP2-2 connected')" ] ; then
	# HDMI output is connected, i.e. probably in office, enlarge laptop display
	xrandr --output eDP1 --off --output DP2-2 --auto --primary
	xrandr --output DP2-3 --auto --left-of DP2-2
else
	# assume no other display connected, use only laptop
	xrandr --output DP2-2 --off --output DP2-3 --off --output eDP1 --auto --primary
fi
