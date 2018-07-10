#!/bin/bash
standardWidth=20
delimeterDone="|"
delimeterNot="-"
while true; do
	echo -e \\033c
	date +"%H:%M:%S"
	squeue -o "%.10i %.9P %.8u %.2t %.8M" | grep "experimen\|goelt\|JOBID"
	if [ "$1" != "" ]; then
		echo $1
		eval $1
	fi
	if [ -n "$StepNumber" ]; then
		for file in $(ls *slurm*.out); do
			FileCount=$(grep step -c $file)
			counter=$(($FileCount * $standardWidth / $StepNumber))
			echo -n $file": "
			while (( $counter > 0 )); do
				echo -n $delimeterDone
				counter=$(($counter-1))
			done
			counter=$(($(($StepNumber-$FileCount)) * $standardWidth / $StepNumber))
			while (( $counter > 0 )); do
				echo -n $delimeterNot
				counter=$(($counter-1))
			done
			echo
		done
	fi
	# sleep 5
	# -p "what should be the repetition per job (everything but a number will quit): " 
	read -t 5 input
	if [ -n "$input" ]; then
		read -p "How many steps are planned?" StepNumber
	fi
	# if [ -n "$File1Name" ]; then
	# 	File1Count=$(grep step -c $File1Name)
	# 	counter=$File1Count
	# 	echo -n $File1Name": "
	# 	while (( $counter > 0 )); do
	# 		echo -n $delimeterDone
	# 		counter=$(($counter-1))
	# 	done
	# 	counter=$(($File1Number-$File1Count))
	# 	while (( $counter > 0 )); do
	# 		echo -n $delimeterNot
	# 		counter=$(($counter-1))
	# 	done
	# fi
	# # sleep 5
	# # -p "what should be the repetition per job (everything but a number will quit): " 
	# read -t 5 input
	# if [ -n "$input" ]; then
	#        	echo "Which of the following files do you want to monitor for 'step'"
	# 	ls *slurm*.out
	# 	read File1Name
	# 	read -p "How many steps are planned?" File1Number
	# fi
done
