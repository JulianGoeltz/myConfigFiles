#!/bin/bash
# print on ${printer}=hbp-printer in KIP by copying a file to wang and print via hel; also delete file again

printer="hbp-printer"

set -euo pipefail

if [ $# -eq 0 ]; then
	echo "there should be an argument"
	exit 1
fi
# for each file given as argument
for file in "$@"; do
	# cleaned filename
	fileTrimmed="$(echo "$file" | sed 's/[^0-9A-Za-z.-]//g')"
	# copy file to tmp folder on wang
	scp "$file" hel:printing/tmp/"$fileTrimmed"
	# print and delete file
	ssh hel 'lp -U jgoeltz -o fit-to-page -o sides=two-sided-long-edge -o media=A4 -h printer.kip.uni-heidelberg.de -d '"${printer}"' "printing/tmp/'"$fileTrimmed"'"; rm "printing/tmp/'"$fileTrimmed"'";';
done
