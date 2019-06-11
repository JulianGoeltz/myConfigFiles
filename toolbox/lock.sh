#!/bin/bash
# inspired by https://www.reddit.com/r/unixporn/comments/7df2wz/i3lock_minimal_lockscreen_pretty_indicator/

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
/home/julgoe/bin/i3lock -nte -B4 \
    --insidecolor=373445ff --ringcolor=ffffffff --line-uses-inside \
    --keyhlcolor=d23c3dff --bshlcolor=d23c3dff --separatorcolor=00000000 \
    --insidevercolor=000000ff --insidewrongcolor=d23c3dff \
    --ringvercolor=ffffffff --ringwrongcolor=ffffffff --indpos="x+86:y+86" \
    --radius=15 --veriftext="" --wrongtext="" --noinputtext=""
# resuming if it wasn't paused beofre locking
[[ "$(cat ~/.tmp_dunststate)" = "running" ]] && pkill -u "$USER" -USR2 dunst
