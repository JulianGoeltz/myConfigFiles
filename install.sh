#!/bin/bash

LocOfScript=$(dirname $(readlink -f $0))

echo "--ZSH"
ln -fsv $LocOfScript/zshrc $HOME/.zshrc
[ ! -d "$HOME/.zsh" ] && mkdir $HOME/.zsh
for fn in $(ls $LocOfScript/zsh/zshrc_host*); do
	ln -fsv $fn $HOME/.zsh/$(basename $fn)
done

echo "--GITCONFIG"
ln -fsv $LocOfScript/gitconfig $HOME/.gitconfig

echo "--FLAKE8"
ln -fsv $LocOfScript/flake8 $HOME/.config/flake8

echo "--ipython"
ln -fsv $LocOfScript/ipython_config.py $HOME/.ipython/profile_default/ipython_config.py

echo "--ssh"
if [[ "$(hostname)" == "T1" ]]; then
	#ln -fsv $LocOfScript/ssh_config $HOME/.ssh/config_prox
	[ -h $HOME/.ssh/config_prox ] && rm $HOME/.ssh/config_prox
	#[ -f $HOME/.ssh/config_prox ] && touch $HOME/.ssh/config_prox
	cat $HOME/.ssh/config > $HOME/.ssh/config_prox
       	cat $LocOfScript/ssh_config >> $HOME/.ssh/config_prox
	echo "Combined ~/.ssh/config with local config_prox"
elif [[ "$(hostname)" == "helvetica" ]]; then
	ln -fsv $LocOfScript/ssh_config $HOME/.ssh/config
	ln -fsv $LocOfScript/ssh_rc $HOME/.ssh/rc
fi

echo "--tmux"
ln -fsv $LocOfScript/tmux.conf $HOME/.tmux.conf
[ ! -d "$HOME/.tmux" ] && mkdir $HOME/.tmux
for fn in $(ls $LocOfScript/tmux/tmux.conf_*); do
	ln -fsv $fn $HOME/.tmux/$(basename $fn)
done

echo "--vim"
ln -fsv $LocOfScript/vimrc $HOME/.vimrc

echo "--i3"
ln -fsv $LocOfScript/i3_config $HOME/.config/i3/config
ln -fsv $LocOfScript/i3status.sh $HOME/.config/i3/i3status.sh
[ ! -d "$HOME/.config/i3/scripts" ] && mkdir $HOME/.config/i3/scripts
for fn in $(ls $LocOfScript/i3scripts/*); do
	ln -fsv $fn $HOME/.config/i3/scripts/$(basename $fn)
done
if [[ "$(hostname)" == "T1" ]]; then
	if [ -h "/etc/acpi/handler.sh" ] && [ "$(md5sum $LocOfScript/acpi_handler.sh | grep -o "[^ ]*" | head -n 1)" = "$(md5sum /etc/acpi/handler.sh | grep -o "[^ ]*" | head -n 1)" ]; then 
		echo "File /etc/acpi/handler.sh exists as link and is equal to local one"
	else
		echo "Trying to replace /etc/acpi/handler.sh with local one, if it doesn't work try with sudo"
		ln -fsv $LocOfScript/acpi_handler.sh /etc/acpi/handler.sh
	fi
fi

echo "--fusuma"
ln -fsv $LocOfScript/fusuma.config $HOME/.config/fusuma/config.yml
