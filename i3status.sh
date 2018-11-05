#!/bin/zsh
# shell script to prepend i3status with more stuff

# define colours:
Cfg="#d3d7cf"
Cbg="#2e3436"
Cfggrey="#b3b7af"
CspecialCyan="#06989a"

#Define the battery
Battery() {
        BATPERC=$(acpi --battery | cut -d, -f2)
	BATPERC="Batt: $(acpi -b | grep  -o "[0-9]*%" | head -n1) & $(acpi -b | grep  -o "[0-9]*%"| tail -n1) $(acpi -b |grep -o "Charging")$(acpi -b |grep -o "Discharging")"
        echo " $BATPERC "
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
	if [ "$(playerctl -p spotify status)" = "Playing" ]; then
		artist=$(playerctl -p spotify metadata artist)
		title=$(playerctl -p spotify metadata title)
		[ "$(echo $artist | wc -c )" -gt "23" ] && artist=$(echo "${artist:0:20}...")
		[ "$(echo $title | wc -c )" -gt "23" ] && title=$(echo "${title:0:20}...")
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
		# string=$(ifconfig enp0s31f6)
		echo -n $(ethtool enp0s31f6  2>/dev/null| grep Speed | sed -E 's/.*Speed: ([0-9]*Mb\/s).*/\1/')
		echo
	fi
}
# wifi
Wifi() {
	string=$(iwconfig wlp4s0)
	if [ "$(echo $string | grep -c off/any)" -eq 0 ]; then
		echo -n "Wifi: "
		echo -n $(echo $string | grep ESSID | sed -E 's/.*ESSID:"(.*?)".*/\1/')
		signalstr=$(echo $string | grep "Signal level" | sed -E 's/.*Signal level=-([0-9]*) dBm.*/\1/')
		# echo -n " at $signalstr"
		signalstr=$(((100-$signalstr)*2))
		signalstr=$(($signalstr > 100 ? 100 : $signalstr))
		signalstr=$(($signalstr < 0 ? 0 : $signalstr))
		printf " at%4u%%" $signalstr
	fi
}
# vpn
Vpn() {
	if $(ifconfig tun0 2>&1 1>/dev/null); then
		echo -n "VPN:"
		ps aux | grep openconnect | grep -v grep | grep -o "openconnect .*" | grep -o " .*" | head -n 1
	fi
}

#define bluetooth shitness
alias bluetoothqc="~/based-connect-master/based-connect $(echo 'quit' | bluetoothctl | grep -o '\S* [LE-]*Bose QC35'|grep -o '\S*:\S*')"
Volume() {
	# if bluetooth is attached select volume of that one, and also print battery
	# otherwise jsut first volume
	[ "$#" -eq "0" ] && return

	correctSink=$1
	text=$(pactl list sinks | pcregrep -M "Sink #$correctSink(.|\n)*?Volume.*?$")
       	retval=$(echo $text | grep -oP "Volume: .*?\%" | grep -oP "[0-9]*%")

	if $(echo $text | grep -q "Mute: yes"); then
		retval="🔇  $retval"
	else
		retval="🔊  $retval"
	fi
	if [ "$#" -gt "1" ]; then
		retval="$retval (QC 🔋 $2%)"
	fi
	echo "$retval" 
}

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
	#echo "%{B$Cbg}%{F$Cfg}%{c}$(Playing) %{r}$(Host)|$(Battery)|$(Date)"
	echo "["
	# echo '  { "full_text": "lalala", "color":"#ffffff" },'
	echo '  { "full_text": "'$(Playing)'"},'

	echo '  { "full_text": "'$(Volume 0)'", "color":"'$Cfggrey'"},'
	correctSink=$(/home/julgoe/.config/i3/scripts/correctSinkForChangingVolume.sh)
	if [ "$correctSink" -ne 0 ]; then
		if ! $qc_shown || [ "$(($counter%100))" -eq 0 ]; then
			qc_battery=$(bluetoothqc -b)
		fi
		echo '  { "full_text": "'$(Volume $correctSink $qc_battery)'", "color":"'$Cfggrey'"},'
		qc_shown=true
	else
		qc_shown=false
	fi

	if [ "$(($counter%5))" -eq 0 ]; then
		ethernet=$(Ethernet)
		wifi=$(Wifi)
		vpn=$(Vpn)
	fi
	echo '  { "full_text": "'$ethernet'" }, '
	echo '  { "full_text": "'$wifi'" }, '
	echo '  { "full_text": "'$vpn'" }, '


	echo '  { "full_text": "<span bgcolor=\"'$Cfg'\"> on </span>", "markup":"pango", "color":"'$Cbg'", "separator":false, "separator_block_width": 0 },'
	echo '  { "full_text": "<span bgcolor=\"'$Cfg'\" weight=\"bold\">'$(hostname)' </span>", "markup":"pango", "color":"'$CspecialCyan'" },'

	# echo '  { "full_text": "'$(Battery)'", "color":"#ffffff"},'
	echo '  { "full_text": "🔋  '$(acpi -b | grep  -o "[0-9]*%" | head -n1)' & '$(acpi -b | grep  -o "[0-9]*%"| tail -n1)'", "separator":false, "separator_block_width": 0},'
	echo '  { "full_text": " '$(acpi -b |grep -o "Charging")'", "color":"#00ff00", "separator":false, "separator_block_width": 0},'
	echo '  { "full_text": " '$(acpi -b |grep -o "Discharging")'", "color":"#ff0000", "separator":false, "separator_block_width": 0},'
	echo '  { "full_text": " "},'
	#BATPERC="<b>Batt: $(acpi -b | grep  -o "[0-9]*%" | head -n1) & $(acpi -b | grep  -o "[0-9]*%"| tail -n1) $(acpi -b |grep -o "Charging")$(acpi -b |grep -o "Discharging")</b>"

	echo '  { "full_text": "'$(Date)'" }'
	echo "],"
	counter=$(($counter+1))
	sleep 1;
done
