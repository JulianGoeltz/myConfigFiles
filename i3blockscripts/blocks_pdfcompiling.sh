#!/bin/bash

# set -euo pipefail
source /home/julgoe/myConfigFiles/i3blockscripts/blocks_defines.sh


tmp=""
if pgrep gridspeccer >/dev/null; then
	tmp="${tmp}gridspeccer; "
fi
if pidof pdflatex >/dev/null; then
	tmp="${tmp}pdf,"
fi
if pidof lualatex >/dev/null; then
	tmp="${tmp}lua,"
fi
if pidof xelatex >/dev/null; then
	tmp="${tmp}xe,"
fi
if [[ "${#tmp}" -gt "1" ]]; then
	echo "${tmp:0:-1}latex running"
fi

