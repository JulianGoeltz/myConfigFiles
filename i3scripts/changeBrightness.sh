#!/bin/bash

# set -euo pipefail

# in case one is in tty without x:
# $ su
# $ cd /sys/class/backlight/intel-backlight
# $ echo # > brightness
# # the number # can be 0-100
case $1 in
	'up') 
		xbacklight +20
		;;
	'down') 
		xbacklight -20
		;;
	'high') 
		xbacklight -set 100
		;;
	'low') 
		xbacklight -set 1
		;;
esac


round() {
	echo $((($1 + $2/2)/$2))
}
# xbacklight takes a bit to reflect change (default time 200ms)
# sleep 0.4

# if larger than 5 round to nearest 10:
num=$(xbacklight | xargs printf '%.*f' 0)
if [ "$num" -gt 0 -a "$num" -lt 5 ]; then
	num=1
else
	#num=$(($(round $num 10)*10))
	num=$((num / 5))
fi

bar=$(seq -s "─" 0 $num | sed 's/[0-9]//g')

dunstify -i display-brightness-symbolic -r 3333 "$bar"
