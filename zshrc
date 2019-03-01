# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory
# End of lines configured by zsh-newuser-install
# add custom completion scripts
fpath=(~/.zsh/completion $fpath)
# define filename for compinstall based on host
if [[ "$(hostname)" == "T1" ]]; then
	zstyle :compinstall filename '/home/julgoe/.zshrc'
elif [[ "$(hostname)" == "helvetica" ]] || [[ "$(hostname)" == "hel" ]]; then
	zstyle :compinstall filename '/wang/users/jgoeltz/cluster_home/.zshrc'
elif echo $HOME | grep -q termux; then
	echo "Welcome to termux!"
	zstyle :compinstall filename '/data/data/com.termux/files/home/.zshrc'
else
	echo "no known host. what to do?"
	echo "Opening bash so you can adapt. Think about exiting"
	bash
fi

# The following lines were added by compinstall
autoload -Uz compinit
compinit
# End of lines added by compinstall


######## Own stuff
export LC_COLLATE=en_US.UTF-8
export EDITOR=vim
export VISUAL=vim
export LESS=-Ri  #r: display colours; i: smartcase search;
alias vi=vim


alias sourcezsh="source ~/.zshrc"
mkcd () { mkdir -p $1; cd $1}


setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
REPORTTIME=10 # print elapsed time when more than 10 seconds
[ -f /etc/zsh_command_not_found ] && source /etc/zsh_command_not_found # to get info about similar commands
[[ $PATH == *"myConfigFiles/toolbox"* ]] || PATH=$PATH:~/myConfigFiles/toolbox
# add user's bin directories to path
[[ $PATH == *".local/bin"* ]] || export PATH="$HOME/bin:$HOME/.local/bin:$PATH"


# To access port on hel locally, add to command (then go to localhost with that port):
# -L 5678:localhost:5678
# port forwarding to get notifs when slurm jobs are done
alias sshhel="ssh -A -X -o ConnectTimeout=60 -o ServerAliveInterval=60 -p 11022 jgoeltz@brainscales-r.kip.uni-heidelberg.de -R 1234:127.0.0.1:1234"
alias sshice="ssh -A -X -o ConnectTimeout=60 -p 7022 jgoeltz@brainscales-r.kip.uni-heidelberg.de"
# alias sshhel_fs="sudo sshfs jgoeltz@brainscales-r.kip.uni-heidelberg.de:MasterThesis /mnt/hel_fs -p 11022 -o allow_other,IdentityFile=/home/julgoe/.ssh/id_rsa"
sshhel_fs_helper(){
	sshfs -p 11022 jgoeltz@brainscales-r.kip.uni-heidelberg.de:$1 $2 -o delay_connect,idmap=user,transform_symlinks -o ConnectTimeout=60 -o ServerAliveInterval=60
}
alias sshhel_fs="sshhel_fs_helper MasterThesis ~/mntHel; sshhel_fs_helper /loh/users/jgoeltz ~/mntHel_loh"
alias sshhel_fs_unmount="fusermount -u -z ~/mntHel; fusermount -u -z ~/mntHel_loh"
alias sshhel_visu="sshhel -L 6931:localhost:6931"

alias vpn_connect="sudo openconnect vpn-ac.urz.uni-heidelberg.de"

# makes 10s wait period before executing rm -rf *
setopt rm_star_wait

# aliases for files, see man zshbuiltins
alias -s pdf=zathura
alias -s wiki=vim
alias -s txt=vim
# dont use this to be able to execute stuff; alias -s py=vim
alias -s svg=inkview
alias -s out=less
alias -s mp4=vlc

alias -g C=" | wc -l"
alias -g G=" | grep"
alias -g L=" | less" 
alias -g T=" | tail"
alias -g H=" | head"
alias -g S=" | sort"


ipy (){
	# determine if devmisc is loaded as a module on hel
	loadedDevmisc=$(module list 2>&1 | grep -o "developmisc.*")
	if [ $? -eq 0 -a -n "$loadedDevmisc" ]; then
		module unload $loadedDevmisc
	fi
	ipython2 -ic "import numpy as np, matplotlib.pyplot as plt, cPickle as pkl, h5py, os, os.path as osp; from pprint import pprint; $1"
	if [ -n "$loadedDevmisc" ] ; then module load $loadedDevmisc; fi
}
alias ipy2=ipy
# only set ipy3 alias if ipython3 exists
ipy3 () {
	if ! hash ipython3 2>/dev/null; then echo "No python3 install found."; return; fi
	ipython3 -ic "import numpy as np, matplotlib.pyplot as plt, pickle as pkl, h5py, os, os.path as osp; from pprint import pprint; $1"
}

