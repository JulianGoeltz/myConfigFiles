#!/bin/zsh

# echo single dot to indicate start of process
echo -n .

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

sleepNotNegaitve() {
	sleep $( echo "0\n$(($repeatEvery - ( $(date +%s) - $1)))" | sort -g | tail -n 1)
}

#while true; do
	startTimestamp=$(date +%s)
	# decide whether to use sequential or parallel, based on terminal size
	# first compose longer part, then echo all at once
	output=""

	output_pending=""
	for linefeed in $(squeue -t pd -p longexp,experiment --noheader -o  "%.8u" --noheader | grep -v jgoeltz | sort | uniq -c ); do
		output_pending=$output_pending$(echo $linefeed | awk '{print $2": "$1}')"; "
	done
	[ -n "$output_pending" ] && output=$output"Pending on experiment:: "${output_pending:0:-2}"\n"
	count_ownall=$(squeue -u jgoeltz --noheader -o  "%.8u" --noheader | wc -l)
	count_ownpending=$(squeue -t pd -u jgoeltz --noheader -o  "%.8u" --noheader | wc -l)
	output=$output"Own jobs count; total: $count_ownall, pending: $count_ownpending\n"

	if [ "$(tput cols)" -gt "$minimumColsForParallel" ]; then
		# output=$output"with $(tput cols) we use the parallel display\n"
		for linefeed in $(squeue -t R -o "%.10i %.9P %.8u %.2t %.10M" --sort=u,P,i |
			grep "longexp\|experimen\|goelt\|JOBID" --color=never); do
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
		output=$(squeue -t R -o "%.10i %.9P %.8u %.2t %.10M" | grep "longexp\|experimen\|goelt\|JOBID" --color=auto)"\n"$output
	fi
	echo -ne \\033c
	date +"%H:%M:%S"
	# to get rid of trailing newline, -n and cut ot off last 2 chars (\n)
	echo -ne ${output:0:-2}
	if [ "$1" != "" ]; then
		echo $1
		eval $1
	fi
	sleepNotNegaitve $startTimestamp
	# sleep $( echo "0\n$(($repeatEvery - ( $(date +%s) - $startTimestamp)))" | sort | head -n 1)
#done

# redo previous change
unset IFS
