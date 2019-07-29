#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
	echo "first argument is string of wafers, separated by whitespaces"
	echo "if second argument is not an existing file it is taken as the rep number"
	echo "all other arguments are the files where the following call is executed"
	echo '    sbatch -p experiment --time 1-0:0:0 --wmod $wafer --wrap "singularity exec --app visionary-wafer /containers/stable/latest ./train.py train_yccp $file"'
	exit
fi

# if ! module list 2>&1 >/dev/null | grep -q slurm-singularity ; then 
# 	echo "Do 'module load slurm-singularity/...' to start plotting scripts from within."
# 	exit
# fi

# define licences wafer-specific
hicann_wafer=(
	[33]="271,239,272,240,299,322,323,301"
	[37]="271,239,299,322,323,301"
	)

waferString=$1
shift
if [ ! -f "$1" ]; then
	repetition=$1
	shift
	echo "Using $repetition repetitions"
else
	repetition=1
fi
filesList=( "$@" )
for wafer in $(echo "$waferString" | grep -oP "\S*"); do
	echo "wafer $wafer:"
	for file in "${filesList[@]}"; do
		echo "    $file:"

		tmpInt=$repetition
		while [ $tmpInt -gt 0 ]; do
			# containerPath=/containers/stable/latest
			# containerPath=/containers/stable/2019-01-11_1.img
			# exclude nodes with `-x HBPHost9 \`
			output=$(OMP_NUM_THREADS=48 sbatch -p experiment \
					--time 1-0:0:0 \
					--wmod "$wafer" \
					-c8 \
					--mem 10g \
					--hicann "${hicann_wafer[$wafer]}" \
					--wrap "run_nmpm_software ./train.py train_yccp $file"
			)
			jobid=$(echo "$output" | grep -oP "\d*")
			echo "        submitted $jobid"
			plotAfterJob.sh "$jobid" >/dev/null &
			((tmpInt--))
		done
	done
done
