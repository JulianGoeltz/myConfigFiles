#!/bin/bash

# set -euo pipefail
source /home/$USER/myConfigFiles/i3blockscripts/blocks_defines.sh

tmpQCbatteryFile=/tmp/qcbattery
tmpTWbatteryFile=/tmp/TWbattery

if [ -n "${button}" ]; then
	# notify-send $button
	case "${button}" in
		"1")
			pactl set-sink-mute $(/bin/sh ~/.config/i3/scripts/correctSinkForChangingVolume.sh) toggle && pkill -SIGRTMIN+20 i3blocks
			;;
		"2"|"5")
			pactl set-sink-volume $(/bin/sh ~/.config/i3/scripts/correctSinkForChangingVolume.sh) -10% && pkill -SIGRTMIN+20 i3blocks
			;;
		"3"|"4")
			pactl set-sink-volume $(/bin/sh ~/.config/i3/scripts/correctSinkForChangingVolume.sh) +10% && pkill -SIGRTMIN+20 i3blocks
			;;
	esac
fi

batteryQC() {
	if ! [ -f $tmpQCbatteryFile ] || [ $(($(date +%s) - $(stat -c %Y $tmpQCbatteryFile))) -gt 60 ]; then
		if [[ $# -eq 0 ]]; then
			address=$(echo 'devices Paired' | bluetoothctl | grep -oE '\S* [LE-]*Bose (QC|QuietComfort)35'|grep -o '\S*:\S*')
		else
			address=$1
		fi
		based-connect $address -b > $tmpQCbatteryFile
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
		retval="$retval ($emojiBattery $2%)"
	fi
	echo "$retval" 
}

# standardName="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink"
standardName="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
standardNameHeadphone="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Headphones__sink"
sinkList=$(pactl -f json list sinks)
standardSink=$(echo "$sinkList" | jq '.[] | select (.name == "'${standardName}'") | .index')
standardSinkHP=$(echo "$sinkList" | jq '.[] | select (.name == "'${standardNameHeadphone}'") | .index')

echo -n "$(Volume $standardSink)"
echo -n "$(Volume $standardSinkHP)"

for bluezSink in $(echo $sinkList | jq '.[] | select (.name | match("bluez")) | .index' ); do
	# get battery for bose qc35
	# echo $bluezSink >&2
	bluezSinkDesc="$(echo $sinkList | jq '.[] | select (.index == '"$bluezSink"') | .description')"
	if [[ "$bluezSinkDesc" =~ "35" ]] || [[ "$bluezSinkDesc" =~ "Silver" ]]; then
		qc_battery=$(batteryQC $(echo $sinkList | jq --raw-output '.[] | select (.index == '"$bluezSink"') | .properties | ."device.string"'))
	elif [[ "$(echo $sinkList | jq '.[] | select (.index == '"$bluezSink"') | .description')" == '"MOMENTUM TW 3"' ]] ; then
		# qc_battery="$(echo $sinkList | jq '.[] | select ( .index == '$bluezSink' ) | .properties."bluetooth.battery"')"
		# qc_battery=${qc_battery:1:-2}
		qc_battery=$(echo info $(echo $sinkList | jq --raw-output '.[] | select (.index == '"$bluezSink"') | .properties | ."device.string"') | bluetoothctl | grep -oP 'Battery Percentage: 0x[0-f]* \(\K[0-9]*')
	elif [[ "$(echo $sinkList | jq '.[] | select (.index == '"$bluezSink"') | .description')" == '"Bose Mini II SoundLink"' ]] ; then
		qc_battery=$(echo info $(echo $sinkList | jq --raw-output '.[] | select (.index == '"$bluezSink"') | .properties | ."device.string"') | bluetoothctl | grep -oP 'Battery Percentage: 0x[0-f]* \(\K[0-9]*')
	else
		qc_battery=""
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
