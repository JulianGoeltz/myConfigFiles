" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
"   this is using vim-plug https://github.com/junegunn/vim-plug
"   download vim-plug in .vim folder
"   plugins installed by :PlugInstall
set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=indent,eol,start	" more powerful backspacing
call plug#begin('~/.vim/plugged')

" for xterm. do later
set t_Co=8
"set termguicolors
colorscheme desert

" Make sure you use single quotes
" python folding
Plug 'tmhedberg/SimpylFold'
" fast folding, also only on demand calculation
Plug 'Konfekt/FastFold'
Plug 'vim-scripts/indentpython.vim'
"Autocomplete
" feature of vim-plug: compile automatically
function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py
  endif
endfunction

let g:ycm_requirements_met = v:version >= 704 || (v:version == 703 && has('patch584'))
if g:ycm_requirements_met " && index(g:hosts_ycm, hostname()) >= 0
	Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
	Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'} " generating ycm_extra_conf.py for YCM
endif
" not working. Plug 'jeaye/color_coded' " c colour coding
"Syntax check
Plug 'vim-syntastic/syntastic'
let g:syntastic_python_checkers = ['flake8']
"Check PEP8
Plug 'nvie/vim-flake8'
"Color Schemes
"Plug 'jnurmine/Zenburn'
Plug 'altercation/vim-colors-solarized'
"File Browsing
"Plug 'scrooloose/nerdtree'
"Searching
Plug 'kien/ctrlp.vim'
"Git
Plug 'tpope/vim-fugitive'

" in container on hel, zsh doesnt work
set shell=/bin/sh
if system('hostname') =~ "T1"
	"sign column indication of git changes (THIS BREAKS THE C-xC-o omnicomplete
	"FUNCTIONALITY, THUS DISABLED)
	"Plug 'airblade/vim-gitgutter'
	"omnicomplete
	"set omnifunc=syntaxcomplete#Complete
	
	"for forward search in latex with zathura
	let g:vimtex_view_general_viewer='zathura'
	let g:vimtex_view_method = 'zathura'

	let g:vimwiki_list = [{'path':'~/Dropbox/uni/MasterThesis/vimwiki/text/',
		\ 'path_html':'~/Dropbox/uni/MasterThesis/vimwiki/html/',
		\ 'template_path': '~/Dropbox/uni/MasterThesis/vimwiki/templates'}]
	"set shell=/bin/zsh
elseif system('hostname') =~ "helvetica"
	"sign column indication of git changes
	Plug 'airblade/vim-gitgutter'

	let g:ycm_extra_conf_vim_data = ['&filetype']
	"let g:ycm_extra_conf_globlist = ['~/MasterThesis/utils/adc_error/*']

	"for forward search in latex with zathura
	let g:vimtex_view_method = 'mupdf' "zathura'
endif

