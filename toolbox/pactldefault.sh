#!/bin/bash


if pactl list short sinks | grep -q bluez; then
	pactl set-default-sink "$(pactl list short sinks | grep bluez | cut -f2)"
	notify-send "set default sink to bluez"
else
	pactl set-default-sink alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink
	notify-send "set default sink to speaker"
fi
