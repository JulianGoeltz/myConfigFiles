#!zsh
if systemctl -q is-active graphical.target; then
	if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
		startx --keeptty >~/.Xorg.log 2>&1
	fi
fi
