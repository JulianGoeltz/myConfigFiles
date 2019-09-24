#!/bin/bash
set -euo pipefail

tmpfile=~/myConfigFiles/i3scripts/tmpSymbols.txt

# in case of first ever execution, create tmp file with used numbers in front
if ! [ -f  "$tmpfile" ]; then
	! [ -f ~/myConfigFiles/i3scripts/unicodeSymbolList.txt ] && dunstify "Problem with unicode list, look in script" && exit
	awk '{print "0 "$0}' ~/myConfigFiles/i3scripts/unicodeSymbolList.txt > $tmpfile
	sort -r -o $tmpfile $tmpfile
fi

# open rofi and have user select desired symbol
line=$(cut -d ' ' -f2-100 $tmpfile  | rofi -dmenu  -lines 10)

# extract symbol from return value (first character) and paste it to xclip
echo $line | cut -d' ' -f1 -z | xclip -selection c

# rest is done in background

# add 1 to the respective line
gawk -i inplace '{if ($0 ~ /'"$line"'/) { tmp=$1+1; $1=""; print tmp$0} else {print}}' $tmpfile

# sort st next time the lines are in sorted order
sort -r -o $tmpfile $tmpfile
