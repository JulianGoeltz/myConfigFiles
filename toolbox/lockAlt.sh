#!/bin/bash

# set -euo pipefail

# pausing dunst to not show notifs on lock screen
state_of_dunst=$(dunstctl is-paused)
dunstctl set-paused true

xrandr --output DP2-2 --mode 1920x1080 --same-as eDP1

/usr/bin/google-chrome-stable "/home/julgoe/Documents/apple_update_screen/macOSUpdates.html"  --proxy-server="foopy:99" --kiosk 2>/dev/null

/home/julgoe/myConfigFiles/toolbox/screenSet.sh

# resuming if it wasn't paused before locking; but sleep first
sleep 3
[[ "$state_of_dunst" = 'false' ]] && dunstctl set-paused false
