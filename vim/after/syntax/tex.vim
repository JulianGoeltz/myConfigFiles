syntax match texInputFile /\\inputpgf\s*\%(\[.\{-}\]\)\=\s*{.\{-}}{.\{-}}/
      \ contains=texStatement,texInputCurlies,texInputFileOpt,texInputFileOpt

syntax match texInputFile /\\inlinecode\s*\%(\[.\{-}\]\)\=\s*{.\{-}}{.\{-}}/
      \ contains=texStatement,texInputCurlies,texInputFileOpt,texInputFileOpt

syntax match texInputFile /\\import\s*\%(\[.\{-}\]\)\=\s*{.\{-}}{.\{-}}/
      \ contains=texStatement,texInputCurlies,texInputFileOpt,texInputFileOpt

" dont spellcheck easylists. those are for writing down ideas for me, dont
" need spellcheck for those
syntax region texZone start="\\begin{easylist}" end="\\end{easylist}\|%stopzone\>" contains=@NoSpell
