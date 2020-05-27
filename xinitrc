
# load xresources properly
xrdb ~/.Xdefaults

eval $(ssh-agent)

eval $(dbus-launch --auto-syntax) /usr/bin/i3
