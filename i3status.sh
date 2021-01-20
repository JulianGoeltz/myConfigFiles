#!/bin/zsh
# shell script to prepend i3status with more stuff

# define colours:
Cfg="#d3d7cf"
Cbg="#2e3436"
Cfggrey="#b3b7af"
CspecialCyan="#06989a"

#emojis (easily searched on https://emojipedia.org/)
emojiBattery=🔋
emojiHeadphone=🎧
emojiMute=🔇
emojiTune=🎵
emojiTV=📺
emojiVolume=🔊

#Define the battery
Battery() {
        BATPERC=$(acpi --battery | cut -d, -f2 | tr -d '\n')
	echo "$emojiBattery$BATPERC"
}

#define the date
Date() {
	echo "$(date +" %a %d %b %R ") "
}

#define the host
Host() {
	echo " on $(hostname) "
}

#define spotify shitness
json_escape () {
	# from https://stackoverflow.com/questions/10053678/escaping-characters-in-bash-for-json
	printf '%s' "$1" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}
Playing() {
	player=$1
	if [ "$(playerctl -p "$player" status 2>/dev/null)" = "Playing" ]; then
		artist=$(playerctl -p "$player" metadata artist)
		title=$(playerctl -p "$player" metadata title)
		tmp=$?
		if [ "$tmp" -eq "0" ]; then
			[ "${#artist}" -gt "23" ] && artist="${artist:0:20}..."
			[ "${#title}" -gt "23" ] && title="${title:0:20}..."
			tmp="$artist - $title"
		else
			tmp=$(basename $( playerctl -p "$player" metadata xesam:url))
			[ "${#tmp}" -gt "43" ] && tmp="${tmp:0:40}..."
		fi
		# in order for special chars to be properly escaped use json function above
		tmp=$(json_escape "$tmp")
		# but this uses quotes, get rid of them
		echo "$emojiTune ${tmp:1:-1}"
	fi
}

# ethernet
Ethernet() {
	if [ "$(ifconfig enp0s31f6 | grep -c addr)" -gt 1 ]; then
		echo -n "Eth: "
		echo -n "$(ethtool enp0s31f6  2>/dev/null| grep Speed | awk '{print $2}')"
		echo
	fi
}
# wifi
Wifi() {
	string=$(iw dev wlp4s0 link)
	if [ "$?" -eq 0 ] && [ "$(echo "$string" | grep -c "Not connected.")" -eq 0 ]; then
		echo -n "Wifi: "
		echo -n "$(echo "$string" | grep -oP "SSID: \K.*")"
		signalstr=$(echo "$string" | grep "Signal level" | sed -E 's/.*Signal level=-([0-9]*) dBm.*/\1/')
		signalstr=$(((100-signalstr)*2))
		signalstr=$((signalstr > 100 ? 100 : signalstr))
		signalstr=$((signalstr < 0 ? 0 : signalstr))
		printf " at%4u%%" $signalstr
	fi
	# in ICEs show some fun information
	if [ "$(echo "$string" | grep -oP "SSID: \K.*")" = "WIFIonICE" ]; then
		python ~/.config//i3/scripts/ice_wifi.py
	fi
}
# vpn
Vpn() {
	if ifconfig tun0 &>/dev/null; then
		echo -n "VPN:"
		ps --no-headers -o command "$(pgrep openconnect)" | awk '{print $2}'
	fi
}

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
	if [ -n "$2" -a "$1" -ne "0" ]; then
		retval="$retval (QC $emojiBattery $2%)"
	fi
	echo "$retval" 
}

# see whether there is a pdflatex instance running
Pdfcompiling() {
	if pidof pdflatex >/dev/null; then
		echo "pdflatex running"
	fi
	if pidof lualatex >/dev/null; then
		echo "lualatex running"
	fi
}

#define bluetooth shitness
alias bluetoothqc='based-connect $(echo "paired-devices" | bluetoothctl | grep -o "\S* [LE-]*Bose QC35" | grep -o "\S*:\S*")'

# Send the header so that i3bar knows we want to use JSON:
echo '{"version":1}'
# Begin the endless array.
echo '['

# We send an empty first array of blocks to make the loop simpler:
echo '[],'
# print the status line
counter=0
qc_shown=false
while true; do
	echo "["
	if [ "$((counter%6))" -eq 0 ]; then
		playing_spotify=$(Playing spotify)
		playing_spotifyd=$(Playing spotifyd)
		playing_vlc=$(Playing vlc)

		pdfcompiling=$(Pdfcompiling)
	fi

	echo '  { "full_text": "'"$pdfcompiling"'"},'

	echo '  { "full_text": "'"$playing_spotify"'"},'
	echo '  { "full_text": "'"$playing_spotifyd"'"},'
	echo '  { "full_text": "'"$playing_vlc"'"},'

	# when changing alsa config to hdmi, a sink with id != 0 is created, thus get correct sink
	sinkList=$(pactl list short sinks)
	standardSink=$(echo "$sinkList" | grep "alsa_output.pci-0000_00_1f.3" | awk '{print $1}' | tail -n1)
	echo '  { "full_text": "'"$(Volume $standardSink)"'", "color":"'$Cfggrey'"},'
	bluezSink=$(echo "$sinkList" | grep "bluez" | awk '{print $1}')
	if [ "$(echo "$sinkList" | wc -l )" -gt "1" ]; then
		# boombox is sink != 0 too but cant communicate with bluetoothqc
		if pactl list sinks | grep -q "Description:.*35"; then
			if ! $qc_shown || [ "$((counter%100))" -eq 0 ] ; then
				qc_battery=$(bluetoothqc -b)
			fi
		else
			qc_battery=""
		fi
		echo '  { "full_text": "'"$(Volume "$bluezSink" "$qc_battery")"'", "color":"'$Cfggrey'"},'
		qc_shown=true
	else
		qc_shown=false
	fi

	if [ "$((counter%6))" -eq 0 ]; then
		ethernet=$(Ethernet)
		wifi=$(Wifi)
		vpn=$(Vpn)
	fi
	echo '  { "full_text": "'"$ethernet"'" }, '
	echo '  { "full_text": "'"$wifi"'" }, '
	echo '  { "full_text": "'"$vpn"'" }, '


	echo '  { "full_text": "<span bgcolor=\"'$Cfg'\"> on </span>", "markup":"pango", "color":"'$Cbg'", "separator":false, "separator_block_width": 0 },'
	echo '  { "full_text": "<span bgcolor=\"'$Cfg'\" weight=\"bold\">'"$(hostname)"' </span>", "markup":"pango", "color":"'$CspecialCyan'" },'

	echo '  { "full_text": "'"$(Battery)"'", "separator":false, "separator_block_width": 0},'
	echo '  { "full_text": " '"$(acpi -b |grep -o "Charging")"'", "color":"#00ff00", "separator":false, "separator_block_width": 0},'
	echo '  { "full_text": " '"$(acpi -b |grep -o "Discharging")"'", "color":"#ff0000", "separator":false, "separator_block_width": 0},'
	echo '  { "full_text": " "},'

	echo '  { "full_text": "'"$(Date)"'" }'
	echo "],"
	counter=$((counter+3))
	sleep 3;
done
