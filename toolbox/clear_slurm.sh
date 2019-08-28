#!/bin/bash
# easy way to clean all slurm results:

set -euo pipefail

[ -z "$(find . -name "*slurm-*.out")" ] && \
	echo "No *slurm-*.out files" && \
	exit

[ -n "$(find . -size 0 -name "*slurm-*.out")" ] && \
	echo clearing\ empty\ files && \
	find . -size 0 -delete -name "*slurm-*.out"

if [[ "${1:-}" =~ "volt" ]] ; then
	echo clearing\ volts
	grep no\ voltages\ saved --files-with-matches -- *slurm-*.out | xargs rm
elif [[ "${1:-}" =~ "mem" ]] ; then
	echo clearing\ memory
	grep exceeded\ memory\ limit --files-with-matches -- *slurm-*.out | xargs rm
else
	grep -iP "(stepd|error)" -- *slurm-*.out
fi

ls -lAh -- *slurm-*.out
