#!/bin/bash

# set -euo pipefail

doBeforeAndAfter(){
	# in general set keyboard option nocaps
	setxkbmap -option caps:escape
	xset r rate 300 50

	# always set audio input profile to duplex to have a microphone
	pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo 2>/dev/null
	# turn off bern hdmi monitor audio output
	pactl set-card-profile alsa_card.usb-C-Media_Electronics_Inc._USB_Audio_Device-00 off 2>/dev/null
}
doBeforeAndAfter

edp1="eDP-1"
dp12="DP-1-2"
dp22="DP-2-2"
dp23="DP-2-3"
dp2Base="DP-2"

hdmi2="HDMI-2"

if [ $# -gt 1 ]; then
	# set up three monitor setup
	dunstify -r 5555 -t 3000 "setting xrandr in office special"
	xbacklight -set 100
	~/.config/i3/scripts/changeBrightness.sh high
	xrandr --output $dp22 --mode 2560x1440 --primary
	xrandr --output $edp1 --off
	xrandr --output $edp1 --mode 1920x1080 --left-of $dp22
	xrandr --output $dp23 --mode 1920x1080 --right-of $dp2h
	exit
elif [ $# -gt 0 ]; then
	xrandr --output $edp1 --auto --primary
	xrandr --output $dp22 --off
	xrandr --output $dp23 --off
	exit
fi

if xrandr | grep -q "$dp22 connected" &&
	[ "$(xrandr | grep --after-context=1 "$dp22" | grep -c "$dp2Base")" -eq 1 ]; then
	# second condition because it takes time to adapt to dockingstation
	# Connected to Docking Station
	dunstify -r 5555 -t 3000 "setting xrandr for dockingstation in office"
	# check if already set
	if xrandr | grep "$edp1" | grep -q "+2560+0" && 
		xrandr | grep "$dp22" | grep -q "+0+0" &&
		xrandr | grep "$dp23" | grep -q "+2560+0"; then
		dunstify -r 5566 "xrandr already set, exiting."
		exit
	fi
	~/.config/i3/scripts/changeBrightness.sh low
	# xrandr --output VIRTUAL1 --off 
	xrandr --output $dp22 --off
	# xrandr --output $dp23 --off
	xrandr --output $dp23 --mode 1920x1080
	xrandr --output $dp22 --mode 2560x1440 --left-of $dp23 --primary
	xrandr --output $edp1 --same-as $dp23
	# for presentation setting with reduced resolution:
	# xrandr --output DP-2-2 --mode 1920x1080 --primary --output DP-2-3 --mode 1920x1080 --right-of DP-2-2 --output eDP-1 --same-as DP-2-3
	# maybe turn $dp23 off and on again (in xrandr)
	# turn down screen brightness on edp1
elif xrandr | grep -q "$dp12 connected"; then
	dunstify -r 5555 -t 3000 "setting xrandr in Bern"
	if xrandr | grep "$edp1" | grep -q "1920x1080+2560+0" &&
		xrandr | grep "$dp12" | grep -q "2560x1440+0+0"; then
		dunstify -r 5566 "xrandr already set, exiting."
		exit
	fi
	xrandr --output "$dp12" --mode 2560x1440 --primary --output eDP-1 --off
	sleep 0.5
	xrandr --output "$dp12" --mode 2560x1440 --primary --output eDP-1 --right-of "$dp12" --mode 1920x1080
elif xrandr | grep -q "$hdmi2 connected"; then
	dunstify -r 5555 -t 3000 "setting xrandr for one external HDMI"
	xrandr --output "$hdmi2" --above eDP-1 --mode 1920x1080 --rotate normal
	# set audio correctly
	pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:hdmi-stereo-extra1
else
	# assume no other display connected, use only laptop
	~/.config/i3/scripts/changeBrightness.sh high
	dunstify -r 5555 -t 3000 "setting xrandr for mobile use"
	xrandr --output $edp1 --auto --primary
	xrandr --output $dp12 --off
	xrandr --output $dp22 --off
	xrandr --output $dp23 --off
	xrandr --output $hdmi2 --off
	#xrandr --output $dp22 --same-as $edp1 || xrandr --output $dp22 --off
	#xrandr --output $dp23 --same-as $edp1 || xrandr --output $dp23 --off
	# turn up screen brightness again
	pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo
fi

#cat /etc/systemd/logind.conf
doBeforeAndAfter
