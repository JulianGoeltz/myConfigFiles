
# load xresources properly
xrdb ~/.Xdefaults

# enable tapping 
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled"

# disable caps lock and use as additional ctrl 
[ -n "$DISPLAY" ] && setxkbmap -option ctrl:nocaps

# exec /home/julgoe/.local/bin/i3
eval $(dbus-launch --auto-syntax) /usr/bin/i3
