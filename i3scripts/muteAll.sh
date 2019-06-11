#!/bin/sh

for sink in $(pactl list sinks | grep -P "^Sink #[0-9]*" | grep -oP "[0-9]*"); do
	pactl set-sink-mute "$sink" 1
	pactl set-sink-volume "$sink" 0
done
