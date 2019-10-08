#!/bin/bash
set -euo pipefail

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

# xbacklight takes a bit to reflect change (default time 200ms)
# sleep 0.4

blockLeft=▕
blockRight=▏
blockBlank=⠀
blockFull=█

brightness=🔅

num=$(xbacklight | xargs printf '%.*f' 0)
if [ "$num" -gt 0 -a "$num" -lt 5 ]; then
	num=1
else
	num=$((num / 5))
fi

bar="$brightness$blockLeft$( echo "$(seq -s "$blockFull" 0 $num)$(seq -s "$blockBlank" $num 20 )" | tr -d 0,1,2,3,4,5,6,7,8,9)$blockRight"

dunstify -i display-brightness-symbolic -r 3333 "$bar"
