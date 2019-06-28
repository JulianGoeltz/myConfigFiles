#!/bin/bash

# set -euo pipefail

if [ $# -eq 0 ]; then
echo "plot all stuff after it finishes
./plot.py [some methods, one after another] [hdf5]

argument is hdf5, then jobid is found by itself
for more arguments, the script is called for each one"
exit;
fi

# if more then one argument, process each one the same way
if [ $# -gt 1 ]; then
	for f in "$@"; do
		$0 "$f"
	done
	exit
fi

# check whether a plot.py exists in current folder
[ ! -f "plot.py" ] && echo "Execute this command in a 'code' subfolder, needs 'plot.py' to work" && exit
# check whether h5dump is available
if ! type h5dump >/dev/null 2>&1; then
	echo "h5dump needs to be available. try 'spack load hdf5'"
	exit
fi

file=$1
[ ! -f "$file" ] && echo "File $file doesn't exist" && exit

jobid=$(h5dump -d input/environment "$file" | grep SLURM_JOB_ID | grep -o "[0-9]*")
echo "Depending on jobid $jobid"
scontrol show jobid "$jobid" &>/dev/null
jobExist=$?
# echo $jobExist
# if [ $jobExist == 0 ]; then
# 	echo exists
# else
# 	echo doesnt\ exist
# fi
# exit

for method in \
	   plot_training plot_featureMatrix  plot_raster plot_weightHist plot_weightEvolutionIndividual plot_weightEvolution \
	   ; do
	echo "submitting $method"
	if [ $jobExist == 0 ]; then
		echo -n "with depends, "
		sbatch -p short --depend=afterok:"$jobid" --wrap "run_nmpm_software ./plot.py $method $file"
	else
		echo -n "without depends, "
		sbatch -p short --wrap "run_nmpm_software ./plot.py $method $file"
	fi
done
# plotting volts need potentially more ram
method=plot_volts
echo "submitting $method"
if [ $jobExist == 0 ]; then
	echo -n "with depends, "
	sbatch -p short --mem 10g --depend=afterok:"$jobid" --wrap "run_nmpm_software ./plot.py $method $file"
else
	echo -n "without depends, "
	sbatch -p short --mem 10g --wrap "run_nmpm_software ./plot.py $method $file"
fi

# if [ $# -gt 1 ]; then
# 	echo "also animating"
# 	if [ $jobExist == 0 ]; then
# 		sbatch -p simulation --depend=afterok:"$jobid" --wrap "run_nmpm_software ./plot.py animate_training $file"
# 	else
# 		sbatch -p simulation --wrap "run_nmpm_software ./plot.py animate_training $file"
# 	fi
# fi
