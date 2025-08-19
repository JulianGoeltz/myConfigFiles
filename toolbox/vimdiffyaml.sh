#!/bin/bash

call="nvim -d "
for file in "$@"; do
	call="${call} <(echo "${file}"; cat "${file}" | yaml2json | json2yaml)"
done

eval "$call"
