#!/bin/zsh
# shell script to prepend i3status with more stuff

# define colours:
Cfg="#d3d7cf"
Cbg="#2e3436"
Cfggrey="#b3b7af"
CspecialCyan="#06989a"

#emojis (easily searched on https://emojipedia.org/)
emojiHeadphone=🎧
emojiBattery=🔋
emojiVolume=🔊
emojiMute=🔇

#Define the battery
Battery() {
        BATPERC=$(acpi --battery | cut -d, -f2 | tr -d '\n')
	echo "$emojiBattery $BATPERC"
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
	if [ "$(playerctl -p "$player" status)" = "Playing" ]; then
		artist=$(playerctl -p "$player" metadata artist)
		title=$(playerctl -p "$player" metadata title)
		[ "${#artist}" -gt "23" ] && artist="${artist:0:20}..."
		[ "${#title}" -gt "23" ] && title="${title:0:20}..."
		# in order for special chars to be properly escaped use json function above
		tmp=$(json_escape "$artist - $title")
		# but this uses quotes, get rid of them
		echo "𝅘𝅥𝅮 ${tmp:1:-1}"
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
	string=$(iwconfig wlp4s0)
	if [ "$?" -eq 0 ] && [ "$(echo "$string" | grep -c off/any)" -eq 0 ]; then
		echo -n "Wifi: "
		echo -n "$(echo "$string" | grep ESSID | sed -E 's/.*ESSID:"(.*?)".*/\1/')"
		signalstr=$(echo "$string" | grep "Signal level" | sed -E 's/.*Signal level=-([0-9]*) dBm.*/\1/')
		signalstr=$(((100-signalstr)*2))
		signalstr=$((signalstr > 100 ? 100 : signalstr))
		signalstr=$((signalstr < 0 ? 0 : signalstr))
		printf " at%4u%%" $signalstr
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
	# if bluetooth is attached select volume of that one, and also print battery
	# otherwise jsut first volume
	[ "$#" -eq "0" ] && return

	correctSink=$1
	text=$(pactl list sinks | pcregrep -M "Sink #$correctSink(.|\n)*?Volume.*?$")
       	retval=$(echo "$text" | grep -oP "Volume: .*?\%" | grep -oP "[0-9]*%")

	if echo "$text" | grep -q "Mute: yes"; then
		retval="$emojiMute $retval"
	else
		retval="$emojiVolume $retval"
	fi
	if [ "$correctSink" -eq "0" ] &&
		pactl list sinks | grep -q "Active Port: analog-output-headphones"; then
		retval="$retval $emojiHeadphone"
	fi
	if [ -n "$2" ]; then
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
alias bluetoothqc='based-connect $(echo "quit" | bluetoothctl | grep -o "\S* [LE-]*Bose QC35" | grep -o "\S*:\S*")'

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

	echo '  { "full_text": "'"$(Volume 0)"'", "color":"'$Cfggrey'"},'
	correctSink=$(/home/julgoe/.config/i3/scripts/correctSinkForChangingVolume.sh)
	if [ "$correctSink" -ne 0 ]; then
		# boombox is sink != 0 too but cant communicate with bluetoothqc
		if pactl list sinks | grep -q "Description:.*35"; then
			if ! $qc_shown || [ "$((counter%100))" -eq 0 ] ; then
				qc_battery=$(bluetoothqc -b)
			fi
		else
			qc_battery=""
		fi
		echo '  { "full_text": "'"$(Volume "$correctSink" "$qc_battery")"'", "color":"'$Cfggrey'"},'
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
