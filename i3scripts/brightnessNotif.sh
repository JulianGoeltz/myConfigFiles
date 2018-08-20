#!/bin/sh

round() {
	echo $((($1 + $2/2)/$2))
}

# xbacklight takes a bit to reflect change (default time 200ms)
sleep 0.3 

# if larger than 5 round to nearest 10:
num=$(xbacklight | xargs printf '%.*f' 0)
if [ "$num" -gt "5" ]; then
	num=$(($(round $num 10)*10))
fi

notify-send -c "Brightness" "Brightness $num%"
