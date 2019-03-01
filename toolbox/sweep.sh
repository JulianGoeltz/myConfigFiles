#!/bin/zsh

maxNumberOfJobs=100
tokenForAnimation="ThisIsASweepedJobWithJobNumber"

programCall=$3
relPath=$2

# this is st no errors are shown for the filename generation
set -3

# explanation
if [ $# -eq 0 ]; then
	echo "This is a file to use sbatch for every file in a folder. The slurm call is the first argument (including niceness, wmod etc if wanted). The program (with routine) is the third argument, the folder is the second argument, e.g:"
	echo 'sweep.sh "sbatch -p simulation --nice 100 --begin=now+6hours --time 5-0:0:0" ../data/20180712_sweepImp "python train.py xor_yccp_adjusted"'
	# --begin=now+6hours  # if one wants the jobs to start later
	# --time 5-00:00:00  # timelimit. get defaults with sinfo -o "%.12P %.5a %.10l %.10L %.6D %.6t %N"
	# -nice 100 # to have low priority st jobs that one sends later start first
	echo "No more than $maxNumberOfJobs jobs (change in the .sh file) will be launched, in the execution you are asked how many file per job"
	exit
fi

trigger="RESETALLTHEJOBS"
trigger2="useHDF5"
# remove the '_fileHasBeenSend' and '.hdf5' files, if the third argument is $trigger
# first it is checked whether there are no current jobs running, otherwise asks for explicit confirmation
# for each file checks whether training.svg and volts.svg exist, otherwise deletes _fileHasBeenSend and .hdf5
if [[ "$1" == "$trigger" ]]; then
	echo "(tip: to delete all _fileHasBeenSend where no hdf5 exists yet, simply do 'rm **/*_fileHasBeenSend'"
	read "test?you are about to go through the directory $relPath and its subdirectories and delete all .hdf5 and _fileHasBeenSend where hdf5 is not readonly (all where more than one timestamp exist, one will be deleted). Sure to do this (y/n):"
	case $test in 
		'y') echo continue...;;
		*) exit;;
	esac
	if [ -n "$(squeue -u $USER --noheader)" ]; then
		squeueRepeat.sh -vv
		read "test?There are still jobs in the queue, are you sure you want to do this?(y/n)"
		case $test in 
			'y') echo continue...;;
			*) exit;;
		esac
	fi

	numOfAllfHBSFiles=$(find $relPath -name "*.hdf5" -perm 644 | wc -l)
	numOfFilesLookedAt=0
	for file in $(find $relPath -name "*.hdf5" -perm 644); do
		#file=../data/20180712_sweepImp/simulations/taurat0_cuba_x_-l1U_5.0-l1UF_0.0-frobU_0.0-frobUF_0.0-dw_200-l2r_0.0100-learn_0.0050_fileHasBeenSend
		fnPurish=${file:0:-20}
		numOfFilesLookedAt=$(($numOfFilesLookedAt+1))
		#echo $fnPurish

		# here check whether more than one exists, and if so delete
		# if [ $(ls $fnPurish*.hdf5 2>/dev/null | wc -l) -gt 1 ]; then
		# 	echo "($numOfFilesLookedAt/$numOfAllfHBSFiles)"$fnPurish
		# 	tmp=$(ls $fnPurish*.hdf5 | head -n 1)
		# 	# maybe use tail-n +1 to have all lines except the first one, and delete them?
		# 	tmp=${tmp//.hdf5}
		# 	#tmp=$(ls $tmp*)
		# 	rm -f $tmp*
		# fi

		rm $fnPurish*
		echo "($numOfFilesLookedAt/$numOfAllfHBSFiles)"$fnPurish

	done

	exit
fi

# defining slurm call
slurmCall=$1

function sendAway () {
	# eval or, for debug, echo
	eval "${slurmCall} --wrap '${currentJob}'"
}


accumulatedFiles=0
allFiles=0
alreadyStartedJobs=0
currentJob=""
numOfFilesLookedAt=0

if [[ "$4" == "$trigger2" ]]; then
	identifyingBit=".hdf5"
	subFolderSour=$5
	[ -z $subFolderSour ] && subFolderSour="simulations"
	tmpInt=${subFolderSour:11}
	[ -z $tmpInt ] && tmpInt=2 || tmpInt=$(($tmpInt+1))
	subFolderDest="../simulations$tmpInt"
else
	identifyingBit=".yaml"
	subFolderSour=""
	subFolderDest="simulations"
fi

numOfAllFiles=$(ls $relPath/**/$subFolderSour/*$identifyingBit | wc -l)
echo "Do you really want to process $numOfAllFiles files with termination $identifyingBit in the subdirectories '$subFolderSour' of $relPath?"
read "numOfFilesPerJob?How many calls at most in one job: "

case $numOfFilesPerJob in
	''|*[!0-9]*) exit ;;
	*) echo continue... ;;
esac

for fn in $(ls $relPath/**/$subFolderSour/*$identifyingBit); do
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
	fnFolder=$(dirname $fn)/$subFolderDest
	fnPure=$(basename "${fn%.*}")
	[ -n "$(ls $fnFolder/${fnPure}_* 2>/dev/null)" ] && continue
	[ ! -d "$fnFolder" ] && mkdir "$fnFolder"

	accumulatedFiles=$(($accumulatedFiles+1))
	allFiles=$(($allFiles+1))
	#token to make it clear in animation that multiple jobs exist
	currentJob=$currentJob"echo "$tokenForAnimation$accumulatedFiles"of"$numOfFilesPerJob";"
	#actual job
	currentJob=$currentJob$programCall" "$fn";"
	touch "$fnFolder/${fnPure}_fileHasBeenSend"
done
# run the remaining jobs if there are any
if [ $accumulatedFiles -gt 0 ]; then
       	sendAway
	alreadyStartedJobs=$(($alreadyStartedJobs+1))
fi

echo "started $allFiles files in $alreadyStartedJobs jobs."
