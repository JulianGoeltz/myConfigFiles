if [ "$PWD" = "/home/julgoe/myConfigFiles" ]
then
	HOST=T1
elif [ "$PWD" = "/wang/users/jgoeltz/cluster_home/myConfigFiles" ]
then
	HOST=hel
else
	echo neither T1 nor wang system
	exit
fi




if [ "$1" = "get" ]
then
	echo git diff ./_zshrc_$HOST ../.zshrc
	git diff ./_zshrc_$HOST ../.zshrc
	echo git diff ./_vimrc_$HOST ../.vimrc
	git diff ./_vimrc_$HOST ../.vimrc
	echo git diff ./_tmux.conf_$HOST ../.tmux.conf
	git diff ./_tmux.conf_$HOST ../.tmux.conf
	echo git diff ./_ssh_config_$HOST ../.ssh/config
	git diff ./_ssh_config_$HOST ../.ssh/config
	echo git diff ./ipython_config_$HOST.py ../.ipython/profile_default/ipython_config.py
	git diff ./ipython_config_$HOST.py ../.ipython/profile_default/ipython_config.py
	echo git diff ./_gitconfig ../.gitconfig
	git diff ./_gitconfig ../.gitconfig
	echo git diff ./flake8 ../.config/flake8
	git diff ./flake8 ../.config/flake8
	echo diff -r ./_vim/after ../.vim/after
	diff -r ./_vim/after ../.vim/after
	read -p "##### Are you sure you want to get the config files? (y/Y sets config, all else stops): " choice
	case "$choice" in 
	  y|Y ) 
		  echo "   Continuing..."
		  ;;
	  * ) exit;;
	esac
	echo _GETTING_ .zshrc, .vimrc, .gitconfig, config/flake8, .tmux, .ipython config and the folder .vim/after from home directory
	cp ../.zshrc ./_zshrc_$HOST
	cp ../.vimrc ./_vimrc_$HOST
	cp ../.tmux.conf ./_tmux.conf_$HOST
	cp ../.ssh/config ./_ssh_config_$HOST
	cp ../.ipython/profile_default/ipython_config.py ./ipython_config_$HOST.py
	cp ../.gitconfig ./_gitconfig
	cp ../.config/flake8 ./flake8
	mkdir -p ./_vim/after
	cp -r ../.vim/after/ ./_vim/
elif [ "$1" = "set" ]
then
	echo git diff ../.zshrc ./_zshrc_$HOST 
	git diff ../.zshrc ./_zshrc_$HOST 
	echo git diff ../.vimrc ./_vimrc_$HOST
	git diff ../.vimrc ./_vimrc_$HOST
	echo git diff ../.tmux.conf ./_tmux.conf_$HOST
	git diff ../.tmux.conf ./_tmux.conf_$HOST
	echo git diff ../.ssh/config ./_ssh_config_$HOST
	git diff ../.ssh/config ./_ssh_config_$HOST
	echo git diff ../.ipython/profile_default/ipython_config.py ./ipython_config_$HOST.py
	git diff ../.ipython/profile_default/ipython_config.py ./ipython_config_$HOST.py
	echo git diff ../.gitconfig ./_gitconfig
	git diff ../.gitconfig ./_gitconfig
	echo git diff ../.config/flake8 ./flake8
	git diff ../.config/flake8 ./flake8
	echo diff -r ../.vim/after ./_vim/after
	diff -r ../.vim/after ./_vim/after
	read -p "##### Are you sure you want to set the config files? (y/Y sets config, all else stops): " choice
	case "$choice" in 
	  y|Y ) 
		  echo "   Continuing..."
		  ;;
	  * ) exit;;
	esac
	echo _SETTING_ .zshrc, .vimrc, .gitconfig, .config/flake8, .tmux, ipython config and the folder .vim/after from home directory
	cp ./_zshrc_$HOST ../.zshrc
	cp ./_vimrc_$HOST ../.vimrc
	cp ./_tmux.conf_$HOST ../.tmux.conf
	cp ./_ssh_config_$HOST ../.ssh/config
	cp ./ipython_config_$HOST.py ../.ipython/profile_default/ipython_config.py
	cp ./_gitconfig ../.gitconfig
	cp ./flake8 ../.config/flake8
	mkdir -p ../.vim/after
	cp -r ./_vim/after ../.vim/
elif [ "$1" = "comp" ]
then
	echo git diff --no-index ./_zshrc_T1 ./_zshrc_hel
	git diff --no-index ./_zshrc_T1 ./_zshrc_hel
	echo git diff --no-index ./_vimrc_T1 ./_vimrc_hel
	git diff --no-index ./_vimrc_T1 ./_vimrc_hel
	echo git diff --no-index ./_tmux.conf_T1 ./_tmux.conf_hel
	git diff --no-index ./_tmux.conf_T1 ./_tmux.conf_hel
	echo git diff --no-index ./_ssh_config_T1 ./_ssh_config_hel
	git diff --no-index ./_ssh_config_T1 ./_ssh_config_hel
	echo git diff --no-index ./ipython_config_T1.py ./ipython_config_hel.py
	git diff --no-index ./ipython_config_T1.py ./ipython_config_hel.py
	read -p "##### type z, v, t, s or i to vimdiff respective, or else to quit: " choice
	case "$choice" in 
	  z|Z ) 
		  file=_zshrc ;;
	  v|V ) 
		  file=_vimrc ;;
	  t|T ) 
		  file=_tmux.conf ;;
 	  s|S )
		  file=_ssh_config ;;
	  i|I ) 
		  file=ipython_config ;;
	  * ) exit;;
	esac
	vimdiff "$file"_T1 "$file"_hel
else
	echo pass set or get to set or get - or comp
fi
