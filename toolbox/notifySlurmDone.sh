#!/bin/bash
# if slurm done on hel, and connection over ssh exists
# i want to get a notification


if [[ $1 == "sending" ]]; then
	tmpFile=~/.tmp_slurmJobs

	oldState=$(cat $tmpFile)
	state=$(squeue -u jgoeltz -o "%t" --noheader)
	if [ -z $state ]; then
		if [[ $oldState == "running" ]]; then
			echo slurmDone | nc 127.0.0.1 1234
			echo noJobs > $tmpFile
		fi
	else
		echo running > $tmpFile
	fi
elif [[ $1 == "receiving" ]]; then
	while IFS= read -r line; do
		if [[ $line == "slurmDone" ]]; then
			dunstify -r 6666 -t 3000 "Slurm jobs on hel finished"
		fi
	done
fi
