#!/bin/sh

# set -euo pipefail

alsa=$(pactl list short sinks | grep "alsa_output" | awk '{print $1}')
tmpString=$(pactl list short sinks | grep "bluez" | awk '{print $1}')
if [ -z "$tmpString" ] ; then
	echo "$alsa"
else
	echo "$tmpString"
fi
