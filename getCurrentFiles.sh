if [ "$PWD" = "/home/julgoe/myConfigFiles" ]
then
	if [ "$1" = "get" ]
	then
		echo _GETTING_ .zshrc, .vimrc, .gitconfig, .tmux and the folder .vim/after from home directory
		cp ../.zshrc ./_zshrc_T1
		cp ../.vimrc ./_vimrc_T1
		cp -r ../.tmux.conf ./_tmux.conf_T1
		cp ../.gitconfig ./_gitconfig
		mkdir -p ./_vim/after
		cp -r ../.vim/after/ ./_vim/
	elif [ "$1" = "set" ]
	then
		echo _SETTING_ .zshrc, .vimrc, .gitconfig, .tmux and the folder .vim/after from home directory
		cp ./_zshrc_T1 ../.zshrc
		cp ./_vimrc_T1 ../.vimrc
		cp -r ./_tmux.conf_T1 ../.tmux.conf
		cp ./_gitconfig ../.gitconfig
		mkdir -p ../.vim/after
		cp -r ./_vim/after ../.vim/
	else
		echo pass set or get to set or get
	fi
elif [ "$PWD" = "/wang/users/jgoeltz/cluster_home/myConfigFiles" ]
then
	if [ "$1" = "get" ]
	then
		echo _GETTING_ .zshrc, .vimrc, .gitconfig, .tmux and the folder .vim/after from home directory
		cp ../.zshrc ./_zshrc_hel
		cp ../.vimrc ./_vimrc_hel
		cp -r ../.tmux.conf ./_tmux.conf_hel
		cp ../.gitconfig ./_gitconfig
		mkdir -p ./_vim/after
		cp -r ../.vim/after/ ./_vim/
	elif [ "$1" = "set" ]
	then
		echo _SETTING_ .zshrc, .vimrc, .gitconfig, .tmux and the folder .vim/after from home directory
		cp ./_zshrc_hel ../.zshrc
		cp ./_vimrc_hel ../.vimrc
		cp -r ./_tmux.conf_hel ../.tmux.conf
		cp ./_gitconfig ../.gitconfig
		mkdir -p ../.vim/after
		cp -r ./_vim/after ../.vim/
	else
		echo pass set or get to set or get
	fi
else
	echo neither T1 nor wang system
fi
