set makeprg=shellcheck\ -f\ gcc\ %
" redraw! to hide jump to shell
" ! after make to _not_ jump to first error
au BufWritePost * :silent make! | redraw!
