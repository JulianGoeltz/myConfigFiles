#!/bin/sh

# set -euo pipefail

alsa=$(pactl list short sinks | grep "alsa_output.pci" | awk '{print $1}' | tail -n1)
tmpString=$(pactl list short sinks | grep "bluez" | awk '{print $1}')
if [ -z "$tmpString" ] ; then
	echo "$alsa"
else
	echo "$tmpString"
fi
