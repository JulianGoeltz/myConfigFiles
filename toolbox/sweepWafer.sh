#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
	cat <<-EOF
		first argument is string of wafers, separated by whitespaces
		if second argument is not an existing file it is taken as the rep number
		all other arguments are the files where the following call is executed
		    sbatch -p experiment --time 12:0:0 --wmod \$wafer --wrap "run_nmpm_software ./train.py train_yccp \$file"

		    if $partition is in environment, it is used instead of `experiment`
		EOF
	exit
fi

# if ! module list 2>&1 >/dev/null | grep -q slurm-singularity ; then 
# 	echo "Do 'module load slurm-singularity/...' to start plotting scripts from within."
# 	exit
# fi

# define licences wafer-specific
hicann_wafer=(
	[30]="269,271,239,299,322,323,301"
	[33]="266,267,235,299,322,323,301"
	[37]="271,239,203,299,322,323,301"
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
			output=$(OMP_NUM_THREADS=48 sbatch -p "${partition:-experiment}" \
					--time 12:0:0 \
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
