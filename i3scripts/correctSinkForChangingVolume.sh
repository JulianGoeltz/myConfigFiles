#!/bin/sh

tmpString=$(pactl list sinks | grep --context=2 bluez | grep -P "Sink #[0-9]*" | grep -oP "[0-9]*")
if [ -z $tmpString ] ; then
	echo 0
else
	echo $tmpString
fi
