#!/bin/bash
# Take a bunch of json files, prettify them with json_pp and vimdiff the result

call="vimdiff "
for file in "$@"; do
	call="${call} <(echo ${file}; cat ${file} | json_pp) "
done

eval "$call"
