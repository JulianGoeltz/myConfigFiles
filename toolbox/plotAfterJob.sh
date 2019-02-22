#!/bin/bash

if [ $# -eq 0 ]; then
echo "plot all stuff after it finishes
./plot.py [some methods, one after another] [hdf5]

argument is hdf5, then jobid is found by itself
if second argument is given, than also animating"
exit;
fi

# check whether a plot.py exists in current folder
[ ! -f "plot.py" ] && echo "Execute this command in a 'code' subfolder, needs 'plot.py' to work" && exit

file=$1
jobid=$(h5dump -d input/environment $file | grep SLURM_JOB_ID | grep -o "[0-9]*")
echo "Depending on jobid $jobid"
scontrol show jobid $jobid &>/dev/null
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
		sbatch -p short --depend=afterok:$jobid --wrap "./plot.py $method $file"
	else
		echo -n "without depends, "
		sbatch -p short --wrap "./plot.py $method $file"
	fi
done
# plotting volts need potentially more ram
method=plot_volts
echo "submitting $method"
if [ $jobExist == 0 ]; then
	echo -n "with depends, "
	sbatch -p short --mem 10g --depend=afterok:$jobid --wrap "./plot.py $method $file"
else
	echo -n "without depends, "
	sbatch -p short --mem 10g --wrap "./plot.py $method $file"
fi

if [ $# -gt 1 ]; then
	echo "also animating"
	if [ $jobExist == 0 ]; then
		sbatch -p simulation --depend=afterok:$jobid --wrap "./plot.py animate_training $file"
	else
		sbatch -p simulation --wrap "./plot.py animate_training $file"
	fi
fi
