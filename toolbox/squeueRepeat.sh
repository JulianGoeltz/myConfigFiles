#!/bin/zsh

standardWidth=20
repeatEvery=10
redoAfter=$(($repeatEvery + 20))
fileSave=~/.tmp_squeueRepeat_new
fileTmpScontrol=~/.tmp_scontrol.sh
clusterName="new cluster"
minimumColsForParallel=80
delimiterDone="|"
delimiterNot='-'
delimiterNot='\xe2\x94\x88'
delimiterStart='\xe2\x96\x95'
delimiterEnd='\xe2\x96\x8f'
delimiterDone='\xe2\x96\x88'
# split on new lines, not spaces. In case we have filenames including spaces
IFS=$'\n'

# treat arguments
echo $@ | grep -qP "(\s|^)(-v|--verbose)(\s|$|v)" && verbose=true || verbose=false
echo $@ | grep -qP "(\s|^)(-vv)(\s|$)" && vverbose=true || vverbose=false
echo $@ | grep -qP "(\s|^)(work)(\s|$)" && argWorking=true || argWorking=false

# check if file is too old
timeSinceTouch=$(($(date +%s) - $(stat -c %Y $fileSave)))
if ! $verbose ; then
	#if either the file is not old, or already being processed, just output the current one
	if [ $timeSinceTouch -lt $repeatEvery ]; then
		if [ "$(tail -c1 $fileSave)" = "." ]; then
			# only if it didnt take too long since last change
			if [ $timeSinceTouch -lt $redoAfter ]; then
				echo -ne \\033c
				echo -n "Printed $(date +'%H:%M:%S')"
				cat $fileSave
				sleep $repeatEvery
				exit
			fi
		fi
	fi
fi

# echo single dot to indicate start of process
$argWorking && echo -n . >> $fileSave
echo -n .

sleepNotNegaitve() {
	sleep $( echo "0\n$(($repeatEvery - ( $(date +%s) - $1)))" | sort -g | tail -n 1)
}

durationPrint() {
	duration=$1
	tmpOut=""
	[ $duration -gt  $((24*60*60)) ] && tmpOut="$tmpOut$(($duration/24/60/60))-"
	[ $duration -gt  3600 ] && tmpOut="$tmpOut$(($duration/60/60%24)):"
	tmpOut="$tmpOut$(($duration/60%60))"
	tmpOut="$tmpOut:$(printf '%02d' $(($duration%60)))"
	echo $tmpOut
}

