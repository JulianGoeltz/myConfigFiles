#to profile this, afterwards do 'zprof'
# zmodload zsh/zprof

# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt INC_APPEND_HISTORY
# End of lines configured by zsh-newuser-install
# define filename for compinstall based on host
if [[ "$(hostname)" == "T2" ]]; then
	zstyle :compinstall filename '/home/julgoe/.zshrc'
elif [[ "$(hostname)" == "helvetica" ]] || [[ "$(hostname)" == "hel" ]] || [[ "$(hostname)" == "helvetica.kip.uni-heidelberg.de" ]]; then
	zstyle :compinstall filename '/wang/users/jgoeltz/cluster_home/.zshrc'
elif [[ "$(hostname)" == "login1.nemo.privat" ]] then
	zstyle :compinstall filename '/home/hd/hd_hd/hd_ta400/.zshrc'
elif echo $HOME | grep -q termux; then
	echo "Welcome to termux!"
	zstyle :compinstall filename '/data/data/com.termux/files/home/.zshrc'
else
	echo "no known host. what to do?"
	echo "Opening bash so you can adapt. Think about exiting"
	bash
fi

# add custom completion scripts
fpath=(~/.zsh/completion/ $fpath)

# setting the locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

######## Own stuff
export EDITOR=vim
export VISUAL=vim
export LESS=-Ri  #r: display colours; i: smartcase search;
alias vi=vim


alias sourcezsh="source ~/.zshrc"
mkcd () { mkdir -p $1 && cd $1}


setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
REPORTTIME=10 # print elapsed time when more than 10 seconds
[ -f /etc/zsh_command_not_found ] && source /etc/zsh_command_not_found # to get info about similar commands
[[ $PATH == *"myConfigFiles/toolbox"* ]] || PATH=$PATH:~/myConfigFiles/toolbox
# add user's bin directories to path


# To access port on hel locally, add to command (then go to localhost with that port):
# -L 5678:localhost:5678
# port forwarding to get notifs when slurm jobs are done
alias sshhel="ssh -A -X -o ConnectTimeout=60 -o ForwardX11Timeout=1000000s -o ServerAliveInterval=60 -p 11022 jgoeltz@brainscales-r.kip.uni-heidelberg.de -R localhost:1234:localhost:1234"
alias sshice="ssh -A -X -o ConnectTimeout=60 -p 7022 jgoeltz@brainscales-r.kip.uni-heidelberg.de"
alias sshnemo="ssh -A -X hd_ta400@login1.nemo.uni-freiburg.de"
# alias sshhel_fs="sudo sshfs jgoeltz@brainscales-r.kip.uni-heidelberg.de:MasterThesis /mnt/hel_fs -p 11022 -o allow_other,IdentityFile=/home/julgoe/.ssh/id_rsa"
sshhel_fs_helper(){
	sshfs -p 11022 jgoeltz@brainscales-r.kip.uni-heidelberg.de:$1 $2 -o delay_connect,idmap=user,transform_symlinks -o ConnectTimeout=60 -o ServerAliveInterval=60
}
alias sshhel_fs="sshhel_fs_helper MasterThesis ~/mnt/mntHel; sshhel_fs_helper /loh/users/jgoeltz ~/mnt/mntHel_loh"
alias sshhel_fs_unmount="fusermount -u -z ~/mnt/mntHel; fusermount -u -z ~/mnt/mntHel_loh"
alias sshnemo_fs="sshfs hd_ta400@login1.nemo.uni-freiburg.de:/work/ws/nemo/hd_ta400-TtFS-0 ~/mnt/mntNemo -o delay_connect,idmap=user,transform_symlinks -o ConnectTimeout=60 -o ServerAliveInterval=60"
alias sshhel_visu="sshhel -L 6931:localhost:6931"
alias sshnemo_fs_unmount="fusermount -u -z ~/mnt/mntNemo"

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

