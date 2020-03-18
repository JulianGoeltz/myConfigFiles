#!/bin/bash

# set -euo pipefail
LocOfScript=$(dirname "$(readlink -f "$0")")

# check debug options
[ "$1" == "--debug" ] && debug=true || debug=false

# define colours for better output
COLOUR_NON='\033[0m'
COLOUR_RED='\033[0;31m'
COLOUR_ORA='\033[0;33m'
COLOUR_GRE='\033[0;32m'
echo_red (){ echo -en "${COLOUR_RED}"; echo $1; echo -en "${COLOUR_NON}";}
echo_gre (){ echo -en "${COLOUR_GRE}"; echo $1; echo -en "${COLOUR_NON}";}
echo_ora (){ $debug || return; echo -en "${COLOUR_ORA}"; echo $1; echo -en "${COLOUR_NON}";}

# if something goes wrong, change this variable
allWentThrough=true

# evalling a command
evalAndCheckReturn (){
	[ $# -gt 1 ] && expl="${2} (${1})" || expl=$1
	retStr=$(eval "$1" 2>&1)
	retVal=$?
	if [ "$retVal" -ne 0 ]; then
		echo_red "${expl}: ${retVal} (${retStr})"
		allWentThrough=false
	else
		echo_gre "${expl}: Ok"
	fi
}

# linking files
checkSimilaritiesAndLink (){
	orig=$LocOfScript/$1
	dest=$2
	# check if folder structure exists
	if ! [ -d "$(dirname "$dest")" ]; then
		mkdir -p "$(dirname "$dest")"
	fi
	# check if given dest is a link
	if [ -L "$dest" ]; then
		if [[ "$(readlink -f "$dest")" != "$orig" ]]; then
			echo_red "File $dest is a link to $(readlink -f "$dest") and not $orig. Delete manually."
			allWentThrough=false
		else
			echo_ora "File $dest is already linked correctly to $orig."
		fi
	# check if given dest is a file
	elif [ -f "$dest" ]; then
		if [ "$4" = "nolink"  ]; then
			if diff "$orig" "$dest" >/dev/null; then
				echo_ora "File contents of $orig and $dest are the same."
			else
				tmpStr=$(cp "$orig" "$dest" 2>&1)
				if [ "$?" -ne "0" ]; then
					echo_red "$tmpStr"
					if [ "$3" = "sudo"  ]; then
						echo_red "Tried and failed to replace $dest with copy of $orig, try again with sudo BUT CHECK DIFFS BEFORE!!"
					fi
					allWentThrough=false
				else
					echo_gre "Replaced $dest with $orig."
				fi
			fi
		else
			echo_red "File $dest is a regular file, delete manually."
			allWentThrough=false
		fi
	# do the linking
	else
		if [ -e "$dest" ]; then
			echo_red "File $dest is neither link nor regular file, but still exists. Check manually."
			allWentThrough=false
		else
			if [ "$4" = "nolink"  ]; then
				tmpStr=$(cp "$orig" "$dest" 2>&1)
				if [ "$?" -ne "0" ]; then
					echo_red "$tmpStr"
					if [ "$3" = "sudo"  ]; then
						echo_red "Tried and failed to make a copy of $orig at $dest, try again with sudo."
					fi
					allWentThrough=false
				else
					echo_gre "Made a copy of $orig at $dest."
				fi
			else
				tmpStr=$(ln -sv "$orig" "$dest" 2>&1)
				if [ "$?" -ne "0" ]; then
					echo_red "Str"
					if [ "$3" = "sudo"  ]; then
						echo_red "Tried and failed to replace $dest with link to $orig, try again with sudo."
					fi
					allWentThrough=false
				else
					echo_gre "$tmpStr"
				fi
			fi
		fi
	fi
	# echo -en "$NC"

}


echo "This script will setup the config. For that, it will try to link the files, but not replace existing files (no -f force). If there are problems, remove the existing files by hand. This way it is safer."
echo -e "\n\n"



tmpDir=$(pwd)
cd "$LocOfScript"
evalAndCheckReturn "git submodule update --init" "Initting/updating submodules"
evalAndCheckReturn "git config core.hooksPath .githooks" "setting hooksPath"
cd "$tmpDir"
echo -e "\n\n"



echo "--ZSH"
checkSimilaritiesAndLink zshrc "$HOME/.zshrc"
[ ! -d "$HOME/.zsh" ] && mkdir "$HOME/.zsh"
# -d to not list contents of folders
for fn in "$LocOfScript"/zsh/*; do
	checkSimilaritiesAndLink "zsh/$(basename "$fn")" "$HOME/.zsh/$(basename "$fn")"
done

echo "--ssh"
checkSimilaritiesAndLink ssh_config "$HOME/.ssh/config"
# here we use the existing ssh config, which just says which identity files to use, and add a proxied version
cat "$HOME/.ssh/config" > "$HOME/.ssh/config_prox"
cat "$LocOfScript/ssh_config_proxiedgithub" >> "$HOME/.ssh/config_prox"
echo_gre "Combined ~/.ssh/config with local config_prox"
if [[ "$(hostname)" == "helvetica" ]]; then
	checkSimilaritiesAndLink ssh_rc "$HOME/.ssh/rc"
fi

echo "--tmux"
checkSimilaritiesAndLink tmux.conf "$HOME/.tmux.conf"
[ ! -d "$HOME/.tmux" ] && mkdir "$HOME/.tmux"
for fn in "$LocOfScript"/tmux/tmux.conf_*; do
	checkSimilaritiesAndLink tmux/"$(basename "$fn")" "$HOME/.tmux/$(basename "$fn")"
done
checkSimilaritiesAndLink tmux/tmux_T2_status.sh "$HOME/.tmux/tmux_T2_status.sh"
checkSimilaritiesAndLink tmux/plugins/tpm "$HOME/.tmux/plugins/tpm"
[ ! -d "$HOME/.tmux_stableSocket" ] && mkdir "$HOME/.tmux_stableSocket"

echo "--vim"
checkSimilaritiesAndLink vimrc "$HOME/.vimrc"
for fn in "$LocOfScript"/vim/*; do
	checkSimilaritiesAndLink vim/"$(basename "$fn")" "$HOME"/.vim/"$(basename "$fn")"
done
checkSimilaritiesAndLink "vim/autoload/vim-plug/plug.vim" vim/autoload/plug.vim

echo "--others"
checkSimilaritiesAndLink powerline_tmux_colorscheme.json "$HOME/.config/powerline/colorschemes/tmux/default.json"

checkSimilaritiesAndLink gitconfig "$HOME/.gitconfig"

checkSimilaritiesAndLink flake8 "$HOME/.config/flake8"

checkSimilaritiesAndLink ipython_config.py "$HOME/.ipython/profile_default/ipython_config.py"

checkSimilaritiesAndLink neovim_init.vim "$HOME/.config/nvim/init.vim"

checkSimilaritiesAndLink latexmkrc "$HOME/.latexmkrc"

checkSimilaritiesAndLink Xdefaults "$HOME/.Xdefaults"

checkSimilaritiesAndLink zathurarc "$HOME/.config/zathura/zathurarc"

if [[ "$(hostname)" == "T2" ]]; then
	echo "--T2 specifics"
	echo "--i3"
	checkSimilaritiesAndLink i3_config "$HOME/.config/i3/config"
	checkSimilaritiesAndLink i3status.sh "$HOME/.config/i3/i3status.sh"
	[ ! -d "$HOME/.config/i3/scripts" ] && mkdir "$HOME/.config/i3/scripts"
	for fn in "$LocOfScript"/i3scripts/*; do
		checkSimilaritiesAndLink i3scripts/"$(basename "$fn")" "$HOME"/.config/i3/scripts/"$(basename "$fn")"
	done

	echo "--others"

	checkSimilaritiesAndLink compton.conf "$HOME/.config/compton.conf"
	checkSimilaritiesAndLink dunstrc "$HOME/.config/dunst/dunstrc"
	checkSimilaritiesAndLink fusuma.config "$HOME/.config/fusuma/config.yml"
	checkSimilaritiesAndLink pscircle.service "$HOME/.config/systemd/user/pscircle.service"
	checkSimilaritiesAndLink tsocks.conf "$HOME/.config/tsocks.conf"
	checkSimilaritiesAndLink xinitrc "$HOME/.xinitrc"
	checkSimilaritiesAndLink zprofile "$HOME/.zprofile"

	echo "----sudos"

	echo "--acpi&pm"
	checkSimilaritiesAndLink sudos/lock /lib/systemd/system-sleep/10lock sudo nolink

	echo "--networkmanager"
	checkSimilaritiesAndLink sudos/networkmanager /etc/NetworkManager/conf.d/10randomisation sudo nolink

	echo "--changebrightness"
	checkSimilaritiesAndLink sudos/change_brightness.sh /usr/local/bin/change_brightness.sh sudo nolink
fi

if ! $allWentThrough; then
	echo "There were some errors. check."
	exit 1
fi
