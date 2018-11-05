#!/bin/zsh

maxNumberOfJobs=90
tokenForAnimation="ThisIsASweepedJobWithJobNumber"
slurmCall='sbatch -p '
# --begin=now+6hours  # if one wants the jobs to start later
# --time 5-00:00:00  # timelimit. get defaults with sinfo -o "%.12P %.5a %.10l %.10L %.6D %.6t %N"

programCall=$1
relPath=$2

# this is st no errors are shown for the filename generation
set -3

# explanation
if [ $# -eq 0 ]; then
	echo "This is a file to use sbatch for every file in a folder. The program (with routine) is the first argument, the folder is the second argument, e.g:"
	echo 'sweep.sh "python train.py xor_yccp_adjusted" ../data/20180712_sweepImp'
	echo "Unless there's a third argument, the used partition is 'simulation', otherwise 'experiment' with licences for the wafer given as this argument (and, possibly, hicann given as argument four) will be used"
	echo "No more than $maxNumberOfJobs jobs (change in the .sh file) will be launched, in the execution you are asked how many file per job"
	exit
fi

trigger="RESETALLTHEJOBS"
# remove the '_fileHasBeenSend' and '.hdf5' files, if the third argument is $trigger
# first it is checked whether there are no current jobs running, otherwise asks for explicit confirmation
# for each file checks whether training.svg and volts.svg exist, otherwise deletes _fileHasBeenSend and .hdf5
if [[ "$1" == "$trigger" ]]; then
	read "test?you are about to go through the directory $relPath and its subdirectories and delete all .hdf5 and _fileHasBeenSend where no volts.svg and training.svg exist (all where more than one timestamp exist, one will be deleted). Sure to do this (y/n):"
	case $test in 
		'y') echo continue...;;
		*) exit;;
	esac
	if [ -n "$(squeue -u $LOGNAME --noheader)" ]; then
		squeue -u $LOGNAME
		read "test?There are still jobs in the queue, are you sure you want to do this?(y/n)"
		case $test in 
			'y') echo continue...;;
			*) exit;;
		esac
	fi

	numOfAllfHBSFiles=$(find $relPath -name "*_fileHasBeenSend" | wc -l)
	numOfFilesLookedAt=0
	for file in $(find $relPath -name "*_fileHasBeenSend"); do
		#file=../data/20180712_sweepImp/simulations/taurat0_cuba_x_-l1U_5.0-l1UF_0.0-frobU_0.0-frobUF_0.0-dw_200-l2r_0.0100-learn_0.0050_fileHasBeenSend
		fnPurish=${file//_fileHasBeenSend}
		numOfFilesLookedAt=$(($numOfFilesLookedAt+1))
		#echo $fnPurish

		if [ $(ls $fnPurish*.hdf5 2>/dev/null | wc -l) -gt 1 ]; then
			echo "($numOfFilesLookedAt/$numOfAllfHBSFiles)"$fnPurish
			tmp=$(ls $fnPurish*.hdf5 | head -n 1)
			# maybe use tail-n +1 to have all lines except the first one, and delete them?
			tmp=${tmp//.hdf5}
			#tmp=$(ls $tmp*)
			rm -f $tmp*
		fi
		if [ -z "$(ls $fnPurish*_training.svg 2>/dev/null)" ] || [ -z "$(ls $fnPurish*_volts.svg 2>/dev/null)" ]; then
			if [ -n "$(ls $fnPurish*.hdf5 2>/dev/null)" ]; then
				tmp=$(find $fnPurish*.hdf5)
				echo "($numOfFilesLookedAt/$numOfAllfHBSFiles)"$tmp
				rm $tmp
			fi
			echo "($numOfFilesLookedAt/$numOfAllfHBSFiles)"$file
			rm $file
		fi
		# echo `find $relPath/simulations -maxdepth 1 -name "$fnPure*"`
		#training.svg"`

	done

	exit
fi

# if third argument 
if [ $# -gt 3 ]; then
	slurmCall=$slurmCall'experiment --wmod '$3' --hicann '$4' '
elif [ $# -gt 2 ]; then
	slurmCall=$slurmCall'experiment --wmod '$3' '
else
	slurmCall=$slurmCall'simulation '
        # --time=0:22:0'
fi

function sendAway () {
	# eval or, for debug, echo
	eval "${slurmCall} --wrap '${currentJob}'"
}

numOfAllFiles=$(find $relPath -name \*.yaml | wc -l)
echo "Do you really want to process $numOfAllFiles files in the directory $relPath?"
read "numOfFilesPerJob?How many calls at most in one job: "

case $numOfFilesPerJob in
	''|*[!0-9]*) exit ;;
	*) echo continue... ;;
esac


accumulatedFiles=0
allFiles=0
alreadyStartedJobs=0
currentJob=""
numOfFilesLookedAt=0
for fn in `find $relPath -name "*.yaml"`; do
	numOfFilesLookedAt=$(($numOfFilesLookedAt+1))
	if [ $accumulatedFiles -ge $numOfFilesPerJob ]; then
		sendAway
		accumulatedFiles=0
		currentJob=$startingCall
		alreadyStartedJobs=$(($alreadyStartedJobs+1))
	fi
	[ $alreadyStartedJobs -ge $maxNumberOfJobs ] && break;
	echo "($numOfFilesLookedAt/$numOfAllFiles)$alreadyStartedJobs:$accumulatedFiles, current file $fn"
	# check whether file already processed
	fnFolder=$(dirname $fn)/simulations
	fnPure=$(basename "${fn%.*}")
	[ -n "$(ls $fnFolder/$fnPure* 2>/dev/null)" ] && continue
	if [ ! -d "$fnFolder" ]; then mkdir "$fnFolder"; fi

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
