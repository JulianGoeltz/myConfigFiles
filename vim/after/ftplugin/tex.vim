"set background=dark
"colorscheme default
"set foldlevel=99
setlocal tabstop=4
setlocal shiftwidth=4
setlocal textwidth=0
setlocal colorcolumn=0

setlocal spelllang=en_gb spell

setlocal wrap

autocmd FilterWritePre * if &diff | setlocal wrap | endif
