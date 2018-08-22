#!/bin/sh
# shell script to prepend i3status with more stuff

# define colours:
Cfg="#d3d7cf"
Cbg="#2e3436"
Cfggrey="#b3b7af"
CspecialCyan="#06989a"

#Define the battery
Battery() {
        BATPERC=$(acpi --battery | cut -d, -f2)
	BATPERC="%{F$Cfg}Batt: $(acpi -b | grep  -o "[0-9]*%" | head -n1) & $(acpi -b | grep  -o "[0-9]*%"| tail -n1) %{F#0F0}$(acpi -b |grep -o "Charging")%{F#f00}$(acpi -b |grep -o "Discharging")%{F$Cfg}"
        echo " $BATPERC "
}

#define the date
Date() {
	echo "%{F$Cfg} $(date +" %a %d %b %R ") "
}

#define the host
Host() {
	echo "%{B$Cfg}%{F$Cbg} on %{F$CspecialCyan}$(hostname) %{B$Cbg}%{F$Cfg}"
}

#define spotify shitness
Playing() {
	if [ "$(playerctl status)" = "Playing" ]; then
		echo "$(playerctl metadata artist | head -c 20): $(playerctl metadata title | head -c 20) | $(Volume)"
	fi
}

#define bluetooth shitness
alias bluetoothqc="~/based-connect-master/based-connect $(echo 'quit' | bluetoothctl | grep -o '\S* [LE-]*Bose QC35'|grep -o '\S*:\S*')"
Volume() {
	# if bluetooth is attached select volume of that one, and also print battery
	# otherwise jsut first volume
	correctSink=$(/home/julgoe/.config/i3/scripts/correctSinkForChangingVolume.sh)
	text=$(pactl list sinks | pcregrep -M "Sink #$correctSink(.|\n)*?Volume.*?$")
       	retval=$(echo $text | grep -oP "Volume: .*?\%" | grep -oP "[0-9]*%")

	if $(echo $text | grep -q "Mute: yes"); then
		retval=$retval"(Muted)"
	fi
	if [ "$correctSink" -gt "0" ]; then
		batt=$(bluetoothqc -b)
		retval="$retval (QC $batt% battery)"
	fi
	echo " %{F$Cfggrey}Vol. $retval %{F$Cfg}"
}

# print the status line
while true; do
	echo "%{B$Cbg}%{F$Cfg}%{c}$(Playing) %{r}$(Host)|$(Battery)|$(Date)"
        sleep 1;
done
