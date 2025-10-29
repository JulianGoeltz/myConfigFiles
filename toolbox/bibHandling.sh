#/bin/bash

set -euo pipefail

help_text() {
	cat <<EOF
Help with acquirement and formatting of bibtex
argument needs to be one of bibtex, doi, arxiv, or isbn.
if no argument given, use rofi to determine
for the latter 3, the bibtex is first gathered.
for all, a combination of bibtool (for a good label and some formatting) and
	bibtext-tidy are used for the end result
EOF
}

if [ $# -ne 1 ]; then
	arg=$(echo "bibtex|doi|arxiv|isbn" | rofi -sep '|' -dmenu -p "what information is in the clipboard?" -l 5)
else
	arg=$1
fi

fileBase=/tmp/bib_$arg
echo "using fileBase '${fileBase}'"
# switch cases
case $arg in
	"bibtex")
		xclip -o -selection clipboard > ${fileBase}.bib
		;;
	"doi")
		xclip -o -selection clipboard > ${fileBase}.id
		doi2bib --input ${fileBase}.id --output ${fileBase}.bib
		;;
	"arxiv")
		xclip -o -selection clipboard > ${fileBase}.id
		curl --silent https://arxiv.org/bibtex/$(cat ${fileBase}.id) > ${fileBase}.bib
		;;
	"isbn")
		xclip -o -selection clipboard > ${fileBase}.id
		curl -X POST --header "Content-Type: application/json" --data '{"input": "'"$(cat ${fileBase}.id)"'", "targetFormat": "Bibtex", "fromIds": true}' "https://api.paperpile.com/api/public/convert" > ${fileBase}.json
		cat ${fileBase}.json | jq --raw-output '.output' > ${fileBase}.bib
		;;
	"-h"|"--help"|*)
		help_text
		dunstify -t 60000 "bibHandling encounterer an error"
		exit
		;;
esac
echo "after case esac"

# one pass to get rid of umlauts
cat ${fileBase}.bib | bibtex-tidy --output ${fileBase}_tidy.bib

bibtool -r /home/julgoe/Documents/papers/GUT-bib/bibtool.rsc ${fileBase}_tidy.bib > ${fileBase}_tidy_tool.bib
cat ${fileBase}_tidy_tool.bib | bibtex-tidy --curly --numeric --duplicates --blank-lines --sort --sort-fields --output ${fileBase}_tidy_tool_tidy.bib
xterm -name FXTerm -e nvim ${fileBase}_tidy_tool_tidy.bib
xclip -i -selection clipboard < ${fileBase}_tidy_tool_tidy.bib
