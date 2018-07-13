#!/bin/bash

maxNumberOfJobs=90
tokenForAnimation="ThisIsASweepedJobWithJobNumber"
slurmCall='sbatch -p ' # --begin=now+6hours  # if one wants the jobs to start later

if [ $# -eq 0 ]; then
	echo "This is a file to use sbatch for every file in a folder. The program (with routine) is the first argument, the folder is the second argument, e.g:"
	echo 'sweep.sh "python train.py xor_yccp_adjusted" ../data/20180712_sweepImp'
	echo "Unless there's a third argument, the used partition is 'simulation', otherwise 'experiment' with licences for the wafer given as this argument (and, possibly, hicann given as argument four) will be used"
	echo "No more than $maxNumberOfJobs jobs (change in the .sh file) will be launched, in the execution you are asked how many file per job"
	exit
fi

# if third argument 
if [ $# -gt 3 ]; then
	slurmCall=$slurmCall'experiment --wmod '$3' --hicann '$4' '
elif [ $# -gt 2 ]; then
	slurmCall=$slurmCall'experiment --wmod '$3' '
else
	slurmCall=$slurmCall'simulation '
fi

function sendAway () {
	# eval or, for debug, echo
	eval "${slurmCall} --wrap '${currentJob}'"
}

programCall=$1
relPath=$2

echo "Do you really want to process $(find $relPath -maxdepth 1 -name \*.yaml | wc -l) files in the directory $relPath?"
read -p "How many calls at most in one job: " numOfFilesPerJob

case $numOfFilesPerJob in
	''|*[!0-9]*) exit ;;
	*) echo continue... ;;
esac

accumulatedFiles=0
allFiles=0
alreadyStartedJobs=0
currentJob=""
for fn in `find $relPath -maxdepth 1 -name "*.yaml"`; do
	if [ $accumulatedFiles -ge $numOfFilesPerJob ]; then
		sendAway
		accumulatedFiles=0
		currentJob=$startingCall
		alreadyStartedJobs=$(($alreadyStartedJobs+1))
	fi
	[ $alreadyStartedJobs -ge $maxNumberOfJobs ] && break;
	echo "$alreadyStartedJobs:$accumulatedFiles, current file $fn"
	# check whether file already processed
	fnFolder=$(dirname $fn)/simulations
	fnPure=$(basename "${fn%.*}")
	[ -n "$(find $fnFolder -name $fnPure*)" ] && continue

	accumulatedFiles=$(($accumulatedFiles+1))
	allFiles=$(($allFiles+1))
	#token to make it clear in animation that multiple jobs exist
	currentJob=$currentJob"echo "$tokenForAnimation$accumulatedFiles"of"$numOfFilesPerJob";"
	#actual job
	currentJob=$currentJob$programCall" "$fn";"
	touch $fnFolder/$fnPure"_fileHasBeenSend"
done
# run the remaining jobs if there are any
if [ $accumulatedFiles -gt 0 ]; then
       	sendAway
	alreadyStartedJobs=$(($alreadyStartedJobs+1))
fi

echo "started $allFiles files in $alreadyStartedJobs jobs."
