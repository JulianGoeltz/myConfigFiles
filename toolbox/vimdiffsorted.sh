#!/bin/bash
# take files, sort their contents and vimdiff that

comm="vimdiff "
for file in "$@"; do
	# maybe use LC_COLLATE=C for the sort
	comm="${comm} <(echo $file; (cat ${file} | grep -vP '^$' | tr -s '[:blank:]' ' ' | sort --version-sort) )"
done

eval $comm
