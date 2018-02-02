if [ "$PWD" = "/home/julgoe/myConfigFiles" ]
then
	HOST=T1
elif [ "$PWD" = "/wang/users/jgoeltz/cluster_home/myConfigFiles" ]
then
	HOST=hel
else
	echo neither T1 nor wang system
fi




if [ "$1" = "get" ]
then
	echo _GETTING_ .zshrc, .vimrc, .gitconfig, .tmux and the folder .vim/after from home directory
	cp ../.zshrc ./_zshrc_$HOST
	cp ../.vimrc ./_vimrc_$HOST
	cp ../.tmux.conf ./_tmux.conf_$HOST
	cp ../.gitconfig ./_gitconfig
	mkdir -p ./_vim/after
	cp -r ../.vim/after/ ./_vim/
elif [ "$1" = "set" ]
then
	CONTINUELOOP=true
	while $CONTINUELOOP; do
		read -p "##### Are you sure you want to set the config files? (y/Y sets config, d/D diffs the files, all else stops): " choice
		case "$choice" in 
		  y|Y ) 
			  echo "   Continuing..."
			  CONTINUELOOP=false
			  ;;
		  d|D ) 
			echo diff ./_zshrc_$HOST ../.zshrc
			diff ./_zshrc_$HOST ../.zshrc
			echo diff ./_vimrc_$HOST ../.vimrc
			diff ./_vimrc_$HOST ../.vimrc
			echo diff ./_tmux.conf_$HOST ../.tmux.conf
			diff ./_tmux.conf_$HOST ../.tmux.conf
			echo diff ./_gitconfig ../.gitconfig
			diff ./_gitconfig ../.gitconfig
			echo diff -r ./_vim/after ../.vim/after
			diff -r ./_vim/after ../.vim/after
			;;
		  * ) exit;;
		esac
	done
	echo _SETTING_ .zshrc, .vimrc, .gitconfig, .tmux and the folder .vim/after from home directory
	cp ./_zshrc_$HOST ../.zshrc
	cp ./_vimrc_$HOST ../.vimrc
	cp ./_tmux.conf_$HOST ../.tmux.conf
	cp ./_gitconfig ../.gitconfig
	mkdir -p ../.vim/after
	cp -r ./_vim/after ../.vim/
else
	echo pass set or get to set or get
fi
