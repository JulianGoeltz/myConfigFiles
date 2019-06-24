#!~/bin/sh

# set -eu

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/ 
# this is necessary as i had to copy lib to /usr/local/lib like
# sudo cp /home/julgoe/tmp/playerctl/playerctl/.libs/libplayerctl-1.0.so* /usr/local/lib/

# playerctl play-pause

# first direct to spotify, then vlc or general
if playerctl -l | grep -q spotifyd; then
	playerctl --player=spotifyd "$1"
elif playerctl -l | grep -q spotify; then
	playerctl --player=spotify "$1"
elif playerctl -l | grep -q vlc; then
	playerctl --player=vlc "$1"
else
	playerctl -a "$1"
fi
