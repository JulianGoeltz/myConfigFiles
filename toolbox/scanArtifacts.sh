#!/bin/bash
#
# create artifacts that look like a scan


# quality of the two calls is differen

convert -density 150 "$1" -colorspace gray \( +clone -blur 0x1 \) +swap -compose divide -composite -linear-stretch 5%x0% -rotate 1.5 scan.pdf

# convert -density 150 "$1" -colorspace gray  -blur 0x0.8 -attenuate 0.25 -linear-stretch 3.5%x10% -rotate 0.5 scan.pdf
