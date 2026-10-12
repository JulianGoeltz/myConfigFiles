#!/bin/bash

# set -euo pipefail
source /home/$USER/myConfigFiles/i3blockscripts/blocks_defines.sh

if [ -n "${button}" ]; then
	case "${button}" in
		"1")
			/bin/sh ~/.config/i3/scripts/playpausetoggle.sh play-pause
			;;
		"2")
			/bin/sh ~/.config/i3/scripts/playpausetoggle.sh previous
			;;
		"3")
			/bin/sh ~/.config/i3/scripts/playpausetoggle.sh next
			;;
	esac
fi


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
for p in $(playerctl -l | grep chromium); do
	echo -n $(Playing $p)
done
echo
