#!/bin/bash
# easy way to clean all slurm results:

set -euo pipefail

find . -size 0 -delete -name "*slurm-*.out"

grep no\ voltages\ saved slurm* --files-with-matches | xargs rm

grep -iP "(stepd|error)" slurm*

grep -P "(error|file exists)" $(grep "file exists" --files-with-matches )

grep "L1 locking fail" slurm*
