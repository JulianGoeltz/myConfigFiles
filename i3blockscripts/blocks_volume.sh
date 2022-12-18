#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh

tmpQCbatteryFile=/tmp/qcbattery

bluetoothqc() {
	if ! [ -f $tmpQCbatteryFile ] || [ $(($(date +%s) - $(stat -c %Y $tmpQCbatteryFile))) -gt 60 ]; then
		address=$(echo 'devices Paired' | bluetoothctl | grep -oE '\S* [LE-]*Bose (QC|QuietComfort)35'|grep -o '\S*:\S*')
		based-connect $address $@ > $tmpQCbatteryFile
	fi
	cat $tmpQCbatteryFile
}

Volume() {
	[ "$#" -eq "0" ] && return

	correctSink=$1
	# get full text of only the correct sink
	info="$(pactl -f json list sinks | jq '.[] | select (.index == '"$correctSink"')')"
	# text=$(pactl list sinks | pcregrep -M "Sink #$correctSink(.|\n)*?Formats:$")
       	# retval=$(echo "$text" | grep -oP --max-count=1 "Volume: .*?\%" | grep -oP "[0-9]*%")
	retval="$(echo $info | jq '.volume[].value_percent' | head -n1)"
	retval=${retval:1:-1}

	# mute info
	if [[ "$(echo "$info" | jq '.mute')" == "true" ]]; then
		retval="$emojiMute $retval"
	else
		retval="$emojiVolume $retval"
	fi

	# add additional info
	echo "$info" | jq '.active_port' | grep -qi "headphones" && \
		retval="$retval $emojiHeadphone"
	echo "$info" | grep -q "HDMI" && \
		retval="$retval $emojiTV"

	# battery info
	if [ "$#" -gt 1 -a "$1" -ne "0" ]; then
		retval="$retval (QC $emojiBattery $2%)"
	fi
	echo "$retval" 
}

sinkList=$(pactl -f json list sinks)
standardSink=$(echo "$sinkList" | jq '.[] | select (.name == "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink") | .index')

echo -n "$(Volume $standardSink)"

bluezSink=$(echo "$sinkList" | grep "bluez" | awk '{print $1}')
for bluezSink in $(echo $sinkList | jq '.[] | select (.name | match("bluez")) | .index' ); do
	# get battery for bose qc35
	echo $bluezSink >&2
	if echo $sinkList | jq '.[] | select (.index == '"$bluezSink"') | .description' | grep -q "35"; then
		qc_battery=$(bluetoothqc -b)
		echo  $qc_battery>&2
	else
		qc_battery=""
		echo  qc_battery>&2
	fi

	# display microphone if headset unit active
	if echo "$sinkList" | jq '.[] | select (.index == '"$bluezSink"') | .properties."bluetooth.protocol"' | grep -q _head_unit; then
		bluetoothheadset=" ${emojiMicrophone}"
	else
		bluetoothheadset=""
	fi

	echo -n " | $(Volume "$bluezSink" $qc_battery)${bluetoothheadset}"
	qc_shown=true
done

# to get line break
echo
