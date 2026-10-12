#!/bin/bash


cleanLink="$(xclip -o -selection clipboard | \
grep -oP "url=\K[^=&]*" | \
jq -Rr @urid)"
echo "$cleanLink" | xclip -i -selection clipboard

notify-send "cleaned link" "$cleanLink"
