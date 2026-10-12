#!/bin/bash

set -euo pipefail


file=~/.ssh/mails.txt

arg=$( (
	cat $file
	) |
	rofi -config /home/$USER/.config/rofi/config.rasi -dmenu -p "which email?")


dunstify "copying mail" "${arg}"

echo -n "${arg}" | xclip -i -selection clipboard

