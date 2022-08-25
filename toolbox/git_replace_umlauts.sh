#!/bin/bash

help_text() {
	cat <<EOF
Checks whether any diff has an umlaut, if so uses vim ex to ease replacement
EOF
}

if [ $# -gt 0 ]; then
	help_text
	exit
fi

for str in \
	ae_ä \
	oe_ö \
	ue_ü \
	Ae_ä \
	Oe_Ö \
	Ue_Ü \
	ss_ß \
	; do
	tgt=${str:0:2}
	repl=${str:3:4}
	# echo $str $tgt $repl
	tmp="$(git diff --numstat -S "$tgt" )"
	if [ -n "$tmp" ]; then
		for file in $(git diff --numstat -S "$tgt" | cut -f 3); do
			vim -c '%s/'"$tgt"'/'"$repl"'/gc' -c 'wq' $file
		done
	fi
done
