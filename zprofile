#!zsh
if systemctl -q is-active graphical.target; then
	if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
		startx
	fi
fi
