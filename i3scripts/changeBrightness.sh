#!/bin/zsh
# set -euo pipefail

cd /sys/class/backlight/intel_backlight/
brightness=$(cat brightness)
max_brightness=$(cat max_brightness)
rel_brightness=$((100 * brightness / max_brightness))
case $1 in
	'up') 
		# xbacklight +20
		if [ "$((rel_brightness))" -lt 80 ]; then
			rel_target=$((rel_brightness + 20))
		else
			rel_target="100"
		fi
		;;
	'down') 
		# xbacklight -20
		if [ "$rel_brightness" -gt 20 ]; then
			rel_target=$((rel_brightness - 20))
		else
			rel_target=0
		fi
		;;
	'high') 
		# xbacklight -set 100
		rel_target="100"
		;;
	'low') 
		# xbacklight -set 1
		rel_target=1
		;;
	*)
		rel_target="$rel_brightness"
esac
target=$((rel_target * max_brightness / 100))
# the following produces some output ($1)
sudo /usr/local/bin/change_brightness.sh "$target"

# xbacklight takes a bit to reflect change (default time 200ms)
# sleep 0.4

blockLeft=▕
blockRight=▏
blockBlank=⠀
blockFull=█

brightnessSymbol=🔅

# num=$(xbacklight | xargs printf '%.*f' 0)
brightness=$(cat brightness)
num=$(echo $(($brightness * 100.0 / $max_brightness)) | xargs printf '%.*f' 0)
if [ "$num" -gt 0 -a "$num" -lt 5 ]; then
	num=1
else
	num=$((num / 5))
fi

bar="$brightnessSymbol$blockLeft$( echo "$(seq -s "$blockFull" 0 $num)$(seq -s "$blockBlank" $num 20 )" | tr -d 0,1,2,3,4,5,6,7,8,9)$blockRight"

dunstify -r 3333 "$bar"
