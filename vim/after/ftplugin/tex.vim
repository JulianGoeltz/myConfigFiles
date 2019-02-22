"set background=dark
"colorscheme default
"set foldlevel=99
setlocal tabstop=4
setlocal shiftwidth=4
setlocal textwidth=0
setlocal colorcolumn=0

" do spell check
setlocal spelllang=en_gb spell

" set wrap, especcially in diffs
setlocal wrap
" intent is to in diff mode set wrap and unset spellcheck
autocmd FilterWritePre * if &diff | setlocal wrap | setlocal nospell | endif

" dont spellcheck comments
let g:tex_comment_nospell= 1 
