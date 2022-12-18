#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh


Playing() {
	player=$1
	if [ "$(playerctl -p "$player" status 2>/dev/null)" = "Playing" ]; then
		artist="$(playerctl -p "$player" metadata artist 2>&1)"
		if [ "$?" -ne "0" ]; then
			artist="$(playerctl -p "$player" metadata xesam:albumArtist 2>&1)"
		fi
		title=$(playerctl -p "$player" metadata title)
		tmp=$?
		if [ "$tmp" -eq "0" ]; then
			[ "${#artist}" -gt "23" ] && artist="${artist:0:20}..."
			[ "${#title}" -gt "23" ] && title="${title:0:20}..."
			tmp="$artist - $title"
		else
			tmp=$(basename $( playerctl -p "$player" metadata xesam:url))
			[ "${#tmp}" -gt "43" ] && tmp="${tmp:0:40}..."
		fi
		echo "$emojiTune $tmp"
	fi
}

echo -n $(Playing spotify)
echo -n $(Playing spotifyd)
echo -n $(Playing vlc)
# echo -n $(Playing chromium)
echo
