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

function! MoveAfterSuccess(status)
	" status=1, and 1 is truthy in vim
	if a:status
		"silent execute '! ' . b:vimtex['root'] . '/afterCompletion.sh ' . b:vimtex['root']
		silent !/home/julgoe/Dropbox/uni/MasterThesis/thesis/thesis-skeleton/afterCompletion.sh 1
		redraw!
		call vimtex#log#warning("Compilation completed!")
	else
		silent !/home/julgoe/Dropbox/uni/MasterThesis/thesis/thesis-skeleton/afterCompletion.sh 0
		redraw!
		call vimtex#log#warning("Compilation failed!")
	endif
endfunction
call add(g:vimtex_compiler_callback_hooks, 'MoveAfterSuccess')
" to first do the moving, to not overdraw the output
call reverse(g:vimtex_compiler_callback_hooks)
