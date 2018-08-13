#!/bin/bash

standardWidth=20
delimiterDone="|"
delimiterNot='-'
delimiterNot='\xe2\x94\x88'
delimiterStart='\xe2\x96\x95'
delimiterEnd='\xe2\x96\x8f'
delimiterDone='\xe2\x96\x88'
# split on new lines, not spaces. In case we have filenames including spaces
IFS=$'\n'

while true; do
	echo -e \\033c
	date +"%H:%M:%S"
	squeue -o "%.10i %.9P %.8u %.2t %.8M" | grep "longexp\|experimen\|goelt\|JOBID" --color=auto
	if [ "$1" != "" ]; then
		echo $1
		eval $1
	fi
	if [ -n "$(find ./ -maxdepth 1 -name '*slurm*.out')" ]; then
		for file in $(ls *slurm*.out); do
			# if [ $(du $file | grep -o "^[0-9]*") -ge 200000 ]; then
			# 	#this means the file is very large and it will take too long to search through
			#         echo $file is too large, skipping
			# 	continue
		        # fi
			StepNumber=$(grep -oP "Numer_of_steps is [0-9]*" $file | grep -oP "[0-9]*")
			FileCount=$(grep step -c $file)
			[ $? -ne 0 ] && continue
			if [ -z "$StepNumber" ] ; then StepNumber=100; fi
			if [ "$(echo $StepNumber | wc -w)" -gt 1 ] ; then
			        StepNumber=$(echo $StepNumber | grep -o "[0-9]*$" | tail -n 1);
		        fi
			counter=$(($FileCount * $standardWidth / $StepNumber))
			echo -n $file
			jobIsSweep=$(grep -oP "ThisIsASweepedJobWithJobNumber[0-9]*of[0-9]*" $file)
			if [ -n "$jobIsSweep" ] ; then
				echo -n "("$(echo $jobIsSweep | grep -oP "[0-9]*of[0-9]*" | tail -n 1)")"
			fi
			echo -en ":"$delimiterStart
			while (( $counter > 0 )); do
				echo -en $delimiterDone
				counter=$(($counter-1))
			done
			counter=$(($(($StepNumber-$FileCount)) * $standardWidth / $StepNumber))
			while (( $counter > 0 )); do
				echo -en $delimiterNot
				counter=$(($counter-1))
			done
			echo -e $delimiterEnd
		done
	fi
	sleep 10
	# -p "what should be the repetition per job (everything but a number will quit): " 

	# read -t 5 input
	# if [ -n "$input" ]; then
	# 	read -p "How many steps are planned?" StepNumber
	# fi

	# if [ -n "$File1Name" ]; then
	# 	File1Count=$(grep step -c $File1Name)
	# 	counter=$File1Count
	# 	echo -n $File1Name": "
	# 	while (( $counter > 0 )); do
	# 		echo -n $delimiterDone
	# 		counter=$(($counter-1))
	# 	done
	# 	counter=$(($File1Number-$File1Count))
	# 	while (( $counter > 0 )); do
	# 		echo -n $delimiterNot
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

# redo previous change
unset IFS
