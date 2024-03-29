#!/bin/bash

declare -a  mac_array=("2C_41_A1_07_D2_28" "04_52_C7_34_22_DB" "00_1B_66_CA_9C_76" "08_DF_1F_86_0B_30" "80_C3_BA_2F_85_57")

# check if bluez connected
status="$(pactl list sinks short | grep bluez)"
if [ -z "$status" ]; then
	notify-send "no bluez connected"
	return
fi

# notify-send "$status"

# loop through mac addresses
for mac in "${mac_array[@]}"; do
	# determine if given
	# substatus="$(echo status | grep $mac)"
	substatus="$(pactl list sinks short | grep $mac)"
	if [ -z "$substatus" ]; then
		# notify-send "mac '${mac}' not in status"
		# notify-send "substatus: $substatus"
		continue
	fi
	# determine what current status is
	if echo "$substatus" | grep _head_unit; then
		pactl set-card-profile bluez_card.$mac a2dp_sink
	else
		pactl set-card-profile bluez_card.$mac handsfree_head_unit || \
		pactl set-card-profile bluez_card.$mac headset_head_unit
	fi
	/home/julgoe/myConfigFiles/toolbox/pactldefault.sh
	pkill -SIGRTMIN+20 i3blocks
	exit
done
