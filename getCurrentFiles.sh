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
	echo _GETTING_ .zshrc, .vimrc, .gitconfig, .tmux, .ipython config and the folder .vim/after from home directory
	cp ../.zshrc ./_zshrc_$HOST
	cp ../.vimrc ./_vimrc_$HOST
	cp ../.tmux.conf ./_tmux.conf_$HOST
	cp ../.ipython/profile_default/ipython_config.py ./ipython_config_$HOST.py
	cp ../.gitconfig ./_gitconfig
	mkdir -p ./_vim/after
	cp -r ../.vim/after/ ./_vim/
elif [ "$1" = "set" ]
then
	echo git diff ./_zshrc_$HOST ../.zshrc
	git diff ./_zshrc_$HOST ../.zshrc
	echo git diff ./_vimrc_$HOST ../.vimrc
	git diff ./_vimrc_$HOST ../.vimrc
	echo git diff ./_tmux.conf_$HOST ../.tmux.conf
	git diff ./_tmux.conf_$HOST ../.tmux.conf
	echo git diff ./ipython_config_$HOST.py ../.ipython/profile_default/ipython_config.py
	git diff ./ipython_config_$HOST.py ../.ipython/profile_default/ipython_config.py
	echo git diff ./_gitconfig ../.gitconfig
	git diff ./_gitconfig ../.gitconfig
	echo diff -r ./_vim/after ../.vim/after
	diff -r ./_vim/after ../.vim/after
	read -p "##### Are you sure you want to set the config files? (y/Y sets config, all else stops): " choice
	case "$choice" in 
	  y|Y ) 
		  echo "   Continuing..."
		  ;;
	  * ) exit;;
	esac
	echo _SETTING_ .zshrc, .vimrc, .gitconfig, .tmux, ipython config and the folder .vim/after from home directory
	cp ./_zshrc_$HOST ../.zshrc
	cp ./_vimrc_$HOST ../.vimrc
	cp ./_tmux.conf_$HOST ../.tmux.conf
	cp ./ipython_config_$HOST.py ../.ipython/profile_default/ipython_config.py
	cp ./_gitconfig ../.gitconfig
	mkdir -p ../.vim/after
	cp -r ./_vim/after ../.vim/
else
	echo pass set or get to set or get
fi
