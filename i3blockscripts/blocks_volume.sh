#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh

Volume() {
	[ "$#" -eq "0" ] && return

	correctSink=$1
	# get full text of only the correct sink
	text=$(pactl list sinks | pcregrep -M "Sink #$correctSink(.|\n)*?Formats:$")
       	retval=$(echo "$text" | grep -oP --max-count=1 "Volume: .*?\%" | grep -oP "[0-9]*%")

	# mute info
	if echo "$text" | grep -q "Mute: yes"; then
		retval="$emojiMute $retval"
	else
		retval="$emojiVolume $retval"
	fi

	# add additional info
	echo "$text" | grep -q "Active Port: analog-output-headphones" && \
		retval="$retval $emojiHeadphone"
	echo "$text" | grep -q "HDMI" && \
		retval="$retval $emojiTV"

	# battery info
	if [ "$#" -gt 2 -a "$1" -ne "0" ]; then
		retval="$retval (QC $emojiBattery $2%)"
	fi
	echo "$retval" 
}

sinkList=$(pactl list short sinks)
standardSink=$(echo "$sinkList" | grep "alsa_output.pci-0000_00_1f.3" | awk '{print $1}' | tail -n1)

echo -n "$(Volume $standardSink)"

bluezSink=$(echo "$sinkList" | grep "bluez" | awk '{print $1}')
if [ "$(echo "$sinkList" | wc -l )" -gt "1" ]; then
	# get battery for bose qc35
	if pactl list sinks | grep -q "Description:.*35"; then
		if ! $qc_shown || [ "$((counter%100))" -eq 0 ] ; then
			qc_battery=$(bluetoothqc -b)
		fi
	else
		qc_battery=""
	fi

	# display microphone if headset unit active
	if echo "$sinkList" | grep -q _head_unit; then
		bluetoothheadset=" ${emojiMicrophone}"
	else
		bluetoothheadset=""
	fi

	echo -n " | $(Volume "$bluezSink" "$qc_battery")${bluetoothheadset}"
	qc_shown=true
else
	qc_shown=false
fi

# to get line break
echo
