#!/bin/bash

if [ $# -eq 0 ]; then
	echo "first argument is string of wafers, separated by whitespaces"
	echo "all other arguments are the files where the following call is executed"
	echo '    sbatch -p experiment --time 1-0:0:0 --wmod $wafer --wrap "singularity exec --app visionary-wafer /containers/stable/latest ./train.py train_yccp $file"'
	exit
fi

waferString=$1
shift
if [ ! -f $1 ]; then
	repetition=$1
	shift
	echo "Using $repetition repetitions"
else
	repetition=1
fi
filesList=$@
for wafer in $(echo $waferString | grep -oP "\S*"); do
	echo "wafer $wafer:"
	for file in $filesList; do
		echo "    $file:"

		tmpInt=$repetition
		while [ $tmpInt -gt 0 ]; do
			# containerPath=/containers/stable/latest
			# containerPath=/containers/stable/2019-01-11_1.img
			echo -n "        "
			sbatch -p experiment \
				--time 1-0:0:0 \
				--wmod $wafer \
				--hicann 271,239,203,204,299,322,323,301 \
				--fpga 12,24,28,29,30,31 \
				--wrap "run_nmpm_software ./train.py train_yccp $file"
			tmpInt=$(($tmpInt - 1))
		done
	done
done