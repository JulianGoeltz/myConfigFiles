#!/bin/bash

zathura -x "vim --servername THESISTEX --remote-expr \"vimtex#view#reverse_goto(%{line}, '%{input}')\" --synctex-forward 1:1:/home/julgoe/Dropbox/uni/MasterThesis/thesis/thesis-skeleton/main.tex" /home/julgoe/Dropbox/uni/MasterThesis/thesis/thesis-skeleton/main.pdf
# chromium-browser --window-size=1920,1080 --window-position=0,0
