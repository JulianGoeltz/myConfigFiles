#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh


tmp=""
if pgrep gridspeccer >/dev/null; then
	tmp="${tmp}gridspeccer; "
fi
if pidof pdflatex >/dev/null; then
	tmp="${tmp}pdflatex $(ps --no-headers -o command "$(pgrep pdflatex | head -n1)" | awk '{ print $NF}'),"
fi
if pidof lualatex >/dev/null; then
	tmp="${tmp}lualatex,"
fi
if pidof xelatex >/dev/null; then
	tmp="${tmp}xelatex,"
fi
if [[ "${#tmp}" -gt "1" ]]; then
	echo "${tmp:0:-1} running"
fi

