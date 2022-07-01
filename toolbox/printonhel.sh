#!/bin/bash
# print on r1 in KIP by copying a file to wang and print via hel; also delete file again

set -euo pipefail

if [ $# -eq 0 ]; then
	echo "there should be an argument"
	exit 1
fi
# copy all files to tmp folder on wang
scp "$@" hel:printing/tmp/
# for each file given as argument
for file in "$@"; do
	# print and delete file
	ssh hel 'lp -U jgoeltz -o fit-to-page -o sides=two-sided-long-edge -o media=A4 -h printer.kip.uni-heidelberg.de -d r1 "printing/tmp/'$file'"; rm "printing/tmp/'$file'";';
done
