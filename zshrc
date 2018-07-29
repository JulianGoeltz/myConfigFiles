# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
if [[ "$(hostname)" == "T1" ]]; then
	zstyle :compinstall filename '/home/julgoe/.zshrc'
elif [[ "$(hostname)" == "helvetica" ]]; then
	zstyle :compinstall filename '/wang/users/jgoeltz/cluster_home/.zshrc'
else
	echo "no known host. what to do?"
	exit
fi

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


setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
REPORTTIME=10 # print elapsed time when more than 10 seconds
[ -f /etc/zsh_command_not_found ] && source /etc/zsh_command_not_found # to get info about similar commands
PATH=$PATH:~/myConfigFiles/toolbox

alias sshhel="ssh -A -X -o ConnectTimeout=60 -p 11022 jgoeltz@brainscales-r.kip.uni-heidelberg.de"
alias sshice="ssh -A -X -o ConnectTimeout=60 -p 7022 jgoeltz@brainscales-r.kip.uni-heidelberg.de"
# alias sshhel_fs="sudo sshfs jgoeltz@brainscales-r.kip.uni-heidelberg.de:MasterThesis /mnt/hel_fs -p 11022 -o allow_other,IdentityFile=/home/julgoe/.ssh/id_rsa"
alias sshhel_fs="sudo sshfs -p 11022 jgoeltz@brainscales-r.kip.uni-heidelberg.de:MasterThesis /mnt/hel_fs -o delay_connect,idmap=user,transform_symlinks,identityfile=~/.ssh/id_rsa,allow_other"
alias sshhel_fs_unmount="sudo fusermount -u -z /mnt/hel_fs"

# makes 10s wait period before executing rm -rf *
setopt rm_star_wait

alias ipy="ipython -ic 'import numpy as np; import matplotlib.pyplot as plt'"
alias ipy2="ipython2 -ic 'import numpy as np; import matplotlib.pyplot as plt'"

# aliases for files, see man zshbuiltins
alias -s pdf=zathura
alias -s wiki=vim
alias -s txt=vim
alias -s py=vim
alias -s svg=inkview
alias -s out=less

alias -g C=" | wc -l"
alias -g G=" | grep"
alias -g L=" | less" 


[ -e ~/.zsh/zshrc_host_$(hostname) ] && source ~/.zsh/zshrc_host_$(hostname)
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

# ######## PROMPT
# Old prompt
# RPROMPT='%{$fg[cyan]%}[%?]%{$reset_color%} | %{$fg[yellow]%}%*%{$reset_color%}'
# PROMPT='%B %{$fg[cyan]%}%c%b%{$reset_color%} $(git_prompt_info)'

# use variables to make designing prompt easier
show_prompt () {
	autoload colors zsh/terminfo
	if [[ "$terminfo[colors]" -ge 8 ]]; then
	    colors
	fi
	for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE ORANGE; do
	    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
	    (( count = $count + 1 ))
	done
	ZSH_THEME_GIT_PROMPT_PREFIX=", $PR_RED"
	ZSH_THEME_GIT_PROMPT_SUFFIX="$PR_NO_COLOR"
	ZSH_THEME_GIT_PROMPT_DIRTY="$PR_LIGHT_YELLOW ⚡"
	ZSH_THEME_GIT_PROMPT_CLEAN=""
	# we have to use double quotes for this one to evaluate the colors
	PR_NO_COLOR="%{$terminfo[sgr0]%}"
	PROMPT="\
┌─[$PR_CYAN%D{%m-%d/%H:%M:%S}$PR_NO_COLOR|$PR_LIGHT_GREEN%n$PR_NO_COLOR@$PR_LIGHT_YELLOW%m$PR_NO_COLOR"
	PROMPT=$PROMPT'$(git_prompt_info)'
	PROMPT=$PROMPT"$PR_NO_COLOR:$PR_BLUE%~$PR_NO_COLOR]
└─☉ "
	# └─⬧ "
	# └─⧫ "
	# ━
	# └─☉ "
	RPROMPT="$PR_MAGENTA\$VENV$PR_YELLOW(%?)${PR_GREEN}[%!]$PR_NO_COLOR "
}
show_prompt

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
