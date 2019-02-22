syntax match texInputFile /\\inputpgf\s*\%(\[.\{-}\]\)\=\s*{.\{-}}{.\{-}}/
      \ contains=texStatement,texInputCurlies,texInputFileOpt,texInputFileOpt

syntax match texInputFile /\\inlinecode\s*\%(\[.\{-}\]\)\=\s*{.\{-}}{.\{-}}/
      \ contains=texStatement,texInputCurlies,texInputFileOpt,texInputFileOpt

syntax match texInputFile /\\import\s*\%(\[.\{-}\]\)\=\s*{.\{-}}{.\{-}}/
      \ contains=texStatement,texInputCurlies,texInputFileOpt,texInputFileOpt

