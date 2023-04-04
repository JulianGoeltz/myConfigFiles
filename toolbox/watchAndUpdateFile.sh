#!/bin/bash
# Ideal for automatically updating files mounted by sshfs where changes are not communicated to e.g. eog

if [ "$#" -gt 1 ]; then
	for f in "$@"; do
		watchAndUpdateFile.sh "$f"
	done
	exit
fi

file="$1"

filename="${file//[^0-9A-Za-z./-]/}"
filename="/tmp/${filename//\//__}"
# echo "${file} -> ${filename}"; exit
cp "$file" "$filename"

eog "$filename"&
while true; do
	cmp -s $file "$filename" || (
		cp $file "$filename".tmp
		mv "$filename".tmp "$filename"
		# date
		sleep 5
	)
	sleep 0.3
done&
echo $!
