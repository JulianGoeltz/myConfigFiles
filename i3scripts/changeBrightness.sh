#!/bin/zsh
# set -euo pipefail

case $1 in
	'up') 
		xbacklight +20
		brightness=$(xbacklight -get)
		;;
	'down') 
		xbacklight -20
		brightness=$(xbacklight -get)
		;;
	'high') 
		brightness="50"
		xbacklight -set $brightness
		;;
	'low') 
		xbacklight -set 1
		brightness=1
		;;
	*)
		xbacklight -set $1
		brightness="$1"
esac


dunstify -r 3333 -h int:value:$brightness ""
