#!/bin/zsh

standardWidth=20
repeatEvery=5
minimumColsForParallel=80
delimiterDone="|"
delimiterNot='-'
delimiterNot='\xe2\x94\x88'
delimiterStart='\xe2\x96\x95'
delimiterEnd='\xe2\x96\x8f'
delimiterDone='\xe2\x96\x88'
# split on new lines, not spaces. In case we have filenames including spaces
IFS=$'\n'

while true; do
	startTimestamp=$(date +%s)
	# decide whether to use sequential or parallel, based on terminal size
	# first compose longer part, then echo all at once
	output=""
	if [ "$(tput cols)" -gt "$minimumColsForParallel" ]; then
		# output=$output"with $(tput cols) we use the parallel display\n"
		for linefeed in $(squeue -o "%.10i %.9P %.8u %.2t %.8M" | grep "longexp\|experimen\|goelt\|JOBID" --color=never); do
			if [ -z "$(echo $linefeed | grep jgoeltz)" ]; then
				output=$output$(echo $linefeed | grep "longexp\|experimen\|goelt\|JOBID" --color=always)"\n"

			else
				output=$output$(echo $linefeed | grep jgoeltz --color=always)
				jobid=$(echo $linefeed | grep -oP '^\s*([0-9]*)' | grep -o '[0-9]*')
				file=$(find ./ -maxdepth 1 -name "*slurm-$jobid.out")
				if [ -n "$file" ]; then
					# if [ $(du $file | grep -o "^[0-9]*") -ge 200000 ]; then
					# 	#this means the file is very large and it will take too long to search through
					#         echo $file is too large, skipping
					# 	continue
					# fi
					StepNumber=$(grep -oP "Numer_of_steps is [0-9]*" $file | grep -oP "[0-9]*")
					FileCount=$(grep step -c $file)
					[ $? -ne 0 ] && output=$output"\n" && continue
					if [ -z "$StepNumber" ] ; then StepNumber=100; fi
					if [ "$(echo $StepNumber | wc -w)" -gt 1 ] ; then
						StepNumber=$(echo $StepNumber | grep -o "[0-9]*$" | tail -n 1);
					fi
					# subtract small number that is added later to circumvent false rounding
					counter=$(( ($FileCount - 0.1) * $standardWidth / $StepNumber))
					# output=$output$file
					output=$output" "$delimiterStart
					while (( $counter > 0 )); do
						output=$output$delimiterDone
						counter=$(($counter-1))
					done
					counter=$(( ($StepNumber-$FileCount + 0.1) * $standardWidth / $StepNumber))
					while (( $counter > 0 )); do
						output=$output$delimiterNot
						counter=$(($counter-1))
					done
					output=$output$delimiterEnd
					jobIsSweep=$(grep -oP "ThisIsASweepedJobWithJobNumber[0-9]*of[0-9]*" $file)
					if [ -n "$jobIsSweep" ] ; then
						output=$output" ("$(echo $jobIsSweep | grep -oP "[0-9]*of[0-9]*" | tail -n 1)")"
					fi
				fi
				output=$output"\n"

			fi
		done
		if [ -n "$(find ./ -maxdepth 1 -name 'noslurm*.out')" ]; then
			for file in $(ls noslurm*.out); do
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
				# subtract small number that is added later to circumvent false rounding
				counter=$(( ($FileCount - 0.1) * $standardWidth / $StepNumber))
				output=$output$file
				jobIsSweep=$(grep -oP "ThisIsASweepedJobWithJobNumber[0-9]*of[0-9]*" $file)
				if [ -n "$jobIsSweep" ] ; then
					output=$output"("$(echo $jobIsSweep | grep -oP "[0-9]*of[0-9]*" | tail -n 1)")"
				fi
				output=$output":"$delimiterStart
				while (( $counter > 0 )); do
					output=$output$delimiterDone
					counter=$(($counter-1))
				done
				counter=$(( ($StepNumber-$FileCount + 0.1) * $standardWidth / $StepNumber))
				while (( $counter > 0 )); do
					output=$output$delimiterNot
					counter=$(($counter-1))
				done
				output=$output$delimiterEnd"\n"
			done
		fi

	else
		# output=$output"with $(tput cols) we use the sequential display\n"
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
				# subtract small number that is added later to circumvent false rounding
				counter=$(( ($FileCount - 0.1) * $standardWidth / $StepNumber))
				output=$output$file
				jobIsSweep=$(grep -oP "ThisIsASweepedJobWithJobNumber[0-9]*of[0-9]*" $file)
				if [ -n "$jobIsSweep" ] ; then
					output=$output"("$(echo $jobIsSweep | grep -oP "[0-9]*of[0-9]*" | tail -n 1)")"
				fi
				output=$output":"$delimiterStart
				while (( $counter > 0 )); do
					output=$output$delimiterDone
					counter=$(($counter-1))
				done
				counter=$(( ($StepNumber-$FileCount + 0.1) * $standardWidth / $StepNumber))
				while (( $counter > 0 )); do
					output=$output$delimiterNot
					counter=$(($counter-1))
				done
				output=$output$delimiterEnd"\n"
			done
		fi
		output=$(squeue -o "%.10i %.9P %.8u %.2t %.8M" | grep "longexp\|experimen\|goelt\|JOBID" --color=auto)"\n"$output
	fi
	echo -e \\033c
	date +"%H:%M:%S"
	echo -e $output
	if [ "$1" != "" ]; then
		echo $1
		eval $1
	fi
	sleep $(($repeatEvery - ( $(date +%s) - $startTimestamp)))
done

# redo previous change
unset IFS
