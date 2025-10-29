#/bin/bash

set -euo pipefail

help_text() {
	cat <<EOF
Help with acquirement and formatting of bibtex
argument needs to be one of bibtex, doi, arxiv, or isbn.
for the latter 3, the bibtex is first gathered.
for all, a combination of bibtool (for a good label and some formatting) and
	bibtext-tidy are used for the end result
EOF
}

if [ $# -ne 1 ]; then
	help_text
	exit 1
fi

fileBase=/tmp/bib_$1
# parse potential arguments
while [ "$#" -gt 0 ]; do
	case $1 in
		"bibtex")
			xclip -o -selection clipboard > ${fileBase}.bib
			shift
			;;
		"doi")
			xclip -o -selection clipboard > ${fileBase}.id
			doi2bib --input ${fileBase}.id --output ${fileBase}.bib
			shift
			;;
		"arxiv")
			# curl --silent https://arxiv.org/bibtex/$1 > ${fileBase}.bib
			xclip -o -selection clipboard > ${fileBase}.id
			curl --silent https://arxiv.org/bibtex/$(cat ${fileBase}.id) > ${fileBase}.bib
			shift
			;;
		"isbn")
			xclip -o -selection clipboard > ${fileBase}.id
			curl -X POST --header "Content-Type: application/json" --data '{"input": "'"$(cat ${fileBase}.id)"'", "targetFormat": "Bibtex", "fromIds": true}' "https://api.paperpile.com/api/public/convert" > ${fileBase}.json
			cat ${fileBase}.json | jq --raw-output '.output' > ${fileBase}.bib
			shift
			;;
		"-h"|"--help"|*)
			help_text
			exit
			;;
	esac
done

# one pass to get rid of umlauts
cat ${fileBase}.bib | bibtex-tidy --output ${fileBase}_tidy.bib

bibtool -r /home/julgoe/Documents/papers/GUT-bib/bibtool.rsc ${fileBase}_tidy.bib > ${fileBase}_tidy_tool.bib
cat ${fileBase}_tidy_tool.bib | bibtex-tidy --curly --numeric --duplicates --blank-lines --sort --sort-fields --output ${fileBase}_tidy_tool_tidy.bib
xterm -name FXTerm -e nvim ${fileBase}_tidy_tool_tidy.bib
xclip -i -selection clipboard < ${fileBase}_tidy_tool_tidy.bib
