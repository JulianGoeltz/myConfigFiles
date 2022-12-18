#!/bin/sh

# set -eu

for sink in $(pactl list short sinks | cut -f1); do
	pactl set-sink-mute "$sink" 1
	pactl set-sink-volume "$sink" 0
done
