#!/bin/bash

# set -euo pipefail

doBeforeAndAfter(){
	# in general set keyboard option nocaps
	setxkbmap -option caps:escape
	xset r rate 300 50
	xset s off
	xset -dpms
	xset s noblank
	xinput set-prop 'SYNA8018:00 06CB:CE67 Touchpad' 'libinput Tapping Enabled' 1

	# # always set audio input profile to duplex to have a microphone
	# pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo 2>/dev/null
	# # turn off bern hdmi monitor audio output
	# pactl set-card-profile alsa_card.usb-C-Media_Electronics_Inc._USB_Audio_Device-00 off 2>/dev/null

	# # make all but HDMI stuff default
	# for sink in alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink bluez_sink.2C_41_A1_07_D2_28.a2dp_sink bluez_sink.04_52_C7_34_22_DB.a2dp_sink bluez_sink.00_1B_66_CA_9C_76.a2dp_sink; do
	# 	pactl list short sinks | grep -q $sink && pactl set-default-sink $sink
	# done
}
doBeforeAndAfter

edp1="eDP-1"
# bern
dp12=DP-3-1
dp12="DVI-I-2-1"
dp12="DVI-I-1-1"
dp12="DVI-I.*"

# EINC office
disp_EINCoffice1="DP-3-2"
disp_EINCoffice2="DP-3-3"
disp_EINC="DP-2"

hdmi2="HDMI-1"
dp121="DP-1-2-1"
dp121="DP-3"

if [ $# -gt 1 ]; then
	# set up three monitor setup
	dunstify -r 5555 -t 3000 "setting xrandr in office special"
	# xbacklight -set 100
	# ~/.config/i3/scripts/changeBrightness.sh high
	# xrandr --output $dp22 --mode 2560x1440 --primary
	# xrandr --output $dp22 --mode 1920x1080 --primary
	# xrandr --output $edp1 --off
	# xrandr --output $edp1 --mode 1920x1080 --left-of $dp22
	# xrandr --output $dp23 --mode 1920x1080 --right-of $dp22
	xrandr \
	--output $disp_EINCoffice1 --mode 2560x1440 \
	--output $disp_EINCoffice2 --mode 2560x1440 --left-of $disp_EINCoffice1 \
	--output $edp1 --auto --primary --left-of $disp_EINCoffice2 \

	exit
elif [ $# -gt 0 ]; then
	xrandr --output $edp1 --auto --primary
	xrandr --output $disp_EINCoffice1 --off
	xrandr --output $disp_EINCoffice2 --off
	exit
fi

if xrandr | grep -q "$disp_EINCoffice1 connected"; then
	# Connected to Docking Station
	dunstify -r 5555 -t 3000 "setting xrandr for dockingstation in EINC office"
	# check if already set
	main_res_x=2560
	main_res_y=1440
	# main_res_x=1920
	# main_res_y=1080
	if xrandr | grep "$disp_EINCoffice1" | grep -q "+${main_res_x}+0" && 
		xrandr | grep "$disp_EINCoffice2" | grep -q "+0+0" ; then
		dunstify -r 5566 "xrandr already set, exiting."
		exit
	fi
	xrandr --output $disp_EINCoffice1 --off --output $disp_EINCoffice2 --off --output $edp1 --primary --mode 1920x1200
	xrandr --output $disp_EINCoffice1 --mode 2560x1440 --primary \
		--output $disp_EINCoffice2 --mode 2560x1440 --left-of $disp_EINCoffice1 \
		--output eDP-1 --off
elif xrandr | grep -q "$dp12 connected"; then
	displayIdentifier="$(xrandr | grep -oP "$dp12(?= connected)")"
	dunstify -r 5555 -t 3000 "setting xrandr in Bern on ${displayIdentifier}"
	# # depending if below or above
	# if xrandr | grep "$edp1" | grep -q "1920x1200+0+1440" &&
	# 	xrandr | grep "$dp12" | grep -q "2560x1440+0+0"; then
	# 	dunstify -r 5566 "xrandr already set, exiting."
	# 	exit
	# fi
	if xrandr | grep "$edp1" | grep -q "1920x1200+0+0" &&
		xrandr | grep "$displayIdentifier" | grep -q "2560x1440+0+1200"; then
		dunstify -r 5566 "xrandr already set, exiting."
		exit
	fi
	xrandr --output "$displayIdentifier" --mode 2560x1440 --primary --output eDP-1 --off
	sleep 0.5
	xrandr --output "$displayIdentifier" --mode 2560x1440 --primary --output eDP-1 --above "$displayIdentifier" --mode 1920x1200
elif xrandr | grep -q "$hdmi2 connected"; then
	dunstify -r 5555 -t 3000 "setting xrandr for one external HDMI"
	xrandr --output "$hdmi2" --above eDP-1 --mode 1920x1080 --rotate normal
	# xrandr --output "$hdmi2" --below eDP-1 --mode 2560x1440 --rotate normal
	# set audio correctly
	# pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:hdmi-stereo-extra1
elif xrandr | grep -q "$dp121 connected"; then
	dunstify -r 5555 -t 3000 "setting xrandr for one external HDMI via USB-C"
	xrandr --output "$dp121" --above eDP-1 --mode 2560x1440 --rotate normal
else
	# assume no other display connected, use only laptop
	# ~/.config/i3/scripts/changeBrightness.sh high
	dunstify -r 5555 -t 3000 "setting xrandr for mobile use"
	xrandr --output $edp1 --auto --primary
	for disp in $(xrandr | grep -v eDP-1 | grep connected | grep -P "[0-9]+x[0-9]+\+[0-9]+\+[0-9]+" | cut -f1 -d " "); do
		xrandr --output $disp --off
	done
	# xrandr --output $dp12 --off
	# xrandr --output $dp22 --off
	# xrandr --output $dp23 --off
	# xrandr --output $hdmi2 --off
	# xrandr --output $dp121 --off
	#xrandr --output $dp22 --same-as $edp1 || xrandr --output $dp22 --off
	#xrandr --output $dp23 --same-as $edp1 || xrandr --output $dp23 --off
	# turn up screen brightness again
	# pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo
fi

#cat /etc/systemd/logind.conf
doBeforeAndAfter
