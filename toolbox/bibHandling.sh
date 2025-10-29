#/bin/bash

fileBase=/tmp/bib_arxiv
# curl --silent https://arxiv.org/bibtex/$1 > ${fileBase}.bib
xclip -o -selection clipboard > ${fileBase}.id
curl --silent https://arxiv.org/bibtex/$(cat ${fileBase}.id) > ${fileBase}.bib


bibtool -r /home/julgoe/Documents/papers/GUT-bib/bibtool.rsc ${fileBase}.bib > ${fileBase}_tool.bib
cat ${fileBase}_tool.bib | bibtex-tidy --curly --numeric --duplicates --blank-lines --sort --sort-fields --output ${fileBase}_tool_tidy.bib
xterm -name FXTerm -e nvim ${fileBase}_tool_tidy.bib
xclip -i -selection clipboard < ${fileBase}_tool_tidy.bib

