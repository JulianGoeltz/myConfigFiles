#!/bin/bash
#
# create artifacts that look like a scan


# or use to raster fonts
# convert --compress -density 300 SRC DST





# quality of the two calls is differen

# convert -density 150 "$1" -colorspace gray \( +clone -blur 0x1 \) +swap -compose divide  -linear-stretch 5%x0% -rotate 1.5 scan.pdf
convert -density 150 "$1" -colorspace gray  +swap -compose divide  -linear-stretch 5%x0% -rotate 1.5 scan.pdf
# removed -composite to have multiple pages work

# convert -density 150 "$1" -colorspace gray  -blur 0x0.8 -attenuate 0.25 -linear-stretch 3.5%x10% -rotate 0.5 scan.pdf