alias -g B=" | bat"
alias -g C=" | wc -l"
alias -g G=" | grep"
alias -g L=" | less" 
alias -g T=" | tail"
alias -g H=" | head"
alias -g S=" | sort"
alias -g N=" && notify-send 'Command succeeded' || notify-send 'Command failed'"


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
# cat ~/myConfigFiles/tmp_art
# cat ~/myConfigFiles/tmp_art
# cat ~/myConfigFiles/tmp_art
tm () {
	tmpTmuxServerPid=$(ps axo pid,user,comm,args | grep $USER | grep -v grep | grep -P "(tmux: server|tmux)")

	if [ -z "$tmpTmuxServerPid" ]; then
		echo "no tmux server running, start it"
		return
	elif [ "$(echo "$tmpTmuxServerPid" | wc -l)" -ne 1 ]; then
		echo "More than one server running, handle manually:"
		echo "$tmpTmuxServerPid"
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
eo () { ls -lAh $@; eog $(ls $@)}

# after lost ssh session, often on focus of zsh/terminal, prompt is redrawn
# with redraw there's a loss of lines, for this disable this feature:
alias stoplinesdisappearing='printf "\e[?1004l"'

function replaceGerrit() {
	read "foobar?enter>" ;
	echo ${foobar//gerrit.bioai.eu/brainscales-r.kip.uni-heidelberg.de}
}

# shift tab working as expected
zmodload zsh/complist
bindkey "$terminfo[kcbt]" reverse-menu-complete
bindkey -M menuselect '^[[Z' reverse-menu-complete

# display ^C when CtrlC is pressed, eases reading of lines; maybe causes problems
TRAPINT() {
  print -n "^C"
  return $(( 128 + $1 ))
}

# change default theme of bat in case bright solarized is used
# export BAT_THEME=GitHub

# allows custom completion function ls'ing ~/venvs folder
venvsource() {source $1}

# last thing before end, source the host specific files if existent
[ -e ~/.zsh/zshrc_host_$(hostname | head -c 3) ] && source ~/.zsh/zshrc_host_$(hostname | head -c 3)

# register all completion functions in fpath (from above and the host specific scripts)
autoload -Uz compinit
compinit

# if nvim is available use it instead
if type nvim 2>&1 >/dev/null ; then
	alias vim=nvim
	alias vimdiff="nvim -d "
fi

# to have more vim not vi like bindings:
#bindkey  '^H' backward-delete-char
#bindkey  '^?' delete-char

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
# plugins=(
#   git tmux # thefuck
# )

# source $ZSH/oh-my-zsh.sh
# vim keybindings
bindkey -v
alias la="ls -lAh --color=always"
alias ls="ls --color=auto"
alias grep="grep --color=auto"

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
┌─["
	PROMPT=$PROMPT"${PR_CYAN}%D{%m-%d/%H:%M:%S}$PR_NO_COLOR|$PR_LIGHT_GREEN%n$PR_NO_COLOR@$PR_LIGHT_YELLOW%m$PR_NO_COLOR"
	PROMPT=$PROMPT'`[ -n "$VIRTUAL_ENV" ] && echo -n "$PR_NO_COLOR|$PR_MAGENTA" && echo -n $(basename $VIRTUAL_ENV)`'$PR_NO_COLOR
	PROMPT=$PROMPT'$([ -n "$SINGULARITY_APPNAME" ] && echo "$PR_NO_COLOR|${PR_MAGENTA}$SINGULARITY_APPNAME")'$PR_NO_COLOR
	PROMPT=$PROMPT'$(git_prompt_info)'$PR_NO_COLOR
	PROMPT=$PROMPT"|%(1j.$PR_YELLOW%j$PR_NO_COLOR|.)$PR_BLUE%~$PR_NO_COLOR"
	# for vi normal mode, make first bit red
	PROMPT=$PROMPT"]
└─☉ "
	# └─⬧ "
	# └─⧫ "
	# ━
	# └─☉ "
}
define_rprompt () {
	RPROMPT="$PR_YELLOW(%?)$PR_NO_COLOR "
}
define_prompt
define_rprompt
setopt promptsubst

function zle-line-init zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    # in tty otherwise q is left  in prompt
    [ "$TERM" = "linux" ] || echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    [ "$TERM" = "linux" ] || echo -ne '\e[5 q'
  fi
}

# Use beam shape cursor on startup.
echo -ne '\e[5 q'

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1  #this is for faster mode switching
# to only show the venv once
VIRTUAL_ENV_DISABLE_PROMPT="true"
# set this to nozero length if git is very slow for some reason
ZSH_PROMPT_GIT_DONTDOIT=""

git_prompt_info() {
	# in sshfs'd folders dont query git
	[ -n "$ZSH_PROMPT_GIT_DONTDOIT" ] && return 0

	# in git folder?
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		return 0
	fi

	local git_status_dirty git_branch
	# dirty status
	if [ -z "$(git status --porcelain)" ] ; then
		git_status_dirty=''
	else
		git_status_dirty='*'
	fi

	# branch name
	git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
	if [ "${#git_branch}" -ge 24 ]; then
		git_branch="${git_branch:0:21}..."
	fi
	if [ "${git_branch}" = "HEAD" ]; then
		git_branch="$(git rev-parse --short HEAD 2>/dev/null || echo "NoBranchYet")"
	fi

	# output
	echo "|$PR_RED${git_branch}$PR_LIGHT_GREEN${git_status_dirty}"
}

# highlight items in completion
zstyle ':completion:*' menu select
# cd without 'cd'
setopt  autocd autopushd

# fuzzy completion
# from https://unix.stackexchange.com/questions/330481/zsh-tab-completions-not-working-as-desired-for-partial-paths
#zstyle ':completion:*:*:*:*:globbed-files' matcher 'r:|?=** m:{a-z\-}={A-Z\_}'
#zstyle ':completion:*:*:*:*:local-directories' matcher 'r:|?=** m:{a-z\-}={A-Z\_}'
#zstyle ':completion:*:*:*:*:directories' matcher 'r:|?=** m:{a-z\-}={A-Z\_}'
#zstyle ':completion:*:*:*:*:commands' matcher 'r:|?=** m:{a-z\-}={A-Z\_}'
#explanation https://superuser.com/questions/1092033/how-can-i-make-zsh-tab-completion-fix-capitalization-errors-for-directorys-and
# the patterns are handeled after each other until one finds matches
# first pattern allows lowercase to be match uppercase as well
# second ADDS (due to +) uppercase matching lowercase
# last one matches if given string appears somewhere in the matches, not only at beginning
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' '+m:{A-Z}={a-z}' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'


# coloured completion
eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# complete all own processes
zstyle ':completion:*:processes' command 'ps -u $USER -o pid,user,comm'


# ### Plugins
pluginDir="$HOME/.zsh/plugins/"
# to copy to system clipboard with vi keybinds in zsh
# check that ZSH_SYSTEM_CLIPBOARD is not empty, the file exist and we are not in a singularity shell
[ -z "$ZSH_SYSTEM_CLIPBOARD" ] && \
	[ -e "$pluginDir/zsh-system-clipboard/zsh-system-clipboard.zsh" ] && \
	[ -z $SINGULARITY_APPNAME ] && \
	[ -n "$DISPLAY" ] && \
	( which xclip >/dev/null 2>&1 || which xsel >/dev/null 2>&1) && \
	source "$pluginDir/zsh-system-clipboard/zsh-system-clipboard.zsh"

# load autosuggestions
[ -d "$pluginDir/zsh-autosuggestions" ] && source $pluginDir/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_USE_ASYNC=""
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="underline"
bindkey '^N' autosuggest-execute

[ -d "$pluginDir/zsh-syntax-highlighting" ] && source $pluginDir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -d "$pluginDir/zsh-history-substring-search" ] && source $pluginDir/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
