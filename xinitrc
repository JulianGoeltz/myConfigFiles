
# load xresources properly
xrdb ~/.Xdefaults

# exec /home/julgoe/.local/bin/i3
eval $(dbus-launch --auto-syntax) /usr/bin/i3
