#!/bin/bash

echo "This script will try to link the files, but not replace existing files (no -f force). If there are problems, remove the existing files by hand. This way it is safer."
LocOfScript=$(dirname $(readlink -f $0))

# define colours for better output
RED='\033[0;31m'
# existing and correct, yellow
ExCorr='\033[0;33m'
# action correct, green
ActCorr='\033[0;32m'
NC='\033[0m'

# if something goes wrong, change this variable
allWentThrough=true

checkSimilaritiesAndLink (){
	orig=$LocOfScript/$1
	dest=$2
	# check if given dest is a link
	if [ -L $dest ]; then
		if [[ "$(readlink -f $dest)" != "$orig" ]]; then
			echo -e "${RED}File $dest is a link to $(readlink -f $dest) and not $orig. Delete manually."
			allWentThrough=false
		else
			echo -e "${ExCorr}File $dest is already linked correctly to $orig."
		fi
	# check if given dest is a file
	elif [ -f $dest ]; then
		if [ "$4" = "nolink"  ]; then
			if diff $orig $dest >/dev/null; then
				echo -e "${ExCorr}File contents of $orig and $dest are the same."
			else
				tmpStr=$(cp $orig $dest 2>&1)
				if [ "$?" -ne "0" ]; then
					echo -e "${RED}$tmpStr"
					if [ "$3" = "sudo"  ]; then
						echo -e "${RED} Tried and failed to replace $dest with copy of $orig, try again with sudo BUT CHECK DIFFS BEFORE!!"
					fi
					allWentThrough=false
				else
					echo -e "${ActCorr} Replaced $dest with $orig."
				fi
			fi
		else
			echo -e "${RED}File $dest is a regular file, delete manually."
			allWentThrough=false
		fi
	# do the linking
	else
		if [ -e $dest ]; then
			echo -e "${RED}File $dest is niether link nor regular file, but still exists. Check manually."
			allWentThrough=false
		else
			if [ "$4" = "nolink"  ]; then
				tmpStr=$(cp $orig $dest 2>&1)
				if [ "$?" -ne "0" ]; then
					echo -e "${RED}$tmpStr"
					if [ "$3" = "sudo"  ]; then
						echo -e "${RED} Tried and failed to make a copy of $orig at $dest, try again with sudo."
					fi
					allWentThrough=false
				else
					echo -e "${ActCorr}Made a copy of $orig at $dest."
				fi
			else
				tmpStr=$(ln -sv $orig $dest 2>&1)
				if [ "$?" -ne "0" ]; then
					echo -e "${RED}$tmpStr"
					if [ "$3" = "sudo"  ]; then
						echo -e "${RED} Tried and failed to replace $dest with link to $orig, try again with sudo."
					fi
					allWentThrough=false
				else
					echo -e "${ActCorr}$tmpStr"
				fi
			fi
		fi
	fi
	echo -en $NC

}

echo "--ZSH"
checkSimilaritiesAndLink zshrc $HOME/.zshrc
[ ! -d "$HOME/.zsh" ] && mkdir $HOME/.zsh
# -d to not list contents of folders
for fn in $(ls -d $LocOfScript/zsh/*); do
	checkSimilaritiesAndLink zsh/$(basename $fn) $HOME/.zsh/$(basename $fn)
done

echo "--GITCONFIG"
checkSimilaritiesAndLink gitconfig $HOME/.gitconfig

echo "--FLAKE8"
checkSimilaritiesAndLink flake8 $HOME/.config/flake8

echo "--ipython"
checkSimilaritiesAndLink ipython_config.py $HOME/.ipython/profile_default/ipython_config.py

echo "--ssh"
if [[ "$(hostname)" == "T1" ]]; then
	# here we use the existing ssh config, which just says which identity files to use, and add a proxied version
	[ -h $HOME/.ssh/config_prox ] && rm $HOME/.ssh/config_prox
	cat $HOME/.ssh/config > $HOME/.ssh/config_prox
       	cat $LocOfScript/ssh_config_proxiedgithub >> $HOME/.ssh/config_prox
	echo -e "${ActCorr}Combined ~/.ssh/config with local config_prox${NC}"
elif [[ "$(hostname)" == "helvetica" ]]; then
	checkSimilaritiesAndLink ssh_config_proxiedgithub $HOME/.ssh/config
	checkSimilaritiesAndLink ssh_rc $HOME/.ssh/rc
fi

echo "--tmux"
checkSimilaritiesAndLink tmux.conf $HOME/.tmux.conf
[ ! -d "$HOME/.tmux" ] && mkdir $HOME/.tmux
for fn in $(ls $LocOfScript/tmux/tmux.conf_*); do
	checkSimilaritiesAndLink tmux/$(basename $fn) $HOME/.tmux/$(basename $fn)
done

echo "--vim"
checkSimilaritiesAndLink vimrc $HOME/.vimrc

if [[ "$(hostname)" == "T1" ]]; then
	echo "--this repo"
	checkSimilaritiesAndLink ensureUpdates_pre-commit $LocOfScript/.git/hooks/pre-commit

	echo "--i3"
	checkSimilaritiesAndLink i3_config $HOME/.config/i3/config
	checkSimilaritiesAndLink i3status.sh $HOME/.config/i3/i3status.sh
	[ ! -d "$HOME/.config/i3/scripts" ] && mkdir $HOME/.config/i3/scripts
	for fn in $(ls $LocOfScript/i3scripts/*); do
		checkSimilaritiesAndLink i3scripts/$(basename $fn) $HOME/.config/i3/scripts/$(basename $fn)
	done

	echo "--acpi&pm"
	checkSimilaritiesAndLink sudos/lock /lib/systemd/system-sleep/10lock sudo nolink

	echo "--new i3"
	checkSimilaritiesAndLink sudos/i3_new.desktop /usr/share/xsessions/i3_new.desktop sudo nolink

	echo "--fusuma"
	checkSimilaritiesAndLink fusuma.config $HOME/.config/fusuma/config.yml

	echo "--dunst"
	checkSimilaritiesAndLink dunstrc $HOME/.config/dunst/dunstrc
fi

if ! $allWentThrough; then
	echo "There were some errors. check."
	exit 1
fi