#while true; do
	startTimestamp=$(date +%s)
	# decide whether to use sequential or parallel, based on terminal size
	# first compose longer part, then echo all at once
	output=""
	$verbose && output=$output"Verbose Output\n"
	$vverbose && output=$output"Even very verbose Output\n"

	output_pending=""
	for linefeed in $(squeue -t pd -p longexp,experiment --noheader -o  "%.8u" --noheader | grep -v jgoeltz | sort | uniq -c ); do
		output_pending=$output_pending$(echo $linefeed | awk '{print $2": "$1}')"; "
	done
	[ -n "$output_pending" ] && output=$output"Pending on experiment:: "${output_pending:0:-2}"\n"
	count_ownall=$(squeue -u jgoeltz --noheader -o  "%.8u" --noheader | wc -l)
	count_ownpending=$(squeue -t pd -u jgoeltz --noheader -o  "%.8u" --noheader | wc -l)
	count_all=$(squeue --noheader -o  "%.8u" | wc -l)
	output=$output"Own jobs count; total: $count_ownall, pending: $count_ownpending; all: $count_all\n"

	if [ "$(tput cols)" -gt "$minimumColsForParallel" ]; then
		remCols=$(($(tput cols) - 80))
		# output=$output"with $(tput cols) we use the parallel display\n"
		if $vverbose; then
			# also show pending
			allLines=$(squeue -o "%.10i %.9P %.8u %.2t %.10M" --sort=-p,u,i |
				grep "longexp\|experimen\|goelt\|JOBID" --color=never)
		else
			allLines=$(squeue -t R -o "%.10i %.9P %.8u %.2t %.10M" --sort=-p,u,i |
				grep "longexp\|experimen\|goelt\|JOBID" --color=never)
		fi
		allLinesNum=$(echo $allLines | wc -l)
		for linefeed in $(echo $allLines); do
			if [ -z "$(echo $linefeed | grep jgoeltz)" ]; then
				output=$output$(echo $linefeed | grep "longexp\|experimen\|goelt\|JOBID" --color=always)"\n"
			else
				output=$output$(echo $linefeed | grep "experimen\|jgoeltz" --color=always)
				jobid=$(echo $linefeed | grep -oP '^\s*([0-9]*)' | grep -o '[0-9]*')

				# find the file worked on (only do for small job numbers, otherwise its a hassle
				if [[ "$allLinesNum" -lt 8 ]] || $verbose; then
					scontrol write batch_script $jobid $fileTmpScontrol >/dev/null
					tmpString=$([ -f $fileTmpScontrol ] && grep -oP "\S*\.(yaml|hdf5)\S*" $fileTmpScontrol)
					# check whether we found something
					if [ -n $tmpString ]; then
						if [[ "$(echo $tmpString | wc -l)" -eq 1 ]]; then
							if echo $tmpString | grep -q yaml; then
								tmpString=$(basename "$(dirname $tmpString)")
							else
								tmpString=$(basename "$tmpString")
							fi
						elif $vverbose; then
							tmpString="$(echo $tmpString | wc -l) files"
						else
							tmpString=""
						fi
						output=$output" ${tmpString:0:$remCols}"
					fi
				fi

				# look how far we are
				file=$(find ./ -maxdepth 1 -name "*slurm-$jobid.out")
				if [ -n "$file" ]; then
					# if [ $(du $file | grep -o "^[0-9]*") -ge 200000 ]; then
					# 	#this means the file is very large and it will take too long to search through
					#         echo $file is too large, skipping
					# 	continue
					# fi
					StepNumber=$(grep -oP "Number_of_steps is [0-9]*" $file | grep -oP "[0-9]*")
					FileCount=$(grep " steps " -c $file)
					[ $? -ne 0 ] && output=$output"\n" && continue
					if [ -z "$StepNumber" ] ; then StepNumber=200; fi
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
					timeSinceTouch=$(($startTimestamp - $(stat -c %Y $file)))
					if [ $timeSinceTouch -gt 60 ]; then
						output="${output} not changed for $(durationPrint $timeSinceTouch)"
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
				StepNumber=$(grep -oP "Number_of_steps is [0-9]*" $file | grep -oP "[0-9]*")
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
				output=$output":"
				# how long has it been
				notedTime=$(date -d "${$(grep -io "It is.*" $file):6:99}" +%s)
				if [ -n "$notedTime" ] ; then
					duration=$(($(date +%s) - $notedTime))
					echo $duration
					output="$output $(durationPrint $duration)"

				fi
				output=$output$delimiterStart
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
				timeSinceTouch=$(($startTimestamp - $(stat -c %Y $file)))
				if [ $timeSinceTouch -gt 60 ]; then
					output="${output} not changed for $(durationPrint $timeSinceTouch)"
				fi
				output=$output"\n"
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
	$verbose || echo -ne \\033c
	$argWorking && echo -ne ", created $(date +'%H:%M:%S') on $clusterName\n${output:0:-2}" > $fileSave
	echo "Created $(date +'%H:%M:%S') on $clusterName"
	# to get rid of trailing newline, -n and cut ot off last 2 chars (\n)
	echo -ne ${output:0:-2}
	# if [ "$1" != "" ]; then
	# 	echo $1
	# 	eval $1
	# fi
	$verbose || sleepNotNegaitve $startTimestamp
	# sleep $( echo "0\n$(($repeatEvery - ( $(date +%s) - $startTimestamp)))" | sort | head -n 1)
#done

# redo previous change
unset IFS