# from oli and his .zshrc
export TMUX_TMPDIR="$HOME/.tmux_stableSocket"
alias tmux_reattach_running="/proc/\$(pgrep -u \$USER tmux | head -n 1)/exe detach; /proc/\$(pgrep -u \$USER tmux | head -n 1)/exe attach"
tmux_resetSocket () {
	processID=$(ps axo pid,user,comm,args G jgoeltz G -v grep G "tmux: server" G -o "^\s*\S*")
	if [ "$(echo $processID | wc -l)" -eq 1 ]; then
		kill -s USR1 $processID
	else
		echo "More than one server running, do it manually:"
		ps axo pid,user,comm,args G jgoeltz G -v grep G "tmux: server"
	fi
}

# from http://patorjk.com/software/taag/#p=display&f=Big&t=You%20should%20be%20writing!!!%20
cat ~/myConfigFiles/tmp_art
cat ~/myConfigFiles/tmp_art
cat ~/myConfigFiles/tmp_art
tm () {
	tmpTmuxServerPid=$(ps axo pid,user,comm,args | grep $USER | grep -v grep | grep -P "(tmux: server|tmux -f /home/julgoe)")
	if [ -z "$tmpTmuxServerPid" ]; then
		echo "no tmux server running, start it"
		return
	elif [ "$(echo $tmpTmuxServerPid | wc -l)" -ne 1 ]; then
		echo "More than one server running, handle manually:"
		echo $tmpTmuxServerPid
		return
	fi
	tmpTmuxServerPid=$(echo $tmpTmuxServerPid | grep -o "^\s*[0-9]*" | grep -o "[0-9]*")
	[ -z "$TMUX" ] && /proc/$tmpTmuxServerPid/exe attach
	if [ -n "$TMUX" -o "$?" -ne "0" ]; then
		echo "tmux server might have lost socket connection, or similar. Socket is reset, try connection again."
		kill -s USR1 $tmpTmuxServerPid
	fi
}
tmux_tree () {
	for s in `tmux list-sessions -F '#{session_name}'` ; do
	  echo -e "\ntmux session name: $s\n--------------------"
	  for w in `tmux list-windows -F '#I' -t "$s"`; do
	    echo -e "\ntmux window index: $w\n-----"
	    for p in `tmux list-panes -F '#{pane_pid}' -t "$s:$w"` ; do
	      pstree -p -a -A $p
	    done
	  done
	done
}

# in order to see filenames before looking at files
iv () { ls -lAh $@; inkview $(ls $@)}
fe () { ls -lAh $@; feh $(ls $@)}

# easy diff of hdf5 datasets,from zsh/..hel
function diffHdf5 () {
	tmp_prefix=""
	tmp_suffix=""
	if [ ! -f $1 ]; then
		dataGroup=$1
		if [[ "$1" == "input/yaml_evaluated" ]]; then
			tmp_prefix='echo ${$('
			tmp_suffix=')//,/\\n}'
		fi
		shift
	else
		dataGroup='input/yaml_pure'
	fi
	diffCommand="vimdiff "
	for file in $@; do
		[ ! -f $file ] && continue
		if [[ "$file[-5,-1]" == ".hdf5" ]]; then
			diffCommand=$diffCommand" <($tmp_prefix h5dump -d $dataGroup $file$tmp_suffix) "
		elif [[ "$file[-5,-1]" == ".yaml" ]]; then
			diffCommand=$diffCommand" <(echo 'file $file'; cat $file | sed 's/^/           /' ) "
		fi
	done
	eval $diffCommand
}

# after lost ssh session, often on focus of zsh/terminal, prompt is redrawn
# with redraw there's a loss of lines, for this disable this feature:
printf "\e[?1004l"

