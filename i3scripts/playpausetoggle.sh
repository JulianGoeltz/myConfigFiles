#~/bin/sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/ 
# this is necessary as i had to copy lib to /usr/local/lib like
# sudo cp /home/julgoe/tmp/playerctl/playerctl/.libs/libplayerctl-1.0.so* /usr/local/lib/

# playerctl play-pause
playerctl $1