Plug 'vim-airline/vim-airline'
""Powerline-status installed via pip (on hel with pip install -b ~/tmpbuild -t ~/pip_files powerline-status
"if system('hostname') =~ "T1" || system('hostname') =~ "helvetica"
"	python3 from powerline.vim import setup as powerline_setup
"	python3 powerline_setup()
"	python3 del powerline_setup
"elseif system('hostname') =~ "localhost"
"	python3 from powerline.vim import setup as powerline_setup
"	python3 powerline_setup()
"	python3 del powerline_setup
"endif
"Latex 
Plug 'lervag/vimtex'
"Diff parts of one file (maps defined below)
Plug 'AndrewRadev/linediff.vim'
"vimwiki
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
"session managment
Plug 'tpope/vim-obsession'
" Initialize plugin system
" Plug 'benmills/vimux'
" " running commands in other tmux pane
" Plug 'julienr/vim-cellmode'
" " like vimux but for ipython
Plug 'epeli/slimux'
" maybe this works
" to have better (patience, histogram=fast patience) diff algorithm
" use with :EnhancedDiff histogram
Plug 'chrisbra/vim-diff-enhanced'
" in case at startup there already exists a swap file offer the option to
" compare the two with vimdiff
Plug 'chrisbra/Recover.vim'
" try diffchar to have diff based on chars, not lines. should be more precise
" for indented stuff, but also slower
" from docu: You can use :SDChar and :RDChar commands to manually show and reset the highlights on all or some of lines. To toggle the highlights, use :TDChar command.
" other way is to use :set diffopt+=iwhite
Plug 'rickhowe/diffchar.vim'
call plug#end()


set nocompatible
filetype plugin on
syntax on
set encoding=utf-8

"use solarized colorscheme
syntax enable
colorscheme default
set background=dark
set cursorline
hi CursorLine cterm=NONE ctermbg=8
hi CursorLineNr ctermbg=1
"let g:solarized_termcolors=16

let g:SimpylFold_docstring_preview=1

"Line numbering
set nu
"Use system clipboard
set clipboard=unnamedplus

"hide .pyc files
"let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>


let python_highlight_all=1

"in order to have cursor at end of pasted stuff
nnoremap p gp
"noremap p gp
nnoremap gP P
"noremap gP P

"python with virtualenv support
"may result in problems if py != py2/3 with execfile
if system('hostname') =~ "T1"
	py << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF
endif

"easier navigations with split windows
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

"automatically start search and highlight, and caseinsensitiviy if lowercase
set incsearch hlsearch
set ignorecase
set smartcase

"on pressing tab show list of options, dont just insert first
set wildmenu
"always show at least one line below cursor and 5 to the side (scroll
"apprptly)
set scrolloff=1
set sidescrolloff=5

"for linediff
noremap \ldt :Linediff<CR>
noremap \ldo :LinediffReset<CR>

"powerline
set laststatus=2 " Always display the statusline in all windows

"new lines into normal mode
nmap <C-o> O<Esc>
nmap <CR> o<Esc>

map <leader><Space> :set foldlevel=0<CR>
map <leader><Space><Space> :set foldlevel=99<CR>

"make updates, e.g. of gitgutter faster (in ms)
set updatetime=100


function! GetDiffBuffers()
    return map(filter(range(1, winnr('$')), 'getwinvar(v:val, "&diff")'), 'winbufnr(v:val)')
endfunction

function! DiffPutAll()
    for bufspec in GetDiffBuffers()
        execute 'diffput' bufspec
    endfor
endfunction

command! -range=-1 -nargs=* DPA call DiffPutAll()

" " <<<Vimux
" " Run the current file with rspec
" map <Leader>rb :call VimuxRunCommand("clear; rspec " . bufname("%"))<CR>
" " Prompt for a command to run
" map <Leader>vp :VimuxPromptCommand<CR>
" " Run last command executed by VimuxRunCommand
" map <Leader>vl :VimuxRunLastCommand<CR>
" " Inspect runner pane
" map <Leader>vi :VimuxInspectRunner<CR>
" " Close vim tmux runner opened by VimuxRunCommand
" map <Leader>vq :VimuxCloseRunner<CR>
" " Interrupt any command running in the runner pane
" map <Leader>vx :VimuxInterruptRunner<CR>
" " Zoom the runner pane (use <bind-key> z to restore runner pane)
" map <Leader>vz :call VimuxZoomRunner()<CR>
" " Vimux>>>

let g:slimux_select_from_current_window = 1
map <Leader>b :SlimuxREPLSendBuffer<CR>

" Allow saving of files as sudo when I forgot to start vim using sudo.
" from https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work#7078429
cmap w!! w !sudo tee > /dev/null %

" wrap and textwidth done in filetypes, see vim folder
" line at 80 (+1 would be after textwidth -> wrap line)
set colorcolumn=80
highlight ColorColumn ctermbg=lightgrey guibg=lightgrey
" better title to distinguish hel and t1
auto BufEnter * let &titlestring = hostname() . "::" . expand("%:t")
set title

" no more unnerving errors with vimtex
let g:syntastic_quiet_messages = { "regex": [
        \ '\mpossible unwanted space at "{"',
	\ 'Command terminated with space.',
	\ "You should perhaps use ..max. instead.",
	\ 'Vertical rules in tables are ugly.',
	\ 'Use .toprule, midrule, or .bottomrule from booktabs.',
        \ ] }

" ycm for tex files, works beautifully
if !exists('g:ycm_semantic_triggers')
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers.tex = g:vimtex#re#youcompleteme

" open Gstatus with small height
nnoremap <silent> <Leader>gs :Gstatus<CR>:20wincmd_<CR>

" remove colorbar for vimwiki
autocmd FileType vimwiki set colorcolumn=0

" all but jobname are defualt, see :help vimtex_compiler_latexmk
let g:vimtex_compiler_latexmk = {
    \ 'backend' : 'jobs',
    \ 'background' : 1,
    \ 'build_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk',
    \ 'options' : [
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-jobname=tmp.main',
    \   '-interaction=nonstopmode',
    \ ],
    \}
" dont open it automatically
let g:vimtex_view_automatic = 0
"let g:vimtex_quickfix_method = 'pplatex'
let g:vimtex_quickfix_latexlog = {
  \ 'overfull' : 0,
  \ 'underfull' : 0,
  \ 'packages' : {
  \   'hyperref' : 0,
  \ },
  \}
map <localleader>ls :VimtexCompileSS<CR>

"" scroll and advance the cursor
"map <c-j> j<c-e>
"map <c-k> k<c-y>

" ROT13 the buffer
map <F5> ggg?G``

" return to normal mode by typing jk
imap jk <ESC>

" default tex flavour
let g:tex_flavor = 'tex'
