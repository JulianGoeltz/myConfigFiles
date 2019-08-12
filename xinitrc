
# load xresources properly
xrdb ~/.Xdefaults

# exec /home/julgoe/.local/bin/i3
exec dbus-launch --autolaunch=$(cat /var/lib/dbus/machine-id) /home/julgoe/.local/bin/i3