# to copy to system clipboard with vi keybinds in zsh
# check that ZSH_SYSTEM_CLIPBOARD is not empty, the file exist and we are not in a singularity shell
[ -z "$ZSH_SYSTEM_CLIPBOARD" ] && \
	[ -e "$HOME/.zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh" ] && \
	[ -z $SINGULARITY_APPNAME ] && \
	[ -n "$DISPLAY" ] && \
	source "$HOME/.zsh/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"

# last thing before end, source the host specific files if existent
[ -e ~/.zsh/zshrc_host_$(hostname | head -c 3) ] && source ~/.zsh/zshrc_host_$(hostname | head -c 3)

######## end


# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git tmux # thefuck
)

source $ZSH/oh-my-zsh.sh
# vim keybindings
bindkey -v
alias la="ls -lAh --color=always"

# ######## PROMPT
# Old prompt
# RPROMPT='%{$fg[cyan]%}[%?]%{$reset_color%} | %{$fg[yellow]%}%*%{$reset_color%}'
# PROMPT='%B %{$fg[cyan]%}%c%b%{$reset_color%} $(git_prompt_info)'

# use variables to make designing prompt easier
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE ORANGE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done
define_prompt () {
	ZSH_THEME_GIT_PROMPT_PREFIX="|$PR_RED"
	ZSH_THEME_GIT_PROMPT_SUFFIX="$PR_NO_COLOR"
	ZSH_THEME_GIT_PROMPT_DIRTY="$PR_LIGHT_YELLOW ⚡"

	ZSH_THEME_GIT_PROMPT_CLEAN=""
	# we have to use double quotes for this one to evaluate the colors
	PR_NO_COLOR="%{$terminfo[sgr0]%}"
	PROMPT="\
"
	PROMPT=$PROMPT'$([ "$KEYMAP" = "vicmd" ] && echo "${PR_RED}┌─[")'
	PROMPT=$PROMPT'$([ "$KEYMAP" = "vicmd" ] || echo "┌─[")'
	PROMPT=$PROMPT"${PR_CYAN}%D{%m-%d/%H:%M:%S}$PR_NO_COLOR|$PR_LIGHT_GREEN%n$PR_NO_COLOR@$PR_LIGHT_YELLOW%m$PR_NO_COLOR"
	PROMPT=$PROMPT'$([ -n "$VIRTUAL_ENV" ] && echo -n "$PR_NO_COLOR|$PR_MAGENTA" && echo -n $(basename $VIRTUAL_ENV))'$PR_NO_COLOR
	PROMPT=$PROMPT'$([ -n "$SINGULARITY_APPNAME" ] && echo "$PR_NO_COLOR|${PR_MAGENTA}container")'$PR_NO_COLOR
	PROMPT=$PROMPT'$([ -z "$ZSH_THEME_GIT_DONTDOIT" ] && echo "$(git_prompt_info)")'$PR_NO_COLOR
	PROMPT=$PROMPT"|%(1j.$PR_YELLOW%j$PR_NO_COLOR|.)$PR_BLUE%~$PR_NO_COLOR"
	# for vi normal mode, make first bit red
	PROMPT=$PROMPT'$([ "$KEYMAP" = "vicmd" ] && echo "${PR_RED}]\n└─⧫${PR_NO_COLOR} ")'
	PROMPT=$PROMPT'$([ "$KEYMAP" = "vicmd" ] || echo "]\n└─☉ ")'
	# └─⬧ "
	# └─⧫ "
	# ━
	# └─☉ "
}
define_rprompt () {
	#RPROMPT="$PR_MAGENTA\$VENV$PR_YELLOW(%?)${PR_GREEN}[%!]$PR_NO_COLOR "
	#RPROMPT="$PR_YELLOW($(printf '%3u' $?))$PR_NO_COLOR "
	RPROMPT="$PR_YELLOW(%?)$PR_NO_COLOR "
	RPROMPT='$([ "$KEYMAP" = "vicmd" ] && echo "${PR_RED}[NORMAL MODE]")'$PR_NO_COLOR$RPROMPT
}
define_prompt
define_rprompt
# make sure it is redrawn correctly if we change from insert to normal mode
function zle-line-init zle-keymap-select {
	#define_rprompt
	#define_prompt
	zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1  #this is for faster mode switching
# to only show the venv once
VIRTUAL_ENV_DISABLE_PROMPT="true"
# set this to nozero length if git is very slow for some reason
ZSH_THEME_GIT_DONTDOIT=""

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
