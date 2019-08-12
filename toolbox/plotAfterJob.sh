#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
	cat <<-EOF 
		plot all stuff after it finishes
		./plot.py [some methods, one after another] [hdf5]

		argument is hdf5, then jobid is found by itself
		for more arguments, the script is called for each one
		EOF
	exit;
fi

plot_methods="plot_training 
plot_featureMatrix 
plot_raster
plot_volts
plot_weightHist
plot_weightEvolutionIndividual
plot_weightEvolution
"

# check whether a plot.py exists in current folder
if [ ! -f "plot.py" ]; then
	echo "Execute this command in a 'code' subfolder, needs 'plot.py' to work"
	exit
fi
# check whether h5dump is available
if ! type h5dump >/dev/null 2>&1; then
	echo "h5dump needs to be available. try 'spack load hdf5'"
	exit
fi

# if more then one argument, process each one the same way
if [ $# -gt 1 ]; then
	echo "using plotting methods $plot_methods on all files "
	for f in "$@"; do
		echo "$f"
		# parallelise this bit to make it faster
		$0 "$f" >/dev/null &
	done
	echo
	exit
fi

if [ -f "$1" ]; then 
	file=$1
	jobid=$(h5dump -d input/environment "$file" | grep SLURM_JOB_ID | grep -o "[0-9]*")
	echo "Depending on jobid $jobid"
else
	jobid=$1
	file=$jobid
fi

if scontrol show jobid "$jobid" &>/dev/null ; then
	jobExist=true
	# when sharing FGs, some files can already be done, aka readonly
	# in this case start plotting immediately
	if [ "$(stat --format '%a' "$1")" == "444" ]; then
		dependOnJob=false
	else
		dependOnJob=true
	fi
else
	jobExist=false
	dependOnJob=false
fi

if ! { $jobExist || [ -f "$1" ] ; }; then
	echo "File $file doesn't exist and is no jobid either"
	exit
fi

for method in $plot_methods; do
	echo "submitting $method"

	# plotting volts need potentially more ram
	if [ "$method" == "plot_volts" ]; then
		memoption="--mem 25g"
	else
		memoption=""
	fi

	if $dependOnJob; then
		echo -n "with depends, "
		sbatch -p short $memoption --depend=afterok:"$jobid" --wrap "run_nmpm_software ./plot.py $method $file"
	else
		echo -n "without depends, "
		sbatch -p short $memoption --wrap "run_nmpm_software ./plot.py $method $file"
	fi
done

# if [ $# -gt 1 ]; then
# 	echo "also animating"
# 	if [ $jobExist == 0 ]; then
# 		sbatch -p simulation --depend=afterok:"$jobid" --wrap "run_nmpm_software ./plot.py animate_training $file"
# 	else
# 		sbatch -p simulation --wrap "run_nmpm_software ./plot.py animate_training $file"
# 	fi
# fi
