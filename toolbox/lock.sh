#!/bin/bash
# inspired by https://www.reddit.com/r/unixporn/comments/7df2wz/i3lock_minimal_lockscreen_pretty_indicator/

# set -euo pipefail

# first check whether any other ttys are running
if [ "$(who | grep -oP "tty[0-9]" | sort | uniq | wc -l )" -ne 1 ]; then
	pkill -u "$USER" -USR2 dunst
	notify-send "There is more than one TTY logged in. Lock out of them!"
	exit
fi

# pausing dunst to not show notifs on lock screen
pkill -u "$USER" -USR1 dunst
# previously: 
# i3lock -tbefi /home/julgoe/Pictures/actualBackgrounds/lock_1820.png -c 000000
# -i /home/julgoe/Pictures/actualBackgrounds/lock_1820.png \
i3lock -nte -B4 \
    --inside-color=373445ff --ring-color=ffffffff --line-uses-inside \
    --keyhl-color=d23c3dff --bshl-color=d23c3dff --separator-color=00000000 \
    --insidever-color=000000ff --insidewrong-color=d23c3dff \
    --ringver-color=ffffffff --ringwrong-color=ffffffff --ind-pos="x+86:y+86" \
    --radius=15 --verif-text="" --wrong-text="" --noinput-text=""
# resuming if it wasn't paused beofre locking
sleep 2
[[ "$(cat ~/.tmp_dunststate)" = "running" ]] && pkill -u "$USER" -USR2 dunst
