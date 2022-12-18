#!/bin/bash
#


call="xrandr "

IFS=$'\n'
for line in $(xrandr | grep " connected"); do
	output=$(echo $line | cut -d " " -f1)
	if $(echo $line | grep -q primary); then
		prim="--primary"
	else
		prim=""
	fi

	# (?=PATTERN) is a look-ahead operator that matches but doesn't include the match in the result
	mode="$(echo $line | grep -oP "[0-9]+x[0-9]+(?=\+[0-9]+\+[0-9]+)")"
	if [ -z "$mode" ]; then
		mode="--off"
	else
		mode="--mode ${mode}"
	fi

	call="${call} --output ${output} ${mode} $prim "
done
unset IFS

echo "Does not yet include positions like '--above'"
echo $call
