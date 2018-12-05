#!/bin/zsh

# function for more easy debugging and creating of completion functions:
r() {
	local f
	f=(~/.zsh/completion/*(.))
	unfunction $f:t 2> /dev/null
	autoload -U $f:t
}
